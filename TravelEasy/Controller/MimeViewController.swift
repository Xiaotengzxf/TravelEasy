//
//  MimeViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/26.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import UIViewController_NavigationBar
import JLToast
import SwiftyJSON

class MimeViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = UIColor.hexStringToColor(NAVIGATIONBARTINTCOLOR)
        self.navigationBar.translucent = false
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Top, barMetrics: .Default)
        // Do any additional setup after loading the view.
        let info = NSUserDefaults.standardUserDefaults().objectForKey("info")
        if info != nil {
            let json = JSON(info!)
            nameLabel.text = json["EmployeeName"].string
            departmentLabel.text = json["DeptName"].string
            companyLabel.text = json["CorpName"].string
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func hasCustomNavigationBar() -> Bool {
        return true
    }
    
    override func prefersNavigationBarHidden() -> Bool {
        return true
    }
    
    @IBAction func modifyPwd(sender: AnyObject) {
        self.performSegueWithIdentifier("toModifyPwd", sender: self)
    }
    @IBAction func setAccount(sender: AnyObject) {
        self.performSegueWithIdentifier("toSetting", sender: self)
    }
    @IBAction func exitAccount(sender: AnyObject) {
        let info = NSUserDefaults.standardUserDefaults().objectForKey("info")
        if info == nil {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("Navigation")
            self.presentViewController(controller!, animated: true, completion: { 
                
            })
        }else{
            let alert = UIAlertController(title: "提示", message: "您确定退出登录？", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (action) in
                
            }))
            alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: {[weak self] (action) in
                let manager = URLCollection()
                let hud = self!.showHUD()
                if let token = manager.validateToken(){
                    manager.postRequest(manager.loginOut, params: nil, headers: ["Token" : token], callback: { (json, error) in
                        hud.hideAnimated(true)
                        if let jsonObject = json {
                            if jsonObject["Code"].int == 0 {
                                NSUserDefaults.standardUserDefaults().removeObjectForKey("info")
                                NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "approvalCount")
                                NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "authorizeCount")
                                NSUserDefaults.standardUserDefaults().synchronize()
                                if let controller = self?.storyboard?.instantiateViewControllerWithIdentifier("Navigation") {
                                    self?.view.window?.rootViewController = controller
                                }
                                JPUSHService.setAlias("", callbackSelector: nil, object: nil)
                            }else{
                                if let message = jsonObject["Message"].string {
                                    JLToast.makeText(message).show()
                                }
                            }
                        }else{
                            JLToast.makeText("网络故障，请检查网络").show()
                        }
                    })
                }
            }))
            self.presentViewController(alert, animated: true, completion: { 
                
            })
        }
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
