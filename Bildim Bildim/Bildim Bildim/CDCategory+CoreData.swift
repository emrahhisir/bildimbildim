//
//  Category+CoreData.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 10/13/14.
//  Copyright (c) 2014 Emrah Hisir. All rights reserved.
//

import Foundation

extension CDCategory {
    func setProperties(properties: [AnyObject?], subCats: [CDCategory?]) {
        if (properties[0] != nil) {
            imagePath = properties[0] as! String
        }
        if (properties[1] != nil) {
            name = properties[1] as! String
        }
        if (properties[2] != nil) {
            id = properties[2] as! NSNumber
        }
        if (properties[3] != nil) {
            desc = properties[3] as! String
        }
        if (properties[4] != nil) {
            color = properties[4] as! String
        }
        if (properties[5] != nil) {
            active = properties[5] as! NSNumber
        }
        if (properties[6] != nil) {
            parentCat = properties[6] as? CDCategory
        }
        for subCat in subCats {
            if let existSubCat = subCat {
                self.mutableSetValueForKey("subCats").addObject(existSubCat)
            }
        }
        //self.mutableSetValueForKey("questions").addObject(properties[8]!)
    }
}