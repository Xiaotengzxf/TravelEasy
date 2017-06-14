//
//  ModifyPwdViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/27.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import JLToast

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
    
    @IBAction func showPwd(sender: AnyObject) {
        let button = sender as! UIButton
        switch button.tag {
        case 1:
            tfOldPwd.secureTextEntry = button.selected
        case 2:
            tfNewPwd.secureTextEntry = button.selected
        default:
            tfReNewPwd.secureTextEntry = button.selected
        }
        button.selected = !button.selected
    }

    @IBAction func modifyPwd(sender: AnyObject) {
        tfOldPwd.resignFirstResponder()
        tfNewPwd.resignFirstResponder()
        tfReNewPwd.resignFirstResponder()
        if let oldPwd = tfOldPwd.text where oldPwd.characters.count > 0 {
            if let newPwd = tfNewPwd.text where newPwd.characters.count > 0 {
                if let renewPwd = tfReNewPwd.text where newPwd == renewPwd {
                    let manager = URLCollection()
                    let hud = self.showHUD()
                    if let token = manager.validateToken(){
                        manager.postRequest(manager.ChangePassword, params: ["oldPassword" : oldPwd , "newPassword" : newPwd], encoding: .URLEncodedInURL , headers: ["Token" : token], callback: { (json, error) in
                            hud.hideAnimated(true)
                            if let jsonObject = json {
                                if jsonObject["Code"].int == 0 {
                                    JLToast.makeText("成功修改密码").show()
                                    self.navigationController?.popViewControllerAnimated(true)
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
                }else{
                    JLToast.makeText("二次密码不一致").show()
                }
            }else{
                JLToast.makeText("新密码不能为空").show()
            }
        }else{
            JLToast.makeText("旧密码不能为空").show()
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
