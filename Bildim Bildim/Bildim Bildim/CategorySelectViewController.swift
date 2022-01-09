//
//  CategorySelectViewController.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 10/30/14.
//  Copyright (c) 2014 Emrah Hisir. All rights reserved.
//

import UIKit

// MARK: - Gradient Colors
let GRADIENT_COLOR1_1 = UIColor(red: 1.0, green: 0.39, blue: 0.0, alpha: 0.75)
let GRADIENT_COLOR1_2 = UIColor(red: 0.9, green: 0.56, blue: 0.35, alpha: 0.75)
let GRADIENT_COLOR2_1 = UIColor(red: 0.44, green: 0.81, blue: 0.16, alpha: 0.75)
let GRADIENT_COLOR2_2 = UIColor(red: 0.64, green: 0.88, blue: 0.46, alpha: 0.75)

class CategorySelectViewController: GenericDetailViewController {
    
    @IBOutlet weak var containerView: UIView!
    var categoryButtons: NSMutableArray = NSMutableArray()
    var categories: [CDCategory]? = nil
    var didSetupConstraints: Bool = false
    var didGradientHandled: Bool = false
    var buttonSize: CGFloat = 0.0
    var teamNumber = 0
    var roundNumber = 0
    var detailVCManager: SplitVCRootViewController?
    var isRootCategorySelectVC: Bool = true
    var isNewCategorySelectVC: Bool = false
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //createButtons()
        self.view.setNeedsUpdateConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func viewWillAppear(animated: Bool) {
        if (isRootCategorySelectVC) {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        else {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.LandscapeLeft.rawValue |
            UIInterfaceOrientation.LandscapeRight.rawValue
    }
    
    // MARK: - Button Layout
    func createButtons() {
        var index = -1
        let fileManager = NSFileManager.defaultManager()
        buttonSize = self.view.frame.width/2.0
        
        // Select All Button
        var button = UIButton()
        var imagePath = "\(AppDelegate.applicationDocPath!.path!)/white-four11.png"
        if fileManager.fileExistsAtPath(imagePath) {
            button.setImage(UIImage(contentsOfFile: imagePath), forState: UIControlState.Normal)
            button.centerButtonAndImageWithSpacing(buttonSize)
        }
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.setTitle(NSLocalizedString("SelectAllCategory", comment: "SelectAll"), forState: UIControlState.Normal)
        button.tag = index
        button.addTarget(self, action: "selectCategory:", forControlEvents: UIControlEvents.TouchUpInside)
        containerView.addSubview(button)
        categoryButtons.addObject(button)
        index++
        
        for category in categories! {
            button = UIButton()
            imagePath = "\(AppDelegate.applicationDocPath!.path!)/white-\(category.imagePath).png"
            if fileManager.fileExistsAtPath(imagePath) {
                button.setImage(UIImage(contentsOfFile: imagePath), forState: UIControlState.Normal)
                button.centerButtonAndImageWithSpacing(buttonSize)
            }
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.setTitle(category.name, forState: UIControlState.Normal)
            button.tag = index
            button.addTarget(self, action: "selectCategory:", forControlEvents: UIControlEvents.TouchUpInside)
            containerView.addSubview(button)
            categoryButtons.addObject(button)
            index++
        }
        
        // Random Button
        button = UIButton()
        imagePath = "\(AppDelegate.applicationDocPath!.path!)/white-doubts.png"
        if fileManager.fileExistsAtPath(imagePath) {
            button.setImage(UIImage(contentsOfFile: imagePath), forState: UIControlState.Normal)
            button.centerButtonAndImageWithSpacing(buttonSize)
        }
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.setTitle(NSLocalizedString("RandomCategory", comment: "Random"), forState: UIControlState.Normal)
        button.tag = index
        button.addTarget(self, action: "selectCategory:", forControlEvents: UIControlEvents.TouchUpInside)
        containerView.addSubview(button)
        categoryButtons.addObject(button)
    }
    
    override func viewDidLayoutSubviews() {
        if (didGradientHandled == false &&
            (categoryButtons.firstObject as! UIButton).bounds.width > 0) {
                var index = 0
                var layer: CAGradientLayer?
                
                for ; index < categoryButtons.count; index++ {
                    let button = categoryButtons.objectAtIndex(index) as! UIButton
                    button.layer.masksToBounds = true
                    button.backgroundColor = UIColor.clearColor()
                    if (index%4 == 1 || index%4 == 2) {
                        layer = CAGradientLayer.colorGradientLayer(GRADIENT_COLOR2_1.CGColor, color2: GRADIENT_COLOR2_2.CGColor)
                    }
                    else {
                        layer = CAGradientLayer.colorGradientLayer(GRADIENT_COLOR1_1.CGColor, color2: GRADIENT_COLOR1_2.CGColor)
                    }
                    
                    layer?.frame = button.layer.bounds
                    button.layer.insertSublayer(layer, atIndex: 0)
                    
                    didGradientHandled = true
                }
        }
        super.viewDidLayoutSubviews()
    }
    
    override func updateViewConstraints() {
        if (didSetupConstraints == false) {
            
            createButtons()
            
            // Apply a fixed height of 50 pt to two views at once, and a fixed height of 70 pt to another two views
            //let buttonSize = self.view.frame.width/2.0
            categoryButtons.autoSetViewsDimension(ALDimension.Height, toSize: buttonSize)
            categoryButtons.autoSetViewsDimension(ALDimension.Width, toSize: buttonSize)
            let scrollviewHeight = ceil(CGFloat((Double)(categoryButtons.count)/2.0))*buttonSize
            containerView.autoSetDimensionsToSize(CGSizeMake(self.view.frame.width, scrollviewHeight))
            let firstButton: UIButton = categoryButtons.firstObject as! UIButton
            
            firstButton.autoPinEdgeToSuperviewEdge(ALEdge.Left)
            var previousButton: UIButton? = nil
            var twoPreviousButton: UIButton? = nil
            var index = 0
            for ; index < categoryButtons.count; index++ {
                let button: UIButton = categoryButtons.objectAtIndex(index) as! UIButton
                
                if (index == 1) {
                    button.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Right, ofView: previousButton!)
                }
                else if (index%2 == 1) {
                    button.autoPinEdge(ALEdge.Left, toEdge: ALEdge.Right, ofView: previousButton!)
                    button.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: twoPreviousButton!)
                }
                else if (twoPreviousButton != nil) {
                    button.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: twoPreviousButton!)
                }
                twoPreviousButton = previousButton
                previousButton = button
            }
            self.didSetupConstraints = true
        }
        super.updateViewConstraints()
    }
    
    func selectCategory(sender:UIButton!) {
        if (sender.titleLabel?.text == NSLocalizedString("SelectAllCategory", comment: "SelectAll")) {
            let newViewController = PlayViewController(nibName: "Play", bundle: nil)
            newViewController.awakeFromNib()
            newViewController.questions = DatabaseManager.getQuestions(categories)
            if (categories![0].parentCat == nil || isNewCategorySelectVC) {
                newViewController.categoryTitle = sender.titleLabel!.text!
            }
            else {
                newViewController.categoryTitle = categories![0].parentCat!.name
            }
            newViewController.teamNumber = teamNumber
            newViewController.roundNumber = roundNumber
            UIApplication.sharedApplication().idleTimerDisabled = true
            setDetailViewController(newViewController)
        }
        else {
            var selectedCatIndex = 0
            if (sender.titleLabel?.text == NSLocalizedString("RandomCategory", comment: "Random")) {
                if let catCount = categories?.count {
                    selectedCatIndex = Int(arc4random_uniform(UInt32(catCount)))
                }
            }
            else {
                selectedCatIndex = sender.tag
            }
            
            let selectedCategory = categories?[selectedCatIndex]
            if (selectedCategory?.subCats.count != 0) {
                let newViewController = CategorySelectViewController(nibName: "CategorySelect", bundle: nil)
                newViewController.categories = selectedCategory?.subCats.allObjects as? [CDCategory]
                newViewController.awakeFromNib()
                newViewController.isRootCategorySelectVC = false
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.navigationItem.title = selectedCategory?.name
                setDetailViewController(newViewController)
            }
            else if (selectedCategory != nil){
                let questions = DatabaseManager.getQuestions(selectedCategory!)
                
                if (questions.count == 0) {
                    showAlert()
                }
                else {
                    var categoryTitle = selectedCategory?.name
                    let newViewController = PlayViewController(nibName: "Play", bundle: nil)
                    newViewController.awakeFromNib()
                    newViewController.questions = questions
                    newViewController.categoryTitle = categoryTitle!
                    newViewController.teamNumber = teamNumber
                    newViewController.roundNumber = roundNumber
                    UIApplication.sharedApplication().idleTimerDisabled = true
                    setDetailViewController(newViewController)
                }
            }
        }
    }
    
    func setDetailViewController(newViewController: GenericDetailViewController) {
        if (detailVCManager == nil) {
            detailVCManager = self.navigationController?.parentViewController?.parentViewController as! SplitVCRootViewController?
        }
        detailVCManager?.setGenericDetailViewController(newViewController)
    }
    
    func showAlert() {
        var alert = UIAlertController(title: NSLocalizedString("Alert", comment: "Alert Title"), message: NSLocalizedString("NoQuestionError", comment: "Empty Category Error"), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}