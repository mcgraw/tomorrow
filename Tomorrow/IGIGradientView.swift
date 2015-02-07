//
//  IGIGradientView.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

class IGIGradientView: UIView {
    
    var gradientLayer: CAGradientLayer?
    
    var startColor: UIColor?
    var endColor: UIColor?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer?.frame = bounds
    }
    
    func updateGradientLayer(startColor: UIColor, endColor: UIColor) {
        self.startColor = startColor
        self.endColor = endColor
        
        if gradientLayer == nil {
            gradientLayer = CAGradientLayer()
            gradientLayer?.frame = bounds
            gradientLayer?.colors = [startColor.CGColor, endColor.CGColor]
            layer.insertSublayer(gradientLayer, atIndex: 0)
        } else {
            gradientLayer?.colors = [startColor.CGColor, endColor.CGColor]
        }
    }
}
