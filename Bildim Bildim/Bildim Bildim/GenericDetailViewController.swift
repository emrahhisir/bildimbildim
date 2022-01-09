//
//  GenericDetailViewController.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 11/12/14.
//  Copyright (c) 2014 Emrah Hisir. All rights reserved.
//

import UIKit
import GoogleMobileAds

class GenericDetailViewController: UIViewController, GADInterstitialDelegate {
    var isRoot: Bool?
    var HUD: MBProgressHUD?
    var interstitial: GADInterstitial?
    
    func removeHUD() {}
    
    func removePopupView() {}
    
    func createAndLoadInterstitial() {
        if (IAPHelper.sharedInstance().productPurchased(IAP_PRODUCT_REMOVEAD) == false) {
            interstitial = GADInterstitial(adUnitID: "ca-app-pub-1796711852238712/7294850184")
            interstitial?.delegate = self
            interstitial?.loadRequest(GADRequestFactory.request())
        }
    }
    
    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        interstitial?.presentFromRootViewController(self)
    }
}