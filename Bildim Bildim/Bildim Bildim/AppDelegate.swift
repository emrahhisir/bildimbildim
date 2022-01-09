//
//  AppDelegate.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 9/26/14.
//  Copyright (c) 2014 Emrah Hisir. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private struct SubStruct {
        static var applicationDocPath: NSURL? = nil
        static var moc: NSManagedObjectContext? = nil
    }
    var productListRetryCount = 0
    
    class var applicationDocPath: NSURL?
        {
        get { return SubStruct.applicationDocPath }
        set { SubStruct.applicationDocPath = newValue }
    }
    
    class var moc: NSManagedObjectContext?
        {
        get { return SubStruct.moc }
        set { SubStruct.moc = newValue }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //parseJSON()
        getProductList()
        SubStruct.applicationDocPath = applicationDocumentsDirectory
        SubStruct.moc = managedObjectContext
        println(applicationDocumentsDirectory.path!)
        FileChecker().startCheckingFiles(managedObjectContext!)
        let settingsProvider = SettingsProvider()
        if (settingsProvider.videoRecordOnOff[settingsProvider.settings["VideoRecordOnOff"]!] == "On") {
            CameraEngine.sharedInstance().startup()
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        let settingsProvider = SettingsProvider()
        if (settingsProvider.videoRecordOnOff[settingsProvider.settings["VideoRecordOnOff"]!] == "On") {
            CameraEngine.sharedInstance().shutdown()
        }
        self.saveContext()
    }

    // MARK: - Store Operations
    /*func createAndGetStoreDir -> String {
    
    }*/
    
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "ANKADev.Bildim_Bildim" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Bildim_Bildim", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: 1,
            NSInferMappingModelAutomaticallyOption: 1,
            NSSQLitePragmasOption: [ "journal_mode": "DELETE"]
        ]
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Bildim_Bildim.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options as [NSObject : AnyObject], error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

    // MARK: - In-App purchases operations
    
    func getProductList () {
        let inAppHelper = IAPHelper.sharedInstance()
    
        if (inAppHelper.isProductRequestNotCompleted()) {
            inAppHelper.requestProductsWithCompletionHandler({ (success, products) -> Void in
                if (success == false) {
                    self.productListRetryCount++
                    if (self.productListRetryCount < 4) {
                        self.getProductList()
                    }
                }
            })
        }
    }
}

