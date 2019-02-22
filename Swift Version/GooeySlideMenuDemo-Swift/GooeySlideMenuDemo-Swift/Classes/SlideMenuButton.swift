//
//  SlideMenuButton.swift
//  GooeySlideMenuDemo-Swift
//
//  Created by Kitten Yang on 1/3/16.
//  Copyright © 2016 Kitten Yang. All rights reserved.
//

import UIKit

struct MenuButtonOptions {
    var title: String
    var buttonColor: UIColor
    var buttonClickBlock: ()->()
}

final class SlideMenuButton: UIView {

    private var option: MenuButtonOptions
    
    init(option: MenuButtonOptions) {
        self.option = option
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        guard let ctx = context else { return }
        
        ctx.addRect(rect)
        option.buttonColor.set()
        ctx.fillPath()

        let roundedRectanglePath = UIBezierPath(roundedRect: rect.insetBy(dx: 1, dy: 1), cornerRadius: rect.height / 2)
        option.buttonColor.setFill()
        roundedRectanglePath.fill()
        UIColor.white.setStroke()
        roundedRectanglePath.lineWidth = 1
        roundedRectanglePath.stroke()

        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.alignment = .center
        let attr = [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24.0),NSAttributedString.Key.foregroundColor: UIColor.white]
        let size = option.title.size(withAttributes: attr)
        
        let r = CGRect(x:rect.origin.x,
                       y:rect.origin.y + (rect.size.height - size.height)/2.0,
                       width:rect.size.width,
                       height:size.height)
        option.title.draw(in: r, withAttributes: attr)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let touch = touch {
            let tapCount = touch.tapCount
            switch (tapCount) {
            case 1: option.buttonClickBlock()
            default: break
            }
        }
    }
}
