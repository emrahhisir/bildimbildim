import UIKit

struct SideBarMenu {
  let name: String
  let imageName: String
  
  var image: UIImage {
    return UIImage(named: imageName)!
  }
  
  init(dictionary: [String:String]) {
    let menuText = "Menu-" + dictionary["name"]!
    name = NSLocalizedString(menuText, comment: menuText)
    imageName = dictionary["icon"]!
  }
}

class SideBarMenuProvider {
  private(set) var menus = [SideBarMenu]()
  
  convenience init() {
    self.init(plistNamed: "SideBarMenu")
  }
  
  init(plistNamed: String) {
    self.menus = self.loadMenusFromPListNamed(plistNamed)
  }
  
  private func loadMenusFromPListNamed(plistName: String) -> [SideBarMenu] {
    let path = NSBundle.mainBundle().pathForResource(plistName, ofType: "plist")
    let rawArray = NSArray(contentsOfFile: path!)
    var menuCollection = [SideBarMenu]()
    for rawMenu in rawArray as! [[String:String]] {
      menuCollection.append(SideBarMenu(dictionary: rawMenu))
    }
    return menuCollection
  }
}


