import UIKit


class SettingsProvider {
    private let filePath: String
    var settings = [String:Int]()
    let roundTimes = [60, 90, 120]
    let bonusTimeOnOff = ["On", "Off"]
    let soundOnOff = ["On", "Off"]
    let videoRecordOnOff = ["On", "Off"]
    
    init() {
        if let validPath = AppDelegate.applicationDocPath!.path {
            filePath = "\(validPath)/BBSettings.plist"
        }
        else {
            filePath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString as String
        }
        let fileManager = NSFileManager.defaultManager()
        if (fileManager.fileExistsAtPath(filePath) == false) {
            let sourcePath = NSBundle.mainBundle().pathForResource("BBSettings", ofType: "plist")
            fileManager.copyItemAtPath(sourcePath!, toPath: filePath, error: nil)
        }
        self.settings = self.loadSettingsFromPListNamed()
    }
  
    private func loadSettingsFromPListNamed() -> [String:Int] {
        var result = [String:Int]()
        let rawArray = NSDictionary(contentsOfFile: filePath)
        for rawValue in rawArray! {
            result[rawValue.key as! String] = rawValue.value as? Int
        }
        return result
    }
    
    func writeSettingsToPlistFile() {
        let tempSettings = NSDictionary(dictionary: settings)
        tempSettings.writeToFile(filePath, atomically: true)
    }
}


