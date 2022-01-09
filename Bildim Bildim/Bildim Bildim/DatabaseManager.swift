//
//  DatabaseManager.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 10/2/14.
//  Copyright (c) 2014 Emrah Hisir. All rights reserved.
//

import Foundation
import CoreData

class DatabaseManager {
    let serverJSONPath = "s3.amazon.com";
    private struct SubStruct { static var moc: NSManagedObjectContext = AppDelegate.moc! }
    class var MAX_NUM_OF_QUESTIONS_IN_A_QUERY: UInt32 {
        return 100
    }
    
    class var moc: NSManagedObjectContext
        {
        get { return SubStruct.moc }
        set { SubStruct.moc = newValue }
    }
    
    class func getCategories() -> [CDCategory] {
        var errorOptional: NSError?
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let catEntityName: NSString = "CDCategory"
        let fetchRequest = NSFetchRequest(entityName: catEntityName as String)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return moc.executeFetchRequest(fetchRequest, error: &errorOptional) as! [CDCategory]
    }
    
    class func setAllCategoriesOld() {
        var errorOptional: NSError?
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let catEntityName: NSString = "CDCategory"
        let fetchRequest = NSFetchRequest(entityName: catEntityName as String)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let categories = moc.executeFetchRequest(fetchRequest, error: &errorOptional) as! [CDCategory]
        
        for category in categories {
            category.isNew = 0
        }
        
    }
    
    class func getQuestions() -> [CDQuestion] {
        var errorOptional: NSError?
        
        let catEntityName: NSString = "CDQuestion"
        let fetchRequest = NSFetchRequest(entityName: catEntityName as String)
        
        return moc.executeFetchRequest(fetchRequest, error: &errorOptional) as! [CDQuestion]
    }

    class func getTopCategories() -> [CDCategory] {
        var errorOptional: NSError?
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let catEntityName: NSString = "CDCategory"
        let fetchRequest = NSFetchRequest(entityName: catEntityName as String)
        fetchRequest.predicate = NSPredicate(format: "parentCat.@count == 0")
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return moc.executeFetchRequest(fetchRequest, error: &errorOptional) as! [CDCategory]
    }
    
    class func getNewCategories() -> [CDCategory] {
        var errorOptional: NSError?
        var index = 0
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let catEntityName: NSString = "CDCategory"
        let fetchRequest = NSFetchRequest(entityName: catEntityName as String)
        fetchRequest.predicate = NSPredicate(format: "isNew == 1")
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        var cats = moc.executeFetchRequest(fetchRequest, error: &errorOptional) as! [CDCategory]
        
        for cat in cats {
            if (cat.parentCat?.isNew == 1) {
                cats.removeAtIndex(index)
            }
            else {
                index = index + 1
            }
        }
        
        return cats
    }
    
    private class func getSubCatIds(category: CDCategory) -> [NSNumber] {
        var result:[NSNumber] = [category.id]
        
        for subCat in category.subCats {
            if let validSubCat = subCat as? CDCategory {
                if (validSubCat.subCats.count > 0) {
                    result.extend(getSubCatIds(validSubCat))
                }
                else {
                    result.append(validSubCat.id)
                }
            }
        }
        
        return result
    }
    
    class func getQuestions(categories: [CDCategory]?) -> [CDQuestion] {
        var errorOptional: NSError?
        var subcatIdArray = [NSNumber]()
        var result = [CDQuestion]()
        var fetchedQuestions = [CDQuestion]()
        
        if let validCategories = categories {
            for category in validCategories {
                subcatIdArray = getSubCatIds(category)
            }
        }
        let catEntityName: NSString = "CDQuestion"
        let fetchRequest = NSFetchRequest(entityName: catEntityName as String)
        fetchRequest.predicate = NSPredicate(format: "ANY category.id IN %@", subcatIdArray)
        
        fetchedQuestions = moc.executeFetchRequest(fetchRequest, error: &errorOptional) as! [CDQuestion]
        /*else {
            fetchedQuestions = getQuestions()
        }*/
        
        let fetchedQuestionsCount = UInt32(fetchedQuestions.count)
        
        if (fetchedQuestionsCount <= MAX_NUM_OF_QUESTIONS_IN_A_QUERY) {
            result = fetchedQuestions
        }
        else {
            for _ in 1...MAX_NUM_OF_QUESTIONS_IN_A_QUERY {
                let randomIndex = Int(arc4random_uniform(fetchedQuestionsCount))
                result.append(fetchedQuestions[randomIndex])
            }
        }
        
        return result
    }
    
    
    class func getQuestions(category: CDCategory) -> [CDQuestion] {
        var errorOptional: NSError?
        var result = [CDQuestion]()
        var fetchedQuestions = [CDQuestion]()
        
        let catEntityName: NSString = "CDQuestion"
        let fetchRequest = NSFetchRequest(entityName: catEntityName as String)
        fetchRequest.predicate = NSPredicate(format: "ANY category.id == \(category.id)")
        
        
        fetchedQuestions = moc.executeFetchRequest(fetchRequest, error: &errorOptional) as! [CDQuestion]
        
        let fetchedQuestionsCount = UInt32(fetchedQuestions.count)
        
        if (fetchedQuestionsCount <= MAX_NUM_OF_QUESTIONS_IN_A_QUERY) {
            result = fetchedQuestions
        }
        else {
            for _ in 1...MAX_NUM_OF_QUESTIONS_IN_A_QUERY {
                let randomIndex = Int(arc4random_uniform(fetchedQuestionsCount))
                result.append(fetchedQuestions[randomIndex])
            }
        }

        return result
    }
    
    func readJSONFileFromServer() {
        
        let request = NSURLRequest(URL: NSURL(string: self.serverJSONPath)!)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, urlResponse, error in
            var jsonErrorOptional: NSError?
            let jsonOptional: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonErrorOptional)
            
            if let json = jsonOptional as? Dictionary<String, AnyObject> {
                if let id = json["id"] as AnyObject? as? Int { // Currently in beta 5 there is a bug that forces us to cast to AnyObject? first
                    if let name = json["name"] as AnyObject? as? String {
                        if let email = json["email"] as AnyObject? as? String {
                            //let user = User(id: id, name: name, email: email)
                            //callback(user)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    class func readJSONFileFromLocal(categoryLocalPath: String, questionLocalPath: String) {
        
        readCatJSONFile(categoryLocalPath)
        readQuestionJSONFile(questionLocalPath)
        saveContext(moc)

    }
    
    private class func readCatJSONFile(filePath: String) {
        
        let numberFormatter = NSNumberFormatter()
        var errorOptional: NSError?
        
        let filemanager: NSFileManager = NSFileManager.defaultManager()
        
        if (filemanager.fileExistsAtPath(filePath)) {
            let jsonData = NSData(contentsOfFile: filePath, options: .DataReadingMappedIfSafe, error: &errorOptional)
            let jsonAnyObjects: [[String:AnyObject]]! = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions(0), error: &errorOptional) as! [[String:AnyObject]]
            
            if (errorOptional == nil) {
                for jsonObject in jsonAnyObjects {
                    var id: NSNumber?
                    var parentCatId: NSNumber?
                    var subCatIds: String?
                    var name: String?
                    var desc: String?
                    var imagePath: String?
                    var color: String?
                    var active: NSNumber?
                    var properties: [AnyObject?] = []
                    var parentCat:CDCategory?
                    var subCats: [CDCategory?] = []
                    var newCategory:CDCategory?
                    
                    if let parsedId = string(jsonObject, key: "id") {
                        id = numberFormatter.numberFromString(parsedId)
                    }
                    if let parsedParentCatId = string(jsonObject, key: "parent_category_id") {
                        parentCatId = numberFormatter.numberFromString(parsedParentCatId)
                    }
                    
                    subCatIds = string(jsonObject, key: "sub_category_ids")
                    name = string(jsonObject, key: "category")
                    desc = string(jsonObject, key: "description")
                    imagePath = string(jsonObject, key: "icon")
                    color = string(jsonObject, key: "color")
                    
                    if let parsedActive = string(jsonObject, key: "actflg") {
                        active = numberFormatter.numberFromString(parsedActive)
                    }
                    
                    let catEntityName: NSString = "CDCategory"
                    let fetchRequest = NSFetchRequest(entityName: catEntityName as String)
                    if (parentCatId != nil) {
                        fetchRequest.predicate = NSPredicate(format: "id == \(parentCatId!)")
                        let parentCatsResult = moc.executeFetchRequest(fetchRequest, error: &errorOptional) as! [CDCategory]
                        if (errorOptional == nil && parentCatsResult.count == 0) {
                            parentCat = NSEntityDescription.insertNewObjectForEntityForName("CDCategory", inManagedObjectContext: moc) as? CDCategory
                            parentCat?.id = parentCatId!
                        }
                        else {
                            parentCat = parentCatsResult[0]
                        }
                    }
                    
                    if (subCatIds != "") {
                        let subCatArray = subCatIds!.componentsSeparatedByString(",")
                        fetchRequest.predicate = NSPredicate(format: "id IN %@", subCatArray)
                        let subCatsResult = moc.executeFetchRequest(fetchRequest, error: &errorOptional) as! [CDCategory]
                        if (errorOptional == nil) {
                            for subCatId in subCatArray {
                                var isNotValidSubCat = true
                                for subCat in subCatsResult {
                                    if (subCat.id == subCatId.toInt()) {
                                        isNotValidSubCat = false
                                        break
                                    }
                                }
                                if (isNotValidSubCat) {
                                    let subCatItem = NSEntityDescription.insertNewObjectForEntityForName("CDCategory", inManagedObjectContext: moc) as? CDCategory
                                    subCatItem?.id = subCatId.toInt()!
                                    subCats.append(subCatItem)
                                }
                            }
                        }
                    }
                    
                    properties.append(imagePath)
                    properties.append(name)
                    properties.append(id)
                    properties.append(color)
                    properties.append(desc)
                    properties.append(active)
                    properties.append(parentCat)

                    fetchRequest.predicate = NSPredicate(format: "id == \(id!)")
                    let catsResult = moc.executeFetchRequest(fetchRequest, error: &errorOptional) as! [CDCategory]
                    if (catsResult.count == 0) {
                        newCategory = NSEntityDescription.insertNewObjectForEntityForName("CDCategory", inManagedObjectContext: moc) as? CDCategory
                        newCategory?.isNew = true
                        newCategory?.id = id!
                    }
                    else {
                        newCategory = catsResult[0]
                        newCategory?.isNew = false
                    }
                    
                    newCategory?.setProperties(properties, subCats: subCats)
                    
                }
            }
            
            filemanager.removeItemAtPath(filePath, error: &errorOptional)
        }
        
    }
    
    private class func readQuestionJSONFile(filePath: String) {
        
        let numberFormatter = NSNumberFormatter()
        var errorOptional: NSError?
        
        let filemanager: NSFileManager = NSFileManager.defaultManager()
        
        if (filemanager.fileExistsAtPath(filePath)) {
            let jsonData = NSData(contentsOfFile: filePath, options: .DataReadingMappedIfSafe, error: &errorOptional)
            let jsonAnyObjects: [[String:AnyObject]]! = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions(0), error: &errorOptional) as! [[String:AnyObject]]
            
            if (errorOptional == nil) {
                for jsonObject in jsonAnyObjects {
                    var id: NSNumber?
                    var catId: NSNumber?
                    var question: String?
                    var countryCode: NSNumber?
                    var difficulty: NSNumber?
                    var actflg: NSNumber?
                    var category:CDCategory?
                    var properties: [AnyObject?] = []
                    var newQuestion:CDQuestion?
                    
                    if let parsedId = string(jsonObject, key: "id") {
                        id = numberFormatter.numberFromString(parsedId)
                    }
                    if let parsedCatId = string(jsonObject, key: "category_id") {
                        catId = numberFormatter.numberFromString(parsedCatId)
                    }
                    
                    question = string(jsonObject, key: "question")
                    
                    if let parsedCountryCode = string(jsonObject, key: "countrycode") {
                        countryCode = numberFormatter.numberFromString(parsedCountryCode)
                    }
                    if let parsedDifficulty = string(jsonObject, key: "difficulty") {
                        difficulty = numberFormatter.numberFromString(parsedDifficulty)
                    }
                    if let parsedActflg = string(jsonObject, key: "actflg") {
                        actflg = numberFormatter.numberFromString(parsedActflg)
                    }
                    
                    let catEntityName: NSString = "CDCategory"
                    let catFetchRequest = NSFetchRequest(entityName: catEntityName as String)
                    if (catId != nil) {
                        catFetchRequest.predicate = NSPredicate(format: "id == \(catId!)")
                        let parentCatsResult = moc.executeFetchRequest(catFetchRequest, error: &errorOptional) as! [CDCategory]
                        if (errorOptional == nil && parentCatsResult.count == 0) {
                            category = NSEntityDescription.insertNewObjectForEntityForName("CDCategory", inManagedObjectContext: moc) as? CDCategory
                            category?.id = catId!
                        }
                        else {
                            category = parentCatsResult[0]
                        }
                    }
                    
                    properties.append(actflg)
                    properties.append(difficulty)
                    properties.append(id)
                    properties.append(countryCode)
                    properties.append(question)
                    properties.append(category)
                    
                    let questionEntityName: NSString = "CDQuestion"
                    let questionFetchRequest = NSFetchRequest(entityName: questionEntityName as String)
                    questionFetchRequest.predicate = NSPredicate(format: "id == \(id!)")
                    let questionsResult = moc.executeFetchRequest(questionFetchRequest, error: &errorOptional) as! [CDQuestion]
                    if (errorOptional == nil && questionsResult.count == 0) {
                        newQuestion = NSEntityDescription.insertNewObjectForEntityForName("CDQuestion", inManagedObjectContext: moc) as? CDQuestion
                        newQuestion?.id = id!
                    }
                    else {
                        newQuestion = questionsResult[0]
                    }
                    
                    newQuestion?.setProperties(properties)
                    
                }
            }
            
            filemanager.removeItemAtPath(filePath, error: &errorOptional)
        }
    }
    
    class func array(input: [String:AnyObject], key: String) ->  [AnyObject]? {
        let maybeAny : AnyObject? = input[key]
        return maybeAny >>>= { $0 as? [AnyObject] }
    }
    
    class func dictionary(input: [String:AnyObject], key: String) ->  [String:AnyObject]? {
        return input[key] >>>= { $0 as? [String:AnyObject] }
    }
    
    class func string(input: [String:AnyObject], key: String) -> String? {
        return input[key] >>>= { $0 as? String }
    }
    
    class func number(input: [String:AnyObject], key: String) -> NSNumber? {
        return input[key] >>>= { $0 as? NSNumber }
    }
    
    class func int(input: [String:AnyObject], key: String) -> Int? {
        return number(input,key: key).map { $0.integerValue }
    }
    
    class func bool(input: [String:AnyObject], key: String) -> Bool? {
        return number(input,key: key).map { $0.boolValue }
    }
    
    class func saveContext (moc: NSManagedObjectContext) {
        var error: NSError? = nil
        if moc.hasChanges && !moc.save(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    class func clearContext () {
        let categories = getCategories()
        for category in categories {
            moc.deleteObject(category)
        }
        
        let questions = getQuestions()
        for question in questions {
            moc.deleteObject(question)
        }
    }
}

infix operator  <*> { associativity left precedence 150 }
func <*><A, B>(l: (A -> B)?, r: A?) -> B? {
    if let l1 = l {
        if let r1 = r {
            return l1(r1)
        }
    }
    return nil
}

func flatten<A>(x: A??) -> A? {
    if let y = x { return y }
    return nil
}

infix operator  >>>= {}

func >>>= <A,B> (optional : A?, f : A -> B?) -> B? {
    return flatten(optional.map(f))
}