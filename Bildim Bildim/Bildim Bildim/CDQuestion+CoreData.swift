//
//  CDQuestion+CoreData.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 10/23/14.
//  Copyright (c) 2014 Emrah Hisir. All rights reserved.
//

import Foundation

extension CDQuestion {
    func setProperties(properties: [AnyObject?]) {
        if (properties[0] != nil) {
            active = properties[0] as! NSNumber
        }
        if (properties[1] != nil) {
            difficultLevel = properties[1] as! NSNumber
        }
        if (properties[2] != nil) {
            id = properties[2] as! NSNumber
        }
        if (properties[3] != nil) {
            localGroup = properties[3] as! String
        }
        if (properties[4] != nil) {
            question = properties[4] as! String
        }
        if let existCat: AnyObject = properties[5] {
            self.mutableSetValueForKey("category").addObject(existCat)
        }
    }
}