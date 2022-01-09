//
//  FileChecker.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 12/17/14.
//  Copyright (c) 2014 Emrah Hisir. All rights reserved.
//

import Foundation
import CoreData

class FileChecker : NSObject, DownloadControllerDelegate {
    
    let serverPath = "http://memonary.com.s3-website-eu-west-1.amazonaws.com"
    let imageSubPath = "/images/"
    var fileName: String?
    var documentPath: String?
    var downloader: DownloadController?
    var downloadFiles: [String] = []
    var downloadFilesIndex = 0
    var retryIndex = 0
    let maxRetryCount = 3
    var rootViewController: SplitVCRootViewController?
    var categoryLocalPath: String?
    var questionLocalPath: String?
    var categoryDeltaLocalPath: String?
    var questionDeltaLocalPath: String?
    let confFilePath = AppDelegate.applicationDocPath!.path! + "/Conf.plist"
    let fileManager = NSFileManager.defaultManager()
    var confFileDict = [String:String]()
    let deltaFileName = "delta"
    let locale = NSLocale.preferredLanguages().first as! String
    
    override init() {
    }
    
    func startCheckingFiles(moc: NSManagedObjectContext) {
        downloadFiles = [String]()
        documentPath = AppDelegate.applicationDocPath?.path
        
        downloader = DownloadController.sharedInstance()
        downloader?.delegate = self
        
        if (fileManager.fileExistsAtPath(confFilePath) == true) {
            confFileDict = NSDictionary(contentsOfFile: confFilePath) as! [String:String]
        }
        /*else {
            confFileDict = ["category_\(locale).json" : "0", "question_\(locale).json" : "0"]
            (confFileDict as NSDictionary).writeToFile(confFilePath, atomically: true)
        }*/
        
        // Delta Files
        var deltaNum = confFileDict[deltaFileName]
        var deltaNumAsInt = 1
        if (deltaNum != nil && deltaNum != "") {
            deltaNumAsInt = deltaNum!.toInt()! + 1
        }
        
        categoryLocalPath = "\(documentPath!)/category_\(locale).json"
        questionLocalPath = "\(documentPath!)/question_\(locale).json"
        
        categoryDeltaLocalPath = "\(documentPath!)/category_\(deltaFileName)\(deltaNumAsInt)_\(locale).json"
        questionDeltaLocalPath = "\(documentPath!)/question_\(deltaFileName)\(deltaNumAsInt)_\(locale).json"
        
        downloadFiles.append("\(serverPath)/category_\(locale).json")
        downloadFiles.append("\(serverPath)/question_\(locale).json")
        
        downloadFiles.append("\(serverPath)/category_\(deltaFileName)\(deltaNumAsInt)_\(locale).json")
        downloadFiles.append("\(serverPath)/question_\(deltaFileName)\(deltaNumAsInt)_\(locale).json")
        
        var localImagePath = "\(documentPath!)/white-four11.png"
        if (fileManager.fileExistsAtPath(localImagePath) == false) {
            let remoteImagePath = "\(serverPath)\(imageSubPath)white-four11.png"
            downloadFiles.append(remoteImagePath)
        }
        
        localImagePath = "\(documentPath!)/white-doubts.png"
        if (fileManager.fileExistsAtPath(localImagePath) == false) {
            let remoteImagePath = "\(serverPath)\(imageSubPath)white-doubts.png"
            downloadFiles.append(remoteImagePath)
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        DownloadController.download(downloadFiles[0])
        downloadFilesIndex = downloadFilesIndex + 1
        rootViewController = UIApplication.sharedApplication().delegate?.window??.rootViewController as? SplitVCRootViewController
    }
    
    private func downloadDBFiles() {
        let categories = DatabaseManager.getCategories()
        for category in categories {
            var localImagePath = "\(documentPath!)/white-\(category.imagePath).png"
            if (fileManager.fileExistsAtPath(localImagePath) == false) {
                let remoteImagePath = "\(serverPath)\(imageSubPath)white-\(category.imagePath).png"
                downloadFiles.append(remoteImagePath)
            }
            
            // Black icon files
            /*localImagePath = "\(documentPath!)/black-\(category.imagePath).png"
            if (fileManager.fileExistsAtPath(localImagePath) == false) {
                let remoteImagePath = "\(serverPath)\(imageSubPath)black-\(category.imagePath).png"
                downloadFiles.append(remoteImagePath)
            }*/
        }
    }
    
    func dataDownloadFailed(reason: String!) {
        DownloadController.cancel()
        if (retryIndex < maxRetryCount) {
            DownloadController.download(downloadFiles[downloadFilesIndex - 1])
            retryIndex = retryIndex + 1
        }
        else {
            downloadNextFile()
        }
    }
    
    func downloadNextFile() {
        retryIndex = 0
        if (downloadFilesIndex < downloadFiles.count) {
            DownloadController.download(downloadFiles[downloadFilesIndex])
            downloadFilesIndex = downloadFilesIndex + 1
        }
        else {
            DownloadController.close()
            downloader = nil
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            rootViewController?.detailViewController?.removeHUD()
        }
    }
    
    private func updateJSONFileNames(fileName: String) {
        
        switch (downloadFilesIndex) {
        case 1:
            categoryLocalPath = fileName
        case 2:
            questionLocalPath = fileName
        case 3:
            categoryDeltaLocalPath = fileName
        case 4:
            questionDeltaLocalPath = fileName
        default:
            break
        }
    }
    
    func didReceiveData(data: NSData!) {
        if let validFileName = fileName {
            if let validData = downloader?.data {
                let localFileName = "\(documentPath!)/\(validFileName)"
                validData.writeToFile(localFileName, atomically: true)
                if (downloadFilesIndex > 0 && downloadFilesIndex < 5) {
                    updateJSONFileNames(localFileName)
                }
            }
            if (downloadFilesIndex == 2) {
                DatabaseManager.clearContext()
                confFileDict[deltaFileName] = "0"
                DatabaseManager.readJSONFileFromLocal(categoryLocalPath!, questionLocalPath: questionLocalPath!)
                (confFileDict as NSDictionary).writeToFile(confFilePath, atomically: true)
                downloadDBFiles()
            }
            else if(downloadFilesIndex == 4) {
                DatabaseManager.setAllCategoriesOld()
                DatabaseManager.readJSONFileFromLocal(categoryDeltaLocalPath!, questionLocalPath: questionDeltaLocalPath!)
                (confFileDict as NSDictionary).writeToFile(confFilePath, atomically: true)
                downloadDBFiles()
            }
        }
        
        downloadNextFile()
    }
    
    func didReceiveFilename(name: String!) {
        let fileNameArr = name.componentsSeparatedByString(DOWNLOAD_FILE_NAME_DELIMETER)
        var lastModifiedDate = ""
        if (fileNameArr.count == 2) {
            fileName = fileNameArr[0]
            lastModifiedDate = fileNameArr[1]
        }
        if let validFileName = fileName {
            if (validFileName.rangeOfString("json", options: NSStringCompareOptions.CaseInsensitiveSearch)?.startIndex > validFileName.startIndex) {
                if (confFileDict[validFileName] == lastModifiedDate) {
                    DownloadController.cancel()
                    downloadNextFile()
                }
                else {
                    let foundIndex = validFileName.rangeOfString(deltaFileName, options: NSStringCompareOptions.CaseInsensitiveSearch)
                    if let validFoundIndex = foundIndex {
                        confFileDict[deltaFileName] = validFileName.substringWithRange(Range<String.Index>(start: validFoundIndex.endIndex, end: advance(validFoundIndex.endIndex, 1)))
                    }
                    else {
                        confFileDict[validFileName] = lastModifiedDate
                    }
                }
            }
        }
    }
    
    func urlNotValid(urlString: String!) {
        DownloadController.cancel()
        
        let foundIndex = urlString.rangeOfString(".json", options: NSStringCompareOptions.CaseInsensitiveSearch)
        if let validFoundIndex = foundIndex {
            let searchedLocale = urlString.substringWithRange(Range<String.Index>(start: advance(validFoundIndex.startIndex, -2), end: validFoundIndex.startIndex))
            if (searchedLocale != "tr") {
                let replacedString = urlString.stringByReplacingOccurrencesOfString("_\(locale).json", withString: "_tr.json", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
                DownloadController.download(replacedString)
            }
            else {
                downloadNextFile()
            }
        }
        else {
            downloadNextFile()
        }
    }
}