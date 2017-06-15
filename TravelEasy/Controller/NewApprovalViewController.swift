//
//  NewApprovalViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/8.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SwiftyJSON
import MBProgressHUD
import Toaster


class NewApprovalViewController: UIViewController , XZCalendarControllerDelegate {
    
    @IBOutlet weak var reasonTextView: IQTextView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var goDateLabel: UILabel!
    @IBOutlet weak var backDateLabel: UILabel!
    @IBOutlet weak var travelManView: UIView!
    @IBOutlet weak var travelManViewHeightLConstraint: NSLayoutConstraint!
    @IBOutlet weak var okButton: UIButton!
    var selectedDateFlag = 0
    var goModel : XZCalendarModel!
    var backModel : XZCalendarModel!
    var arrTravel : [JSON] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        okButton.setBackgroundImage(UIImage.imageWithColor(BUTTON3BGCOLORHIGHLIGHT), for: .highlighted)
        okButton.setBackgroundImage(UIImage.imageWithColor(BUTTON3BGCOLORDISABLE), for: .disabled)
        NotificationCenter.default.addObserver(self, selector: #selector(NewApprovalViewController.handleNotification(_:)), name: NSNotification.Name(rawValue: "NewApprovalViewController"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func chooseDate(_ sender: AnyObject) {
        reasonTextView.resignFirstResponder()
        cityTextField.resignFirstResponder()
        let button = sender as! UIButton
        let calender = XZCalendarController()
        calender.start = "1"
        calender.delegate = self
        calender.title = button.tag > 0 ? "选择起始日期" : "选择截止日期"
        selectedDateFlag = button.tag
        self.navigationController?.pushViewController(calender, animated: true)
    }

    @IBAction func addTravelMan(_ sender: AnyObject) {
        reasonTextView.resignFirstResponder()
        cityTextField.resignFirstResponder()
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddressBook") as! AddressBookTableViewController
        controller.flag = 1
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func submitApproval(_ sender: AnyObject) {
        reasonTextView.resignFirstResponder()
        cityTextField.resignFirstResponder()
        let reason = reasonTextView.text
        let city = cityTextField.text
        if reason?.characters.count == 0 || reason?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "请输入出差事由！").show()
            return
        }else if city?.characters.count == 0 || city?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0 {
            Toast(text: "请输入出差地点！").show()
            return
        }else if goModel == nil {
            Toast(text: "请选择起始日期！").show()
            return
        }else if backModel == nil {
            Toast(text: "请选择截止日期！").show()
            return
        }else if arrTravel.count == 0 {
            Toast(text: "请添加出差人！").show()
            return
        }
        if let info = UserDefaults.standard.object(forKey: "info") as? [String : Any] {
            var dicParam : [String : Any] = [:]
            dicParam["CorpId"] = info["CorpId"]
            dicParam["AskEmployeeId"] = info["EmployeeId"]
            dicParam["TravelReason"] = reason as AnyObject
            dicParam["TravelDateStart"] = goModel.toString() as Any
            dicParam["TravelDateEnd"] = backModel.toString() as Any
            dicParam["TravelDestination"] = city as AnyObject
            dicParam["Employees"] = arrTravel.map{$0["EmployeeId"].intValue}
            let token = info["Token"] as! String
            let manager = URLCollection()
            let hud = showHUD()
            manager.postRequest(manager.createAskApproval, params: dicParam, headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                hud.hide(animated: true)
                if let json = jsonObject {
                    if let code = json["Code"].int, code == 0 {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ApprovalListViewController"), object: 3)
                        let controller = self?.storyboard?.instantiateViewController(withIdentifier: "OrderSuccess") as! OrderSuccessViewController
                        controller.intApproval = 1
                        controller.approvalId = json["AskApprovalId"].intValue
                        controller.flightInfo = JSON(["reason" : reason , "date" : "\(self!.goModel.toString())至\(self!.backModel.toString())" , "city" : city!])
                        self?.navigationController?.pushViewController(controller, animated: true)
                        if var viewControllers = self?.navigationController?.viewControllers {
                            for (index , viewController) in  viewControllers.enumerated() {
                                if viewController is NewApprovalViewController {
                                    viewControllers.remove(at: index)
                                    break
                                }
                            }
                            self?.navigationController?.viewControllers = viewControllers
                        }
                        
                    }else{
                        if let message = json["Message"].string {
                            Toast(text: message).show()
                        }
                    }
                }else{
                    Toast(text: "网络不给力，请检查网络!").show()
                }
            })
        }
        
    }
    
    // 处理通知
    func handleNotification(_ sender : Notification) {
        if let tag = sender.object as? Int {
            if tag == 1 {
                let json = JSON(sender.userInfo!["json"]!)
                for travel in arrTravel {
                    if travel["EmployeeId"].intValue == json["EmployeeId"].intValue {
                        return
                    }
                }
                arrTravel.append(json)
                let travelView = Bundle.main.loadNibNamed("TravelManView", owner: nil, options: nil)!.last as! TravelManView
                travelView.translatesAutoresizingMaskIntoConstraints = false
                travelManView.addSubview(travelView)
                travelView.tag = arrTravel.count
                travelManView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[travelView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["travelView" : travelView]))
                travelManView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(spacing)-[travelView(45)]", options: NSLayoutFormatOptions(), metrics: ["spacing" : 30 + 45 * (arrTravel.count - 1)], views: ["travelView" : travelView]))
                travelManViewHeightLConstraint.constant = 30 + 45 * CGFloat(arrTravel.count)
                travelView.nameLabel.text = json["EmployeeName"].string
                travelView.departmentLabel.text = json["DepartmentName"].string
                
            }else if tag == 2 {
                let tag = sender.userInfo!["tag"] as! Int
                let alertController = UIAlertController(title: "提示", message: "您确定要删除该乘机人", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                    
                }))
                alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: {[weak self] (action) in
                    self?.arrTravel.remove(at: tag - 1)
                    if let travelView = self?.travelManView.viewWithTag(tag) as? TravelManView {
                        travelView.removeFromSuperview()
                    }
                    if tag <= self!.arrTravel.count {
                        for i in tag+1...self!.arrTravel.count + 1 {
                            if let passengerView = self?.travelManView.viewWithTag(i) as? TravelManView {
                                passengerView.tag -= 1
                            }
                            for constraint in self!.travelManView.constraints {
                                if constraint.constant == CGFloat(30 + (i-1) * 45) {
                                    constraint.constant -= 45
                                    break
                                }
                            }
                        }
                    }
                    self?.travelManViewHeightLConstraint.constant -= 45
                    }))
                self.present(alertController, animated: true, completion: {
                    
                })
            }
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
    
    // MARK : - Delegate
    
    func xzCalendarController(with model: XZCalendarModel!) {
        if selectedDateFlag > 0 {
            backDateLabel.text = model.toString()
            backModel = model
        }else{
            goDateLabel.text = model.toString()
            goModel = model
        }
    }

}
