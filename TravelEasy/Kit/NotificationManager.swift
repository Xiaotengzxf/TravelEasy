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
        let sound = UserDefaults.standard.bool(forKey: "sound")
        let vibrate = UserDefaults.standard.bool(forKey: "vibrate")
        let notificationSound = UserDefaults.standard.bool(forKey: "notificationSound")
        let notificationVibrate = UserDefaults.standard.bool(forKey: "notificationVibrate")
        if notificationVibrate || notificationSound {
            if sound && vibrate {
                
            }else{
                if notificationVibrate && vibrate {
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                }else if notificationSound && sound {
                    if let path = Bundle(identifier: "com.apple.UIKit")?.path(forResource: "sms-received2", ofType: "caf") {
                        var soundID : SystemSoundID = 0
                        let error = AudioServicesCreateSystemSoundID(URL(fileURLWithPath: path) as CFURL, &soundID)
                        if error == kAudioServicesNoError {
                            AudioServicesPlayAlertSound(soundID)
                        }
                        
                    }else{
                        let path = "/System/Library/Audio/UISounds/sms-received2.caf"
                        var soundID : SystemSoundID = 0
                        let error = AudioServicesCreateSystemSoundID(URL(fileURLWithPath: path) as CFURL, &soundID)
                        if error == kAudioServicesNoError {
                            AudioServicesPlayAlertSound(soundID)
                        }
                    }
                }
            }
        }
    }
}
