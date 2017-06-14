//
//  SettingViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/27.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import JLToast

class SettingViewController: UIViewController  {

    @IBOutlet weak var versionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        versionLabel.text = "V\(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String ?? "1.0")"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // 版本升级
    @IBAction func lookAppVersionInfo(sender: AnyObject) {
        #if DEBUG
            //PgyUpdateManager.sharedPgyManager().checkUpdateWithDelegete(self, selector: #selector(SettingViewController.updateMethod(_:)))
        #else
            updateAppVersion()
        #endif
        
    }
    
    // 版本更新
    func updateAppVersion() {
        if let currentVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
            let url = "http://itunes.apple.com/lookup?id=1169409476"
            let manager = URLCollection()
            let hud = self.showHUD()
            manager.postRequest(url, params: nil, headers: nil, callback: {[weak self] (json, error) in
                hud.hideAnimated(true)
                if let jsonObject = json {
                    if jsonObject["resultCount"].intValue == 1 {
                        if let remoteVersion = jsonObject["results" , 0 , "version"].string {
                            if Float(remoteVersion) > Float(currentVersion) {
                                self?.showVersionAlert(remoteVersion)
                            }else{
                                JLToast.makeText("当前版本V\(currentVersion)为最新版本！").show()
                            }
                        }
                    }
                }else{
                    JLToast.makeText("网络异常，请检查网络").show()
                }
            })
        }
    }

    func showVersionAlert(version : String) {
        let alert = UIAlertController(title: "版本更新", message: "出差易商旅有新版本V\(version)，您确定要更新吗？", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (action) in
            NSUserDefaults.standardUserDefaults().setObject(version, forKey: "version")
            NSUserDefaults.standardUserDefaults().synchronize()
        }))
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (action) in
            UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/lookup?id=1169409476")!)
        }))
        self.presentViewController(alert, animated: true, completion: {
            
        })
    }
    
    func updateMethod(dict : [String : AnyObject]?) {
        if dict != nil && dict?.count > 0 {
            //PgyUpdateManager.sharedPgyManager().checkUpdate()
        }else{
             JLToast.makeText("当前版本为最新版本！").show()
        }
    }
    
}
