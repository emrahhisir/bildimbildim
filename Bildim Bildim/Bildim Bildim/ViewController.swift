//
//  ViewController.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 9/26/14.
//  Copyright (c) 2014 Emrah Hisir. All rights reserved.
//

import UIKit

class ViewController: GenericDetailViewController {
    
    @IBOutlet weak var howToPlayButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var againstTeamButton: UIButton!
    @IBOutlet weak var quickPlayButton: UIButton!
    @IBOutlet weak var moreGameButton: UIButton!
    var detailVCManager: SplitVCRootViewController?
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var roundSelection: UISegmentedControl!
    @IBOutlet weak var teamSelection: UISegmentedControl!
    var playWithTeamPopupView: BBPopupView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isRoot = true
    }
    
    func hideButtonDetails() {
        howToPlayButton.titleLabel?.hidden = true
    }
    
    override func viewDidLoad() {
        HUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        HUD?.dimBackground = true
        HUD?.labelText = NSLocalizedString("Loading", comment: "Load view")
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        hideButtonDetails()
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.LandscapeLeft
    }
    
    override func select(sender: AnyObject?) {
        var button = sender as! UIButton?
        if let validButton = button {
            
            switch (validButton.tag) {
            case 1:
                if (DatabaseManager.getCategories().count == 0) {
                    showAlert()
                }
                else {
                    let newViewController = CategorySelectViewController(nibName: "CategorySelect", bundle: nil)
                    newViewController.categories = DatabaseManager.getTopCategories()
                    newViewController.awakeFromNib()
                    setDetailViewController(newViewController)
                }
            case 2:
                let tempViews = NSBundle.mainBundle().loadNibNamed("PlayWithTeam", owner: self, options: nil)
                playWithTeamPopupView = tempViews[0] as? BBPopupView
                playWithTeamPopupView?.setContent(popupView, continueButton: continueButton)
                playWithTeamPopupView?.showInView(self.view, animated: true)
                //showInView(self.view, animated: true)
            case 3:
                let developerPages = [NSURL(string: "http://itunes.apple.com/tr/artist/emrah-hisir/id645377074"),
                    NSURL(string: "https://itunes.apple.com/tr/artist/semih-emre-unlu/id933553681")]
                /*let randIndex = Int(arc4random_uniform(2))*/
                UIApplication.sharedApplication().openURL(developerPages[0]!)
            case 4:
                UIApplication.sharedApplication().openURL(NSURL(string: "http://appstore.com/bildim_bildim")!)
            case 5:
                UIApplication.sharedApplication().openURL(NSURL(string: "http://www.mobew.com/bildimbildim")!)
            default:
                break
            }
        }
    }
    
    func setDetailViewController(detailVC: GenericDetailViewController) {
        if (detailVCManager == nil) {
            detailVCManager = self.navigationController?.parentViewController?.parentViewController as! SplitVCRootViewController?
        }
        detailVCManager?.setGenericDetailViewController(detailVC)
    }
    
    @IBAction func clickedContinueForTeamSelection(sender: AnyObject) {
        playWithTeamPopupView?.removeAnimate()
        let selectedTeam = teamSelection.titleForSegmentAtIndex(teamSelection!.selectedSegmentIndex)
        let selectedRound = roundSelection.titleForSegmentAtIndex(roundSelection!.selectedSegmentIndex)
        
        if (DatabaseManager.getCategories().count == 0) {
            showAlert()
        }
        else {
            // Pass the category selection view
            let newViewController = CategorySelectViewController(nibName: "CategorySelect", bundle: nil)
            newViewController.categories = DatabaseManager.getTopCategories()
            newViewController.teamNumber = selectedTeam!.toInt()!
            newViewController.roundNumber = selectedRound!.toInt()!
            newViewController.awakeFromNib()
            setDetailViewController(newViewController)
        }
    }

    override func removeHUD() {
        createAndLoadInterstitial()
        HUD?.hide(true)
        HUD = nil
    }
    
    func showAlert() {
        var alert = UIAlertController(title: NSLocalizedString("Alert", comment: "Alert Title"), message: NSLocalizedString("NoCategoryFound", comment: "Category Download Error"), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Default, handler: { action in
                FileChecker().startCheckingFiles(AppDelegate.moc!)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

