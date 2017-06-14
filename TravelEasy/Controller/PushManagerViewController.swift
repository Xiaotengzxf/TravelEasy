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
            UNUserNotificationCenter.currentNotificationCenter().getNotificationSettingsWithCompletionHandler({[weak self] (settings) in
                if settings.authorizationStatus == .Authorized {
                    self?.pushStateLabel.text = "已开启"
                }else if settings.authorizationStatus == .Denied {
                    self?.pushStateLabel.text = "已关闭"
                    self?.propertyView.hidden = true
                }else{
                    self?.pushStateLabel.text = "待开启"
                    self?.propertyView.hidden = true
                }
            })
        }else{
            if UIApplication.sharedApplication().isRegisteredForRemoteNotifications() {
                pushStateLabel.text = "已开启"
            }else{
                pushStateLabel.text = "待开启"
                propertyView.hidden = true
            }
        }
        let sound = NSUserDefaults.standardUserDefaults().boolForKey("sound")
        let vibrate = NSUserDefaults.standardUserDefaults().boolForKey("vibrate")
        let notificationSound = NSUserDefaults.standardUserDefaults().boolForKey("notificationSound")
        let notificationVibrate = NSUserDefaults.standardUserDefaults().boolForKey("notificationVibrate")
        if notificationSound {
            soundSwitch.on = sound
        }
        if notificationVibrate {
            shakeSwitch.on = vibrate
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeSound(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "notificationSound")
        NSUserDefaults.standardUserDefaults().setBool(soundSwitch.on, forKey: "sound")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    @IBAction func changeShake(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "notificationVibrate")
        NSUserDefaults.standardUserDefaults().setBool(shakeSwitch.on, forKey: "vibrate")
        NSUserDefaults.standardUserDefaults().synchronize()
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
