//
//  LoginViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/8/12.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import UIViewController_NavigationBar
import Toaster

class LoginViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField! // 用户名
    @IBOutlet weak var pwdTextField: UITextField! // 密码
    @IBOutlet weak var loginButton: UIButton! // 登录按钮
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barTintColor = UIColor.hexStringToColor(BACKGROUNDCOLOR)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.setBackgroundImage(UIImage(), for: .top, barMetrics: .default)
        //nameTextField.rightView = rightButton(1)
        //pwdTextField.rightView = rightButton(2)
        //nameTextField.rightViewMode = .WhileEditing
        //pwdTextField.rightViewMode = .WhileEditing
        nameTextField.text = UserDefaults.standard.object(forKey: "loginName") as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func hasCustomNavigationBar() -> Bool {
        return true
    }
    
    /**
     输入框右按钮
     
     - parameter tag: 标签
     
     - returns: 右按钮
     */
    func rightButton(_ tag : Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = tag
        button.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)
        button.setBackgroundImage(UIImage(named: "login_img_del_un"), for: UIControlState())
        button.setBackgroundImage(UIImage(named: "login_img_del_pr"), for: .highlighted)
        button.addTarget(self, action: #selector(LoginViewController.clearText(_:)), for: .touchUpInside)
        return button
    }
    
    /**
     清空文本
     
     - parameter sender: 按钮
     */
    func clearText(_ sender : AnyObject!) {
        if let button = sender as? UIButton {
            let tag = button.tag
            if tag == 1 {
                nameTextField.text = nil
            }else{
                pwdTextField.text = nil
            }
        }
    }

    /**
     登录
     
     - parameter sender: 按钮
     */
    @IBAction func login(_ sender: AnyObject) {
        nameTextField.resignFirstResponder()
        pwdTextField.resignFirstResponder()
        let name = nameTextField.text
        let pwd = pwdTextField.text
        if name?.characters.count == 0 {
            Toast(text: "请输入帐号").show()
        }else if pwd?.characters.count == 0 {
            Toast(text: "请输入密码").show()
        }else{
            let hud = showHUD()
            let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            let deviceId = UIDevice.current.identifierForVendor!.uuidString
            let sysVersion = UIDevice.current.systemVersion
            let manager = URLCollection()
            manager.postRequest(manager.login, params: ["LoginName" : name ?? "" , "Password" : pwd ?? "" , "AppVersion" : appVersion , "DeviceType" : modelName , "DeviceId" : deviceId , "OSVersion" : sysVersion], headers: nil, callback: {[weak self] (json, error) in
                hud.hide(animated: true)
                if let jsonObject = json {
                    if jsonObject["Code"].int == 0 {
                        let controller = self?.storyboard?.instantiateViewController(withIdentifier: "TabBarController")
                        self?.view.window?.rootViewController = controller
                        UserDefaults.standard.set(jsonObject.object, forKey: "info")
                        UserDefaults.standard.set(self!.nameTextField.text, forKey: "loginName")
                        UserDefaults.standard.synchronize()
                        JPUSHService.setAlias("\(jsonObject["EmployeeId"].intValue)", callbackSelector: nil, object: nil)
                        self?.loadApprovalAndAuthorizeCount()
                    }else{
                        if let message = jsonObject["Message"].string {
                            Toast(text: message).show()
                        }
                    }
                }else{
                    Toast(text: "网络故障，请检查网络").show()
                }
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.resignFirstResponder()
        pwdTextField.resignFirstResponder()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /// 手机名称
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
    func loadApprovalAndAuthorizeCount() {
        if let info = UserDefaults.standard.object(forKey: "info") as? [String : AnyObject], info.count > 0 {
            let manager = URLCollection()
            if let token = manager.validateToken() {
                manager.getRequest(manager.getApprovalAndAuthorizeCount, params: nil, headers: ["token" : token], callback: {(json, error) in
                    if let jsonObject = json {
                        if jsonObject["Code"].int == 0 {
                            let approvalCount = jsonObject["ApprovalCount"].intValue
                            let authorizeCount = jsonObject["AuthorizeCount"].intValue
                            UserDefaults.standard.set(approvalCount, forKey: "approvalCount")
                            UserDefaults.standard.set(authorizeCount, forKey: "authorizeCount")
                            UserDefaults.standard.synchronize()
                            if approvalCount > 0 || authorizeCount > 0 {
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "MTabBarViewController"), object: 12)
                            }
                            
                        }
                    }
                })
            }
        }
    }

}
