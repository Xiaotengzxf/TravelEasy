//
//  SettingViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/27.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import Toaster
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SettingViewController: UIViewController  {

    @IBOutlet weak var versionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        versionLabel.text = "V\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")"
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
    @IBAction func lookAppVersionInfo(_ sender: AnyObject) {
        #if DEBUG
            //PgyUpdateManager.sharedPgyManager().checkUpdateWithDelegete(self, selector: #selector(SettingViewController.updateMethod(_:)))
        #else
            updateAppVersion()
        #endif
        
    }
    
    // 版本更新
    func updateAppVersion() {
        if let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            let url = "http://itunes.apple.com/lookup?id=1169409476"
            let manager = URLCollection()
            let hud = self.showHUD()
            manager.postRequest(url, params: nil, headers: nil, callback: {[weak self] (json, error) in
                hud.hide(animated: true)
                if let jsonObject = json {
                    if jsonObject["resultCount"].intValue == 1 {
                        if let remoteVersion = jsonObject["results" , 0 , "version"].string {
                            if Float(remoteVersion) > Float(currentVersion) {
                                self?.showVersionAlert(remoteVersion)
                            }else{
                                Toast(text: "当前版本V\(currentVersion)为最新版本！").show()
                            }
                        }
                    }
                }else{
                    Toast(text: "网络异常，请检查网络").show()
                }
            })
        }
    }

    func showVersionAlert(_ version : String) {
        let alert = UIAlertController(title: "版本更新", message: "出差易商旅有新版本V\(version)，您确定要更新吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            UserDefaults.standard.set(version, forKey: "version")
            UserDefaults.standard.synchronize()
        }))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/lookup?id=1169409476")!)
        }))
        self.present(alert, animated: true, completion: {
            
        })
    }
    
    func updateMethod(_ dict : [String : AnyObject]?) {
        if dict != nil && dict?.count > 0 {
            //PgyUpdateManager.sharedPgyManager().checkUpdate()
        }else{
             Toast(text: "当前版本为最新版本！").show()
        }
    }
    
}
