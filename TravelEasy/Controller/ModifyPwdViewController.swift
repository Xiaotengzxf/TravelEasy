//
//  ModifyPwdViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/27.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import Toaster
import Alamofire

class ModifyPwdViewController: UIViewController {

    @IBOutlet weak var tfOldPwd: UITextField!
    @IBOutlet weak var tfNewPwd: UITextField!
    @IBOutlet weak var tfReNewPwd: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showPwd(_ sender: AnyObject) {
        let button = sender as! UIButton
        switch button.tag {
        case 1:
            tfOldPwd.isSecureTextEntry = button.isSelected
        case 2:
            tfNewPwd.isSecureTextEntry = button.isSelected
        default:
            tfReNewPwd.isSecureTextEntry = button.isSelected
        }
        button.isSelected = !button.isSelected
    }

    @IBAction func modifyPwd(_ sender: AnyObject) {
        tfOldPwd.resignFirstResponder()
        tfNewPwd.resignFirstResponder()
        tfReNewPwd.resignFirstResponder()
        if let oldPwd = tfOldPwd.text, oldPwd.characters.count > 0 {
            if let newPwd = tfNewPwd.text, newPwd.characters.count > 0 {
                if let renewPwd = tfReNewPwd.text, newPwd == renewPwd {
                    let manager = URLCollection()
                    let hud = self.showHUD()
                    if let token = manager.validateToken(){
                        manager.postRequest(manager.ChangePassword, params: ["oldPassword" : oldPwd , "newPassword" : newPwd], encoding: URLEncoding.default , headers: ["Token" : token], callback: { (json, error) in
                            hud.hide(animated: true)
                            if let jsonObject = json {
                                if jsonObject["Code"].int == 0 {
                                    Toast(text: "成功修改密码").show()
                                    self.navigationController?.popViewController(animated: true)
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
                }else{
                    Toast(text: "二次密码不一致").show()
                }
            }else{
                Toast(text: "新密码不能为空").show()
            }
        }else{
            Toast(text: "旧密码不能为空").show()
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
