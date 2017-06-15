//
//  PushManagerViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/27.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import UserNotifications

class PushManagerViewController: UIViewController {

    @IBOutlet weak var pushStateLabel: UILabel!
    @IBOutlet weak var propertyView: UIView!
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var shakeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {[weak self] (settings) in
                if settings.authorizationStatus == .authorized {
                    self?.pushStateLabel.text = "已开启"
                }else if settings.authorizationStatus == .denied {
                    self?.pushStateLabel.text = "已关闭"
                    self?.propertyView.isHidden = true
                }else{
                    self?.pushStateLabel.text = "待开启"
                    self?.propertyView.isHidden = true
                }
            })
        }else{
            if UIApplication.shared.isRegisteredForRemoteNotifications {
                pushStateLabel.text = "已开启"
            }else{
                pushStateLabel.text = "待开启"
                propertyView.isHidden = true
            }
        }
        let sound = UserDefaults.standard.bool(forKey: "sound")
        let vibrate = UserDefaults.standard.bool(forKey: "vibrate")
        let notificationSound = UserDefaults.standard.bool(forKey: "notificationSound")
        let notificationVibrate = UserDefaults.standard.bool(forKey: "notificationVibrate")
        if notificationSound {
            soundSwitch.isOn = sound
        }
        if notificationVibrate {
            shakeSwitch.isOn = vibrate
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeSound(_ sender: AnyObject) {
        UserDefaults.standard.set(true, forKey: "notificationSound")
        UserDefaults.standard.set(soundSwitch.isOn, forKey: "sound")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func changeShake(_ sender: AnyObject) {
        UserDefaults.standard.set(true, forKey: "notificationVibrate")
        UserDefaults.standard.set(shakeSwitch.isOn, forKey: "vibrate")
        UserDefaults.standard.synchronize()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
