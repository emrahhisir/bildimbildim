//
//  SummaryResultViewController.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 2/12/15.
//  Copyright (c) 2015 Emrah Hisir. All rights reserved.
//

import Foundation

class SummaryResultViewController: GenericDetailViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let cellIdentifier = "CollectionCell"
    //var cellIndex = 0
    var teamNumber = 0
    var roundNumber = 0
    var cellNumberWithoutHeader = 0
    var headerCellNumber = 0
    let teamFont = UIFont(name: "Helvetica Bold", size: 32.0)
    let roundFont = UIFont(name: "Helvetica Bold", size: 32.0)
    let valueFont = UIFont(name: "Helvetica", size: 30.0)
    var detailVCManager: SplitVCRootViewController?
    var totalCellNumber = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isRoot = true
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.registerNib(UINib(nibName: "SummaryResultHeaderCell", bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        
        nextLabel.text = NSLocalizedString("Next", comment: "Next Button")
        self.view.layer.borderWidth = 2
        self.view.layer.borderColor = UIColor.whiteColor().CGColor
        collectionView.layer.borderWidth = 2
        collectionView.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0) {
            headerCellNumber = teamNumber + 1
            return headerCellNumber
        }
        else {
            cellNumberWithoutHeader = teamNumber*roundNumber + roundNumber
            totalCellNumber = headerCellNumber + cellNumberWithoutHeader
            return cellNumberWithoutHeader
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! SummaryResultHeaderCell
        let cellIndex = indexPath.row
        
        if (indexPath.section == 0) {
            if (cellIndex != 0) {
                cell.label.text = NSLocalizedString("Team", comment: "team") + String(cellIndex)
                cell.label.font = teamFont
            }
        }
        else if (cellIndex % headerCellNumber == 0) {
            cell.label.text = NSLocalizedString("Round", comment: "round") + String(cellIndex/headerCellNumber+1)
            cell.label.font = roundFont
        }
        else {
            let valueCellIndex = cellIndex - cellIndex/headerCellNumber - 1
            let roundIndex = valueCellIndex/teamNumber
            let teamIndex = valueCellIndex - roundIndex*teamNumber
            cell.label.text = String(totalScores[roundIndex][teamIndex])
            cell.label.font = valueFont
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let cellWidth = collectionView.frame.width / CGFloat(headerCellNumber)
        return CGSize(width: cellWidth, height: 50)
    }
    
    /*private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    func collectionView(collectionView: UICollectionView!,
        layout collectionViewLayout: UICollectionViewLayout!,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }*/
    
    func popToRootViewController(animated: Bool) {
        if (detailVCManager == nil) {
            detailVCManager = self.navigationController?.parentViewController?.parentViewController as! SplitVCRootViewController?
        }
        detailVCManager?.popToRootViewController(true)
    }
    
    func setDetailViewController(detailVC: GenericDetailViewController) {
        if (detailVCManager == nil) {
            detailVCManager = self.navigationController?.parentViewController?.parentViewController as! SplitVCRootViewController?
        }
        detailVCManager?.setGenericDetailViewController(detailVC)
    }
    
    @IBAction func pressedBack(sender: AnyObject) {
        popToRootViewController(true)
    }
}