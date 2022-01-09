//
//  CDQuestion.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 10/14/14.
//  Copyright (c) 2014 Emrah Hisir. All rights reserved.
//

import Foundation
import CoreData

@objc(CDQuestion)
class CDQuestion: NSManagedObject {

    @NSManaged var active: NSNumber
    @NSManaged var difficultLevel: NSNumber
    @NSManaged var id: NSNumber
    @NSManaged var localGroup: String
    @NSManaged var question: String
    @NSManaged var category: NSSet

}
