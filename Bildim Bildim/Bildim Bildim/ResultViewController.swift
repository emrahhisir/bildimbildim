//
//  ResultViewController.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 1/17/15.
//  Copyright (c) 2015 Emrah Hisir. All rights reserved.
//

import Foundation
import AudioToolbox

class ResultViewController: GenericDetailViewController {

    var questionLabels: NSMutableArray = NSMutableArray()
    var keyOfAnswers = [String]()
    var valueOfAnswers = [Bool]()
    var answerIndex = 0
    var didSetupConstraints: Bool = true
    var playViewController: PlayViewController?
    var scrollviewHeightConstraints: NSArray?
    var scoreAsInt = 0
    var detailVCManager: SplitVCRootViewController?
    var timer: NSTimer?
    var teamIndex = -1
    var roundIndex = -1
    var isFinished = false
    var isSoundOn = true
    
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
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
        createAndLoadInterstitial()
        super.viewDidLoad()
        hideNextButton()
        nextLabel.text = NSLocalizedString("Next", comment: "Next Button")
        self.view.layer.borderWidth = 2
        self.view.layer.borderColor = UIColor.whiteColor().CGColor
        scrollView.layer.borderWidth = 2
        scrollView.layer.borderColor = UIColor.whiteColor().CGColor
        UIApplication.sharedApplication().idleTimerDisabled = false
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "showAnswer", userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        if (timer == nil) {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "showAnswer", userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let validTimer = timer {
            validTimer.invalidate()
        }
        timer = nil
    }
    
    func showAnswer() {
    
        if (answerIndex < keyOfAnswers.count) {
            let customFont = UIFont(name: "Helvetica Bold", size: 20.0)
            var questionLabel = UILabel()
            questionLabel.textAlignment = NSTextAlignment.Center
            
            questionLabel.text = keyOfAnswers[answerIndex]
            questionLabel.font = customFont;
            questionLabel.numberOfLines = 2;
            questionLabel.baselineAdjustment = UIBaselineAdjustment.AlignBaselines // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
            questionLabel.lineBreakMode = NSLineBreakMode.ByClipping
            questionLabel.adjustsFontSizeToFitWidth = true
            questionLabel.minimumScaleFactor = 10.0/12.0
            questionLabel.clipsToBounds = true
            questionLabel.backgroundColor = UIColor.clearColor()
            questionLabel.textAlignment = NSTextAlignment.Center
            
            if (valueOfAnswers[answerIndex]) {
                questionLabel.textColor = UIColor.whiteColor()
                scoreAsInt = scoreAsInt + 1
                if (isSoundOn) {
                    AudioServicesPlaySystemSound(1057)
                }
            }
            else {
                questionLabel.textColor = UIColor.redColor()
            }
            questionLabels.addObject(questionLabel)
            containerView.addSubview(questionLabel)
            
            answerIndex++
            self.view.setNeedsUpdateConstraints()
        }
        else {
            if let validTimer = timer {
                validTimer.invalidate()
            }
            timer = nil
            if (teamIndex != -1) {
                totalScores[roundIndex][teamIndex] = scoreAsInt
            }
            showNextButton()
        }
    }
    
    override func updateViewConstraints() {
        if (questionLabels.count > 0) {
            
            score.text = String(scoreAsInt)
            
            let firstQuestionLabel = questionLabels.firstObject as! UILabel
            let scrollviewHeight = CGFloat((questionLabels.count))*(firstQuestionLabel.frame.height + 5) + 20
            if (scrollviewHeight > containerView.frame.height) {
                if let validScrollviewHeightConstraints = scrollviewHeightConstraints {
                    containerView.removeConstraints(validScrollviewHeightConstraints as [AnyObject])
                }
                scrollviewHeightConstraints = containerView.autoSetDimensionsToSize(CGSizeMake(self.view.frame.width, scrollviewHeight))
                scrollView.contentOffset = CGPointMake(0, scrollviewHeight)
            }
        
            containerView.addConstraint(NSLayoutConstraint(item: firstQuestionLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
            firstQuestionLabel.autoPinEdgeToSuperviewEdge(ALEdge.Top, withInset: 20.0)
            var previousQuestionLabel = firstQuestionLabel
            var index = 1
            for ; index < questionLabels.count; index++ {
                let questionLabel: UILabel = questionLabels.objectAtIndex(index) as! UILabel
                questionLabel.autoPinEdge(ALEdge.Top, toEdge: ALEdge.Bottom, ofView: previousQuestionLabel, withOffset: 5.0)
                containerView.addConstraint(NSLayoutConstraint(item: questionLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: containerView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
                previousQuestionLabel = questionLabel
            }
        }
        super.updateViewConstraints()
    }
    
    func popToTopViewController(animated: Bool) {
        if (detailVCManager == nil) {
            detailVCManager = self.navigationController?.parentViewController?.parentViewController as! SplitVCRootViewController?
        }
        detailVCManager?.popToTopViewController(animated)
    }
    
    func popToRootViewController(animated: Bool) {
        if (detailVCManager == nil) {
            detailVCManager = self.navigationController?.parentViewController?.parentViewController as! SplitVCRootViewController?
        }
        detailVCManager?.popToRootViewController(animated)
    }
    
    func popToTopViewControllerWithSidebar(animated: Bool) {
        if (detailVCManager == nil) {
            detailVCManager = self.navigationController?.parentViewController?.parentViewController as! SplitVCRootViewController?
        }
        detailVCManager?.popToTopViewControllerWithSidebar(animated)
    }
    
    func setDetailViewController(detailVC: GenericDetailViewController) {
        if (detailVCManager == nil) {
            detailVCManager = self.navigationController?.parentViewController?.parentViewController as! SplitVCRootViewController?
        }
        detailVCManager?.setGenericDetailViewController(detailVC)
    }
    
    @IBAction func pressedBack(sender: AnyObject) {
        if (teamIndex == -1) {
            popToRootViewController(true)
        }
        else if (isFinished) {
            // Pass to summary screen.
            let newViewController = SummaryResultViewController(nibName: "SummaryResult", bundle: nil)
            newViewController.awakeFromNib()
            newViewController.teamNumber = teamIndex + 1
            newViewController.roundNumber = roundIndex + 1
            setDetailViewController(newViewController)
        }
        else {
            popToTopViewController(true)
        }
    }
    
    func hideNextButton() {
        nextLabel.hidden = true
        nextButton.hidden = true
    }
    
    func showNextButton() {
        nextLabel.hidden = false
        nextButton.hidden = false
        showVideoRecordAlertMessage()
    }
    
    func showVideoRecordAlertMessage() {
        var alert = UIAlertController(title: NSLocalizedString("Video", comment: "Video Record Title"), message: NSLocalizedString("VideoRecordMessage", comment: "Video Record Info Message"), preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}