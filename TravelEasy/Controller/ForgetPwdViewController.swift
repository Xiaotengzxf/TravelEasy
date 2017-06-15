//
//  ForgetPwdViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/8/14.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON
import Alamofire

class ForgetPwdViewController: UIViewController {

    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var codeButton: UIButton!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    var timer : Timer?
    var count = 0
    var employeeId = 0  //(integer, optional): 员工id ,
    var corpId = 0 //(integer, optional): 公司id ,
    var smsValidateCode = ""  // (string, optional): 已发送的短信验证码
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func showPwd(_ sender: AnyObject) {
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
        pwdTextField.isSecureTextEntry = !button.isSelected
        
    }
    
    @IBAction func getCode(_ sender: AnyObject) {
        if count > 0 {
            return
        }
        if let mobile = phoneTextField.text, mobile.characters.count > 0 {
            let hud = showHUD()
            let manager = URLCollection()
            manager.postRequest(manager.sendSmsValidateCode, params: ["mobile" : mobile as AnyObject], encoding : URLEncoding.default , headers: nil, callback: {[weak self] (json, error) in
                hud.hide(animated: true)
                if let jsonObject = json {
                    if jsonObject["Code"].int == 0 {
                        Toast(text: "验证码以短信的形式已下发，请注意查收！").show()
                        self?.codeTextField.becomeFirstResponder()
                        if self!.timer == nil {
                            self?.timer = Timer.scheduledTimer(timeInterval: 1, target: self!, selector: #selector(ForgetPwdViewController.startTimer(_:)), userInfo: nil, repeats: true)
                        }
                        self?.employeeId = jsonObject["EmployeeId"].intValue
                        self?.corpId = jsonObject["CorpId"].intValue
                        self?.smsValidateCode = jsonObject["SmsValidateCode"].stringValue
                    }else{
                        if let message = jsonObject["Message"].string {
                            Toast(text: message).show()
                        }
                    }
                }else{
                    Toast(text: "网络故障，请检查网络").show()
                }
                })
        }else{
            Toast(text: "请输入手机号").show()
        }
    }

    @IBAction func submitPwd(_ sender: AnyObject) {
        phoneTextField.resignFirstResponder()
        codeTextField.resignFirstResponder()
        pwdTextField.resignFirstResponder()
        let mobile = phoneTextField.text
        let code = codeTextField.text
        let pwd = pwdTextField.text
        if mobile == nil || mobile!.characters.count == 0 {
            Toast(text: "请输入手机号").show()
            return
        }else if code == nil || code!.characters.count == 0 {
            Toast(text: "请输入验证码").show()
            return
        }else if code! != smsValidateCode {
            Toast(text: "验证码输入有误").show()
            return
        }else if pwd == nil || pwd!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "密码不能为空").show()
            return
        }
        let hud = showHUD()
        let manager = URLCollection()
        manager.postRequest(manager.resetPassword, params: ["corpId" : corpId as AnyObject , "employeeId" : employeeId as AnyObject , "newPassword" : pwd as AnyObject ?? "" as AnyObject], encoding : URLEncoding.default , headers: nil, callback: {[weak self] (json, error) in
            hud.hide(animated: true)
            if let jsonObject = json {
                if jsonObject["Code"].int == 0 {
                    Toast(text: "新密码设置成功，请使用新密码登录").show()
                    self?.navigationController?.popViewController(animated: true)
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
    
    func startTimer(_ sender : Timer)  {
        if count >= 60 {
            codeButton.setTitle("发送验证码", for: UIControlState())
            count = 0
            timer?.invalidate()
            timer = nil
            return
        }
        count += 1
        codeButton.setTitle("\(60 - count)s", for: UIControlState())
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
