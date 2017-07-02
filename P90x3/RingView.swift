//
//  RingView.swift
//  P90x3
//
//  Created by Naman Kedia on 7/1/17.
//

import UIKit

class RingView: UIView {
    
    var backgroundRingLayer: CAShapeLayer!
    var ringLayer: CAShapeLayer!
    var gradientLayer: CAGradientLayer!
    var percentageLabel = UILabel()
    var numberOfQuestions: Int?
    
    var lineWidth: Double = 10.0
    
    var numberOfCompletedWorkouts: Int = 64 {
        didSet {
            updateLayerProperties()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let ringSize = min(bounds.width, bounds.height) - 40
        let ringBounds = CGRect(origin: CGPoint(x: (bounds.width-ringSize)/2.0, y: (bounds.height-ringSize)/2.0), size: CGSize(width: ringSize, height: ringSize))
        
        lineWidth = floor(Double(ringSize) * 0.08)
        
        percentageLabel.frame = ringBounds
        percentageLabel.font = UIFont.systemFont(ofSize: CGFloat(ringSize * 0.3), weight: UIFont.Weight.ultraLight)
        percentageLabel.numberOfLines = 0
        percentageLabel.textColor = UIColor.white
        percentageLabel.textAlignment = NSTextAlignment.center
        
        self.addSubview(percentageLabel)
        
        if backgroundRingLayer == nil {
            backgroundRingLayer = CAShapeLayer()
            layer.addSublayer(backgroundRingLayer)
            backgroundRingLayer.fillColor = nil
            backgroundRingLayer.strokeColor = UIColor(white: 1.0, alpha: 0.1).cgColor
        }
        
        let backgroundRingBounds = CGRect(origin: CGPoint.zero, size: ringBounds.size)
        let backgroundLayerRect = backgroundRingBounds.insetBy(dx: CGFloat(lineWidth / 2.0), dy: CGFloat(lineWidth / 2.0))
        let backgroundLayerPath = UIBezierPath(ovalIn: backgroundLayerRect)
        backgroundRingLayer.path = backgroundLayerPath.cgPath
        backgroundRingLayer.lineWidth = CGFloat(lineWidth)
        
        
        if ringLayer == nil {
            ringLayer = CAShapeLayer()
            ringLayer.fillColor = nil
            ringLayer.strokeColor = UIColor.orange.cgColor
            ringLayer.anchorPoint = CGPoint(x: CGFloat(0.5),y: CGFloat(0.5))
            ringLayer.transform = CATransform3DRotate(ringLayer.transform, CGFloat(-Double.pi / 2), CGFloat(0), CGFloat(0), CGFloat(1))
            ringLayer.strokeEnd = 0.0
            layer.addSublayer(ringLayer)
            
            ringLayer.lineCap = kCALineCapRound
            ringLayer.lineJoin = kCALineJoinRound
        }
        
        let innerRingBounds = CGRect(origin: CGPoint.zero, size: ringBounds.size)
        let ringLayerRect = innerRingBounds.insetBy(dx: CGFloat(lineWidth / 2.0), dy: CGFloat(lineWidth / 2.0))
        let ringLayerPath = UIBezierPath(ovalIn: ringLayerRect)
        
        ringLayer.lineWidth = CGFloat(lineWidth)
        ringLayer.path = ringLayerPath.cgPath
        if gradientLayer == nil {
            gradientLayer = CAGradientLayer()
            let startColor = UIColor(red: 255/255, green: 142/255, blue: 0/255, alpha: 1.0)
            let endColor = UIColor(red: 248/255, green: 137/255, blue: 60/255, alpha: 1.0)
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
            layer.addSublayer(gradientLayer)
            gradientLayer.mask = ringLayer
        }
        
        
        backgroundRingLayer.frame = ringBounds
        gradientLayer.frame = ringBounds
        ringLayer.frame = gradientLayer.bounds
        
        updateLayerProperties()
    }
    
    func animate() {
        let pathAnimation = CASpringAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 2.0
        pathAnimation.damping = 16.0
        
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        pathAnimation.fromValue = ringLayer.strokeEnd = 0.0
        pathAnimation.toValue = ringLayer.strokeEnd = CGFloat(Double(numberOfCompletedWorkouts) / 90.0)
        
        ringLayer.add(pathAnimation, forKey: "strokeEnd")
        
        
    }
    
    private func updateLayerProperties() {
        let ringSize = min(bounds.width, bounds.height) - 40
        let thinFont = UIFont.systemFont(ofSize: ringSize * 0.3, weight: UIFont.Weight.bold)
        let lightFont = UIFont.systemFont(ofSize: ringSize * 0.1, weight: UIFont.Weight.light)
        let attributedText = NSMutableAttributedString(string: String(numberOfCompletedWorkouts), attributes: [NSAttributedStringKey.font : thinFont, NSAttributedStringKey.foregroundColor : UIColor.white])
        attributedText.append(NSAttributedString(string: "\n of \(90)", attributes: [NSAttributedStringKey.font: lightFont, NSAttributedStringKey.foregroundColor:UIColor(white: CGFloat(1.0), alpha: CGFloat(0.5)) ]))
        percentageLabel.attributedText = attributedText
    }
    
    
}


