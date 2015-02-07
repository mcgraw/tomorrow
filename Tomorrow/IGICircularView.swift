//
//  IGICircularView.swift
//  Tomorrow
//
//  Created by David McGraw on 1/24/15.
//  Copyright (c) 2015 David McGraw. All rights reserved.
//

import UIKit

class IGICircularView: IGIView {
    
    var shapeLayer: CAShapeLayer?
    
    required override init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        shapeLayer = CAShapeLayer()
        shapeLayer?.frame = bounds
        shapeLayer?.path = UIBezierPath(ovalInRect: bounds).CGPath
        shapeLayer?.lineWidth = 3.0
        shapeLayer?.strokeColor = UIColor.whiteColor().CGColor
        shapeLayer?.fillColor = UIColor.clearColor().CGColor
        shapeLayer?.rasterizationScale = 2.0 * UIScreen.mainScreen().scale
        shapeLayer?.shouldRasterize = true
        layer.insertSublayer(shapeLayer, atIndex: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shapeLayer?.frame = bounds
    }
    
}
