//
//  CAGradientLayer.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 11/18/14.
//  Copyright (c) 2014 Emrah Hisir. All rights reserved.
//

import QuartzCore
import UIKit

extension CAGradientLayer {
    
    class func colorGradientLayer(color1: CGColorRef, color2:CGColorRef) -> CAGradientLayer {
        
        let gradientColors: [AnyObject] = [color1, color2]
        let gradientLocations = [0.3, 0.6]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPointMake(1.0, 1.0)
        gradientLayer.endPoint = CGPointMake(0.0, 0.0)
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
    }
}
