//
//  SideBarMenuViewController.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 11/5/14.
//  Copyright (c) 2014 Emrah Hisir. All rights reserved.
//

import UIKit

class SideBarMenuViewController: UITableViewController, BBPopupViewDelegate {

    var menuProvider: SideBarMenuProvider? = nil
    var selectedRow: Int?
    var previousSelectedRow = 1
    var detailVCManager: SplitVCRootViewController?
    var detailVC: GenericDetailViewController?
    var settingsPopupView: BBPopupView?
    let settingsProvider = SettingsProvider()
    var storeBBPopupView: BBPopupView?
    let inAppPurchaseHelper = IAPHelper.sharedInstance()
    var removeAdSKProduct: SKProduct?
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var roundTime: UISegmentedControl!
    @IBOutlet weak var bonusTime: UISegmentedControl!
    @IBOutlet weak var soundOpen: UISegmentedControl!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var videoRecord: UISegmentedControl!
    @IBOutlet weak var storePopupView: UIView!
    @IBOutlet weak var removeAdBuyButton: UIButton!
    @IBOutlet weak var removeAdTitle: UILabel!
    @IBOutlet weak var restoreButton: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
        menuProvider = SideBarMenuProvider()
        self.title = "Menu"
        
    }
    
    func initSettingsMenu() {
        roundTime.setTitle(String(settingsProvider.roundTimes[0]), forSegmentAtIndex: 0)
        roundTime.setTitle(String(settingsProvider.roundTimes[1]), forSegmentAtIndex: 1)
        roundTime.setTitle(String(settingsProvider.roundTimes[2]), forSegmentAtIndex: 2)
        roundTime.selectedSegmentIndex = settingsProvider.settings["RoundTime"]!
        
        bonusTime.setTitle(NSLocalizedString(settingsProvider.bonusTimeOnOff[0], comment:"On"), forSegmentAtIndex: 0)
        bonusTime.setTitle(NSLocalizedString(settingsProvider.bonusTimeOnOff[1], comment:"Off"), forSegmentAtIndex: 1)
        bonusTime.selectedSegmentIndex = settingsProvider.settings["BonusTimeOnOff"]!
        
        soundOpen.setTitle(NSLocalizedString(settingsProvider.soundOnOff[0], comment:"On"), forSegmentAtIndex: 0)
        soundOpen.setTitle(NSLocalizedString(settingsProvider.soundOnOff[1], comment:"Off"), forSegmentAtIndex: 1)
        soundOpen.selectedSegmentIndex = settingsProvider.settings["SoundOnOff"]!
        
        videoRecord.setTitle(NSLocalizedString(settingsProvider.videoRecordOnOff[0], comment:"On"), forSegmentAtIndex: 0)
        videoRecord.setTitle(NSLocalizedString(settingsProvider.videoRecordOnOff[1], comment:"Off"), forSegmentAtIndex: 1)
        videoRecord.selectedSegmentIndex = settingsProvider.settings["VideoRecordOnOff"]!
    }
    
    func initRemoveAdSettings() {
        if (inAppPurchaseHelper.isProductRequestNotCompleted() == false) {
            removeAdSKProduct = IAPHelper.sharedInstance().findProduct(IAP_PRODUCT_REMOVEAD)
            let priceFormatter = NSNumberFormatter()
            priceFormatter.locale = removeAdSKProduct!.priceLocale
            priceFormatter.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4
            priceFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
            let formattedPrice = priceFormatter.stringFromNumber(NSNumber(float: removeAdSKProduct!.price.floatValue))
            let underlineAttributedString = NSAttributedString(string: NSLocalizedString("RemoveAdTitle", comment: "Remove Ad Title") + formattedPrice!, attributes: underlineAttribute)
            removeAdTitle.attributedText = underlineAttributedString
            
            if (inAppPurchaseHelper.productPurchased(IAP_PRODUCT_REMOVEAD)) {
                removeAdBuyButton.enabled = false
                removeAdBuyButton.layer.borderColor = UIColor.grayColor().CGColor
            }
            else {
                removeAdBuyButton.enabled = true
                removeAdBuyButton.layer.borderColor = removeAdBuyButton.tintColor?.CGColor
            }
            removeAdBuyButton.layer.cornerRadius = 2.0
            removeAdBuyButton.layer.borderWidth = 1.0
            restoreButton.layer.borderColor = restoreButton.tintColor?.CGColor
            restoreButton.layer.cornerRadius = 2.0
            restoreButton.layer.borderWidth = 2.0
        }
    }
    
    func productBoughtOrRestored(notification: NSNotification) {
        if (inAppPurchaseHelper.productPurchased(IAP_PRODUCT_REMOVEAD)) {
            removeAdBuyButton.enabled = false
            removeAdBuyButton.layer.borderColor = UIColor.grayColor().CGColor
        }
        else {
            removeAdBuyButton.enabled = true
            removeAdBuyButton.layer.borderColor = removeAdBuyButton.tintColor?.CGColor
        }
    }
    
    override func viewDidLoad() {
        configureDetailViewController()
        super.viewDidLoad()
    }
    
    func selectMenu(rowIndex: Int) {
        let defaultSelectedRow = NSIndexPath(forRow: rowIndex, inSection: 0)
        self.tableView.selectRowAtIndexPath(defaultSelectedRow, animated: true, scrollPosition: UITableViewScrollPosition.Top)
    }
    
    override func viewWillAppear(animated: Bool) {
        selectMenu(previousSelectedRow)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "productBoughtOrRestored:", name: IAPHelperProductPurchasedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "productBoughtOrRestored:", name: IAPHelperProductRestoredNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = self.tableView.indexPathForSelectedRow()
            if let setIndexPath = indexPath {
                selectedRow = setIndexPath.row
                if let menu = menuProvider?.menus[selectedRow!] {
                    let controller = (segue.destinationViewController as! UINavigationController).topViewController as UIViewController
                    //controller.menu = menu
                    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    controller.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuProvider?.menus.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        
        let menu = menuProvider?.menus[indexPath.row]
        cell.textLabel?.text = menu?.name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        
        switch (selectedRow!) {
        case 0:
            detailVCManager?.popToRootViewController(true)
            selectMenu(previousSelectedRow)
        case 1:
            previousSelectedRow = selectedRow!
            let newViewController = CategorySelectViewController(nibName: "CategorySelect", bundle: nil)
            newViewController.categories = DatabaseManager.getTopCategories()
            newViewController.awakeFromNib()
            replaceCategorySelectViewController(newViewController)
        case 2:
            previousSelectedRow = selectedRow!
            let newViewController = CategorySelectViewController(nibName: "CategorySelect", bundle: nil)
            newViewController.categories = DatabaseManager.getNewCategories()
            newViewController.isNewCategorySelectVC = true
            newViewController.awakeFromNib()
            replaceCategorySelectViewController(newViewController)
        case 3:
            storeBBPopupView?.removeAnimate()
            storeBBPopupView = nil
            
            let tempViews = NSBundle.mainBundle().loadNibNamed("Settings", owner: self, options: nil)
            settingsPopupView = tempViews[0] as? BBPopupView
            initSettingsMenu()
            settingsPopupView?.setContent(popupView, continueButton: continueButton, ownerViewController: self)
            settingsPopupView?.showInView(detailVCManager!.detailViewController!.view, animated: true)
        case 4:
            settingsPopupView?.removeAnimate()
            settingsPopupView = nil
            
            let tempViews = NSBundle.mainBundle().loadNibNamed("Store", owner: self, options: nil)
            storeBBPopupView = tempViews[0] as? BBPopupView
            initRemoveAdSettings()
            storeBBPopupView?.setContent(storePopupView, continueButton: continueButton, ownerViewController: self)
            storeBBPopupView?.showInView(detailVCManager!.detailViewController!.view, animated: true)
            break
        default:
            settingsPopupView?.removeAnimate()
            settingsPopupView = nil
            storeBBPopupView?.removeAnimate()
            storeBBPopupView = nil
        }
    }
    
    func configureDetailViewController() {
        if (selectedRow == nil) {
            detailVC = ViewController(nibName: "Home", bundle: nil)
            detailVC?.awakeFromNib()
            
            if (detailVCManager == nil) {
                detailVCManager = self.navigationController?.parentViewController?.parentViewController as! SplitVCRootViewController?
            }
            detailVCManager?.setGenericDetailViewController(detailVC!)
        }
    }
    
    @IBAction func enteredSettings(sender:UIButton) {
        settingsPopupView?.removeAnimate()
        settingsProvider.settings["RoundTime"] = roundTime.selectedSegmentIndex
        settingsProvider.settings["BonusTimeOnOff"] = bonusTime.selectedSegmentIndex
        settingsProvider.settings["SoundOnOff"] = soundOpen.selectedSegmentIndex
        settingsProvider.settings["VideoRecordOnOff"] = videoRecord.selectedSegmentIndex
        if (settingsProvider.videoRecordOnOff[settingsProvider.settings["VideoRecordOnOff"]!] == "On") {
            CameraEngine.sharedInstance().startup()
        }
        settingsProvider.writeSettingsToPlistFile()
        selectMenu(previousSelectedRow)
    }
    
    @IBAction func pressedStoreContinueButton(sender: UIButton) {
        storeBBPopupView?.removeAnimate()
        selectMenu(previousSelectedRow)
    }
    
    @IBAction func buyRemoveAdProduct(sender: AnyObject) {
        if let validremoveAdSKProduct = removeAdSKProduct {
            inAppPurchaseHelper.buyProduct(validremoveAdSKProduct)
        }
        else {
            showStoreNoInternetAlert()
        }
    }
    
    @IBAction func restoreTapped(sender: UIButton) {
        inAppPurchaseHelper.restoreCompletedTransactions()
    }
    
    func removePopupView() {
        selectMenu(previousSelectedRow)
    }
    
    func replaceCategorySelectViewController(categorySelectViewController: CategorySelectViewController) {
        if (detailVCManager == nil) {
            detailVCManager = self.navigationController?.parentViewController?.parentViewController as! SplitVCRootViewController?
        }
        detailVCManager?.replaceCategorySelectViewController(categorySelectViewController)
    }
    
    func setDetailViewController(detailVC: GenericDetailViewController) {
        if (detailVCManager == nil) {
            detailVCManager = self.navigationController?.parentViewController?.parentViewController as! SplitVCRootViewController?
        }
        detailVCManager?.setGenericDetailViewController(detailVC)
    }
    
    func showStoreNoInternetAlert() {
        var alert = UIAlertController(title: NSLocalizedString("Alert", comment: "Alert Title"), message: NSLocalizedString("StoreNoConnectionError", comment: "No Internet"), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}