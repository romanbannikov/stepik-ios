//
//  CongratsView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 11.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CongratsView: UIView {
    let backgroundAnimationColor: UIColor = UIColor.white.withAlphaComponent(0.3)
    let backgroundSectionsCount: Int = 18
    let backgroundRotateDuration: CFTimeInterval = 30.0
    let padOpacity: CGFloat = 0.15
    
    private var blurView: UIVisualEffectView?
    private var padView: UIView?
    private var shapeLayer: CAShapeLayer?
    
    override var isHidden: Bool {
        willSet {
            self.shapeLayer?.isHidden = !self.isHidden
            UIView.animate(withDuration: 0.5, animations: {
                self.blurView?.alpha = self.isHidden ? 1.0 : 0.0
                self.padView?.alpha = self.isHidden ? self.padOpacity : 0.0
            })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Blur
        padView = UIView(frame: bounds)
        padView?.backgroundColor = .black
        padView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(padView ?? UIView())
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView?.frame = bounds
        blurView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView ?? UIView())
        
        // Background animation
        let path: CGMutablePath = CGMutablePath()
        
        // colors and clears sections
        shapeLayer = CAShapeLayer()
        let angle = Double.pi / (Double(backgroundSectionsCount) / 2)
        for i in 1...backgroundSectionsCount {
            if i % 2 == 0 {
                let startAngle = angle * Double(i)
                let endAngle = startAngle + angle
                
                path.move(to: CGPoint(x: 0.0, y: 0.0))
                path.addArc(center: CGPoint(x: 0.0, y: 0.0), radius: frame.height + frame.width, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: false)
                path.closeSubpath()
            }
        }
        
        shapeLayer?.position = CGPoint(x: center.x, y: center.y)
        shapeLayer?.path = path
        shapeLayer?.fillColor = backgroundAnimationColor.cgColor
        layer.addSublayer(shapeLayer ?? CAShapeLayer())
        
        // Add rotation
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = 2 * Double.pi
        animation.duration = backgroundRotateDuration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fillMode = kCAFillModeForwards
        shapeLayer?.add(animation, forKey: animation.keyPath)
        
        padView?.alpha = 0.0
        blurView?.alpha = 0.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shapeLayer?.position = CGPoint(x: center.x, y: center.y)
    }
}
