//
//  MotionController.swift
//  Bildim Bildim
//
//  Created by Semih Emre ÜNLÜ on 20.12.2014.
//  Copyright (c) 2014 Emrah Hisir. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion


protocol MotionControllerProtocol
{
    func getMotionData(roll: Double)
}

class MotionController: NSObject
{
    var delegate: MotionControllerProtocol?
    
    func getGyroData(motionManager:CMMotionManager)
    {
        motionManager.startDeviceMotionUpdates()
        
        if (motionManager.deviceMotionAvailable)
        {
            motionManager.deviceMotionUpdateInterval = 30.0/60.0 //listener hassasiyeti
            
            var queue = NSOperationQueue.currentQueue()
            
            motionManager.startDeviceMotionUpdatesToQueue(queue, withHandler:
                {
                    deviceManager, error in
                    var attitude = motionManager.deviceMotion.attitude
                    self.delegate?.getMotionData(attitude.roll)
                    
                    if (error != nil)
                    {
                        println("\(error)")
                    }
                    
            })
        }
    }
}
