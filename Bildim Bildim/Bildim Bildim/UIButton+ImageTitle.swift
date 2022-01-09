//
//  UIButton+ImageTitle.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 11/27/14.
//  Copyright (c) 2014 Emrah Hisir. All rights reserved.
//

import Foundation

extension UIButton {
    
    func centerButtonAndImageWithSpacing(buttonSize: CGFloat) {
        self.imageEdgeInsets = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
        if let image = self.imageForState(UIControlState.Normal) {
            self.titleEdgeInsets = UIEdgeInsetsMake(buttonSize - 20.0, -image.size.width, 0.0, 0.0)
        }
    }
}