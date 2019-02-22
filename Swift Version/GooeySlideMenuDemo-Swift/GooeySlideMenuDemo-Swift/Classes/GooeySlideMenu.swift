//
//  GooeySlideMenu.swift
//  GooeySlideMenuDemo-Swift
//
//  Created by Kitten Yang on 1/3/16.
//  Copyright © 2016 Kitten Yang. All rights reserved.
//

import UIKit
//index, title, titleCounts
typealias MenuButtonClickedBlock = (Int, String, Int) -> ()

struct MenuOptions {
    var titles: [String]
    var buttonHeight: CGFloat
    var menuColor: UIColor
    var blurStyle: UIBlurEffect.Style
    var buttonSpace: CGFloat
    var menuBlankWidth: CGFloat
    var menuClickBlock: MenuButtonClickedBlock
}

final class GooeySlideMenu: UIView {

    private var options: MenuOptions
    private var keyWindow: UIWindow?
    private var blurView: UIVisualEffectView!
    private var helperSideView: UIView!
    private var helperCenterView: UIView!
    
    private var diff: CGFloat = 0.0
    private var triggered: Bool = false
    private var displayLink: CADisplayLink?
    private var animationCount: Int = 0
    
    init(options: MenuOptions) {
        self.options = options
        if let kWindow = UIApplication.shared.keyWindow {
            keyWindow = kWindow
            let frame = CGRect(
                x: -kWindow.frame.size.width / 2 - options.menuBlankWidth,
                y: 0,
                width: kWindow.frame.size.width / 2 + options.menuBlankWidth,
                height: kWindow.frame.size.height)
            super.init(frame:frame)
        } else {
            super.init(frame:CGRect.zero)
        }
        setUpViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: frame.width-options.menuBlankWidth, y: 0))
        path.addQuadCurve(to: CGPoint(x: frame.width-options.menuBlankWidth, y: frame.height), controlPoint: CGPoint(x: frame.width-options.menuBlankWidth+diff, y: frame.height/2))
        path.addLine(to: CGPoint(x: 0, y: frame.height))
        path.close()
        
        let context = UIGraphicsGetCurrentContext()
        context?.addPath(path.cgPath)
        options.menuColor.set()
        context?.fillPath()
    }
    
    func trigger() {
        
        if triggered { tapToUntrigger() }
        
        guard let keyWindow = keyWindow else { return }
        
        keyWindow.insertSubview(blurView, belowSubview: self)
        UIView.animate(withDuration: 0.3, animations: { [weak self] () -> Void in
            guard let nonNifSelf = self else { return }
            nonNifSelf.frame = CGRect(
                x: 0,
                y: 0,
                width: keyWindow.frame.size.width/2 + nonNifSelf.options.menuBlankWidth,
                height: keyWindow.frame.size.height)
        })
        
        beforeAnimation()
        UIView.animate(withDuration: 0.7,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.9,
                       options: [.beginFromCurrentState,.allowUserInteraction],
                       animations: { [weak self] () -> Void in
                        
                        guard let nonNilSelf = self else { return }
                        
                        nonNilSelf.helperSideView.center = CGPoint(x: keyWindow.center.x, y: nonNilSelf.helperSideView.frame.size.height/2);
            }, completion: { [weak self] (finish) -> Void in
                self?.finishAnimation()
        })
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] () -> Void in
            self?.blurView.alpha = 1.0
        })
        
        beforeAnimation()
        UIView.animate(withDuration: 0.7,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 2.0,
                       options: [.beginFromCurrentState,.allowUserInteraction],
                       animations: { [weak self] () -> Void in
                        
                        self?.helperCenterView.center = keyWindow.center
            }, completion: { [weak self] (finished) -> Void in
                if finished {
                    let tapGesture = UITapGestureRecognizer(target: self, action: Selector(("tapToUntrigger")))
                    self?.blurView.addGestureRecognizer(tapGesture)
                    self?.finishAnimation()
                }
        })
        animateButtons()
        triggered = true
    }
}

extension GooeySlideMenu {
    
    private func setUpViews() {
        
        guard let keyWindow = keyWindow else { return }
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: options.blurStyle))
        blurView.frame = keyWindow.frame
        blurView.alpha = 0.0
        
        helperSideView = UIView(frame: CGRect(x: -40, y: 0, width: 40, height: 40))
        helperSideView.backgroundColor = .red
        helperSideView.isHidden = true
        keyWindow.addSubview(helperSideView)
        
        helperCenterView = UIView(frame: CGRect(x: -40, y: keyWindow.frame.height/2 - 20, width: 40, height: 40))
        helperCenterView.backgroundColor = .yellow
        helperCenterView.isHidden = true
        keyWindow.addSubview(helperCenterView)
        
        backgroundColor = .clear
        keyWindow.insertSubview(self, belowSubview: helperSideView)
        addButton()
    }
    
    private func addButton() {
        let titles = options.titles
        if titles.count % 2 == 0 {
            var index_down = titles.count / 2
            var index_up = -1
            for i in 0..<titles.count {
                let title = titles[i]
                let buttonOption = MenuButtonOptions(title:title, buttonColor:options.menuColor, buttonClickBlock:{ [weak self] () -> () in
                    self?.tapToUntrigger()
                    self?.options.menuClickBlock(i,title,titles.count)
                    })
                let home_button = SlideMenuButton(option: buttonOption)
                home_button.bounds = CGRect(x:0, y:0, width:frame.width - options.menuBlankWidth - 20*2, height: options.buttonHeight);
                addSubview(home_button)
                if (i >= titles.count / 2) {
                    index_up = index_up + 1
                    let y = frame.height/2 + options.buttonHeight*CGFloat(index_up) + options.buttonSpace*CGFloat(index_up)
                    home_button.center = CGPoint(x: (frame.width - options.menuBlankWidth)/2, y: y+options.buttonSpace/2 + options.buttonHeight/2)
                } else {
                    index_down = index_down - 1
                    let y = frame.height/2 - options.buttonHeight*CGFloat(index_down) - options.buttonSpace*CGFloat(index_down)
                    home_button.center = CGPoint(x: (frame.width - options.menuBlankWidth)/2, y: y - options.buttonSpace/2 - options.buttonHeight/2)
                }
            }
        } else {
            var index = (titles.count-1) / 2 + 1
            for i in 0..<titles.count {
                index = index - 1
                let title = titles[i]
                let buttonOption = MenuButtonOptions(title: title, buttonColor: options.menuColor, buttonClickBlock: { [weak self] () -> () in
                    self?.tapToUntrigger()
                    self?.options.menuClickBlock(i, title, titles.count)
                    })
                let home_button = SlideMenuButton(option: buttonOption)
                home_button.bounds = CGRect(x: 0, y: 0, width: frame.width - options.menuBlankWidth - 20*2, height: options.buttonHeight)
                home_button.center = CGPoint(x: (frame.width - options.menuBlankWidth)/2, y: frame.height/2 - options.buttonHeight*CGFloat(index) - 20*CGFloat(index))
                addSubview(home_button)
            }
        }
    }
    
    private func animateButtons() {
        for i in 0..<subviews.count {
            let menuButton = subviews[i]
            menuButton.transform = CGAffineTransform(translationX: -90, y: 0)
            UIView.animate(withDuration: 0.7, delay: Double(i)*(0.3/Double(subviews.count)), usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [.beginFromCurrentState,.allowUserInteraction], animations: { () -> Void in
                    menuButton.transform =  .identity
                }, completion: nil)
        }
    }
    
   @objc private func tapToUntrigger() {
    
    UIView.animate(withDuration: 0.3) { [weak self] () -> Void in
        
    guard let nonNilSelf = self, let keyWindow = self?.keyWindow else { return }
        
    let x = -keyWindow.frame.size.width/2 - nonNilSelf.options.menuBlankWidth
    let width = keyWindow.frame.size.width/2 + nonNilSelf.options.menuBlankWidth
    nonNilSelf.frame = CGRect(
        x: x,
        y: 0,
        width: width,
        height: keyWindow.frame.size.height)
    }
    
    beforeAnimation()
    
    UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.9, options: [.beginFromCurrentState,.allowUserInteraction], animations: { () -> Void in
            self.helperSideView.center = CGPoint(x: -self.helperSideView.frame.height/2, y: self.helperSideView.frame.height/2)
            }) { [weak self] (finish) -> Void in
                self?.finishAnimation()
        }
        
    UIView.animate(withDuration: 0.3) { () -> Void in
            self.blurView.alpha = 0.0
        }
        
        beforeAnimation()
    UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: [.beginFromCurrentState,.allowUserInteraction], animations: { () -> Void in
        self.helperCenterView.center = CGPoint(x:-self.helperSideView.frame.size.height/2, y:self.frame.size.height/2)
            }) { (finish) -> Void in
                self.finishAnimation()
        }
        triggered = false
    }
    
    private func beforeAnimation() {
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: Selector(("handleDisplayLinkAction:")))
            displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        }
        animationCount = animationCount + 1
    }
    
    private func finishAnimation() {
        animationCount = animationCount - 1
        if animationCount == 0 {
            displayLink?.invalidate()
            displayLink = nil
        }
    }
    
    @objc private func handleDisplayLinkAction(_ displaylink: CADisplayLink) {
        
        guard let sideHelperPresentationLayer = helperSideView.layer.presentation(),
            let centerHelperPresentationLayer = helperCenterView.layer.presentation() else { return }
        
        let centerRect = (centerHelperPresentationLayer.value(forKeyPath: "frame") as AnyObject).cgRectValue
        let sideRect   = (sideHelperPresentationLayer.value(forKeyPath: "frame") as AnyObject).cgRectValue
        
        if let centerRect = centerRect, let sideRect = sideRect {
            diff = sideRect.origin.x - centerRect.origin.x
        }
        setNeedsDisplay()
    }
}


