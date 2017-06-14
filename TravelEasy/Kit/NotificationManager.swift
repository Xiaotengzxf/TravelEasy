//
//  NotificationManager.swift
//  TravelEasy
//
//  Created by 张晓飞 on 2016/10/27.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import Foundation
import AudioToolbox

class NotificationManager {
    
    static let installShared = NotificationManager()
    
    func play() {
        let sound = NSUserDefaults.standardUserDefaults().boolForKey("sound")
        let vibrate = NSUserDefaults.standardUserDefaults().boolForKey("vibrate")
        let notificationSound = NSUserDefaults.standardUserDefaults().boolForKey("notificationSound")
        let notificationVibrate = NSUserDefaults.standardUserDefaults().boolForKey("notificationVibrate")
        if notificationVibrate || notificationSound {
            if sound && vibrate {
                
            }else{
                if notificationVibrate && vibrate {
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                }else if notificationSound && sound {
                    if let path = NSBundle(identifier: "com.apple.UIKit")?.pathForResource("sms-received2", ofType: "caf") {
                        var soundID : SystemSoundID = 0
                        let error = AudioServicesCreateSystemSoundID(NSURL(fileURLWithPath: path), &soundID)
                        if error == kAudioServicesNoError {
                            AudioServicesPlayAlertSound(soundID)
                        }
                        
                    }else{
                        let path = "/System/Library/Audio/UISounds/sms-received2.caf"
                        var soundID : SystemSoundID = 0
                        let error = AudioServicesCreateSystemSoundID(NSURL(fileURLWithPath: path), &soundID)
                        if error == kAudioServicesNoError {
                            AudioServicesPlayAlertSound(soundID)
                        }
                    }
                }
            }
        }
    }
}
