//
//  ViewController.swift
//  AnimatedCircleDemo-Swift
//
//  Created by Kitten Yang on 1/18/16.
//  Copyright © 2016 Kitten Yang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var slider: UISlider!

    private var circleView: CircleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let x = CGFloat((view.frame.size.width - 320)/2.0)
        let y = CGFloat((view.frame.size.height - 320)/2.0)
        circleView = CircleView(frame: CGRect(x: x,
                                              y: y,
                                              width: CGFloat(320.0),
                                              height: CGFloat(320.0)))
        view.addSubview(circleView)
        
        circleView.circleLayer.progress = CGFloat(slider.value)
    }

    @IBAction func didValueChanged(sender: AnyObject) {
        if let slider = sender as? UISlider {
            progressLabel.text = "Current: \(slider.value)"
            circleView.circleLayer.progress = CGFloat(slider.value)
        }
    }

}

