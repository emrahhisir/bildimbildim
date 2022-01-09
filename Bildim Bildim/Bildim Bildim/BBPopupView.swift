//
//  BBPopupView.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 12/15/14.
//  Copyright (c) 2014 Emrah Hisir. All rights reserved.
//

import Foundation
import UIKit

protocol BBPopupViewDelegate {
    func removePopupView()
}

class BBPopupView: UIView {
    var popupView: UIView!
    var continueButton: UIButton!
    var isNotInitCompleted: Bool = true
    var ownerViewController: BBPopupViewDelegate?
    
    func setContent(popupView: UIView!, continueButton: UIButton!, ownerViewController: BBPopupViewDelegate? = nil) {
        self.popupView = popupView
        self.continueButton = continueButton
        self.ownerViewController = ownerViewController
        
        if (isNotInitCompleted) {
            self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
            self.popupView.layer.borderWidth = 4.0
            self.popupView.layer.borderColor = UIColor(red: 0.59765625, green: 0.59765625, blue: 0.59765625, alpha: 1.0).CGColor
            self.popupView.layer.cornerRadius = 5
            self.popupView.layer.shadowOpacity = 0.8
            self.popupView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
            continueButton.backgroundColor = UIColor(red: 0.18, green: 0.8, blue: 0.35, alpha: 0.75)
            createCustomCloseButton()
            
            isNotInitCompleted = false
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func showAnimate() {
        self.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.alpha = 0
        
        UIView.animateWithDuration(0.25, animations: {
            self.alpha = 1
            self.transform = CGAffineTransformMakeScale(1, 1)
        })
    }
    
    func removeAnimate() {
        UIView.animateWithDuration(NSTimeInterval(0.25), animations: {
            self.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.alpha = 0.0
            }, completion: { (finished: Bool) in
                if (finished) {
                    self.removeFromSuperview()
                }
        })
        
        if let validOwnerViewController = ownerViewController {
            validOwnerViewController.removePopupView()
        }
    }
    
    func closePopup(sender: AnyObject) {
        removeAnimate()
    }
    
    func showInView(aView: UIView, animated: Bool)
    {
        self.frame = aView.frame
        self.bounds = aView.bounds
        
        aView.addSubview(self)
        aView.bringSubviewToFront(self)
        if (animated) {
            self.showAnimate()
        }
    }
    
    func createCustomCloseButton() {
        let button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        var buttonSize = popupView.frame.width/10
        
        let popupFrame = popupView.frame
        if (popupView.frame.width > popupView.frame.height) {
            buttonSize = popupView.frame.height/10
        }
        
        button.frame = CGRectMake(popupView.frame.minX - buttonSize/2, popupView.frame.minY - buttonSize/2, buttonSize, buttonSize)
        button.setBackgroundImage(UIImage(named: "close.png"), forState: UIControlState.Normal)
        button.addTarget(self, action: Selector("removeAnimate"), forControlEvents: UIControlEvents.TouchUpInside)
        button.backgroundColor = UIColor.clearColor()
        self.addSubview(button)
    }
}