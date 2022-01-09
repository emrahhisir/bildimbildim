//
//  CDCategory.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 1/2/15.
//  Copyright (c) 2015 Emrah Hisir. All rights reserved.
//

import Foundation
import CoreData

@objc(CDCategory)
class CDCategory: NSManagedObject {

    @NSManaged var active: NSNumber
    @NSManaged var color: String
    @NSManaged var desc: String
    @NSManaged var id: NSNumber
    @NSManaged var imagePath: String
    @NSManaged var name: String
    @NSManaged var isNew: NSNumber
    @NSManaged var parentCat: CDCategory?
    @NSManaged var questions: NSSet
    @NSManaged var subCats: NSSet

}
