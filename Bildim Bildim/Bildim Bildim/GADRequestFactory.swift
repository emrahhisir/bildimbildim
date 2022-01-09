//
//  GADRequestFactory.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 3/4/15.
//  Copyright (c) 2015 Emrah Hisir. All rights reserved.
//

import Foundation
import GoogleMobileAds

class GADRequestFactory {

    class func request() -> GADRequest {
        var request = GADRequest()
        request.testDevices = ["bcdc0c7866417b2910dc4e43b1b99b04"]
        
        // static location (Batikent)
        //request.setLocationWithLatitude(CGFloat(39.9937026525807), longitude: CGFloat(32.7233115298602), accuracy: CGFloat(65.0))
        
        var userBirtday = NSDateComponents()
        userBirtday.year = 2010
        userBirtday.month = 9
        userBirtday.day = 12
        request.birthday = userBirtday.date
    
        return request;
    }
}