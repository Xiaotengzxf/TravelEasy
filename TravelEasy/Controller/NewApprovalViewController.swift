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
import JLToast


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
        okButton.setBackgroundImage(UIImage.imageWithColor(BUTTON3BGCOLORHIGHLIGHT), forState: .Highlighted)
        okButton.setBackgroundImage(UIImage.imageWithColor(BUTTON3BGCOLORDISABLE), forState: .Disabled)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewApprovalViewController.handleNotification(_:)), name: "NewApprovalViewController", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func chooseDate(sender: AnyObject) {
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

    @IBAction func addTravelMan(sender: AnyObject) {
        reasonTextView.resignFirstResponder()
        cityTextField.resignFirstResponder()
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("AddressBook") as! AddressBookTableViewController
        controller.flag = 1
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func submitApproval(sender: AnyObject) {
        reasonTextView.resignFirstResponder()
        cityTextField.resignFirstResponder()
        let reason = reasonTextView.text
        let city = cityTextField.text
        if reason.characters.count == 0 || reason.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count == 0 {
            JLToast.makeText("请输入出差事由！").show()
            return
        }else if city?.characters.count == 0 || city?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count == 0 {
            JLToast.makeText("请输入出差地点！").show()
            return
        }else if goModel == nil {
            JLToast.makeText("请选择起始日期！").show()
            return
        }else if backModel == nil {
            JLToast.makeText("请选择截止日期！").show()
            return
        }else if arrTravel.count == 0 {
            JLToast.makeText("请添加出差人！").show()
            return
        }
        if let info = NSUserDefaults.standardUserDefaults().objectForKey("info") as? [String : AnyObject] {
            var dicParam : [String : AnyObject] = [:]
            dicParam["CorpId"] = info["CorpId"]
            dicParam["AskEmployeeId"] = info["EmployeeId"]
            dicParam["TravelReason"] = reason
            dicParam["TravelDateStart"] = goModel.toString()
            dicParam["TravelDateEnd"] = backModel.toString()
            dicParam["TravelDestination"] = city
            dicParam["Employees"] = arrTravel.map{$0["EmployeeId"].intValue}
            let token = info["Token"] as! String
            let manager = URLCollection()
            let hud = showHUD()
            manager.postRequest(manager.createAskApproval, params: dicParam, headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                hud.hideAnimated(true)
                if let json = jsonObject {
                    if let code = json["Code"].int where code == 0 {
                        NSNotificationCenter.defaultCenter().postNotificationName("ApprovalListViewController", object: 3)
                        let controller = self?.storyboard?.instantiateViewControllerWithIdentifier("OrderSuccess") as! OrderSuccessViewController
                        controller.intApproval = 1
                        controller.approvalId = json["AskApprovalId"].intValue
                        controller.flightInfo = JSON(["reason" : reason , "date" : "\(self!.goModel.toString())至\(self!.backModel.toString())" , "city" : city!])
                        self?.navigationController?.pushViewController(controller, animated: true)
                        if var viewControllers = self?.navigationController?.viewControllers {
                            for (index , viewController) in  viewControllers.enumerate() {
                                if viewController is NewApprovalViewController {
                                    viewControllers.removeAtIndex(index)
                                    break
                                }
                            }
                            self?.navigationController?.viewControllers = viewControllers
                        }
                        
                    }else{
                        if let message = json["Message"].string {
                            JLToast.makeText(message).show()
                        }
                    }
                }else{
                    JLToast.makeText("网络不给力，请检查网络!").show()
                }
            })
        }
        
    }
    
    // 处理通知
    func handleNotification(sender : NSNotification) {
        if let tag = sender.object as? Int {
            if tag == 1 {
                let json = JSON(sender.userInfo!["json"]!)
                for travel in arrTravel {
                    if travel["EmployeeId"].intValue == json["EmployeeId"].intValue {
                        return
                    }
                }
                arrTravel.append(json)
                let travelView = NSBundle.mainBundle().loadNibNamed("TravelManView", owner: nil, options: nil)!.last as! TravelManView
                travelView.translatesAutoresizingMaskIntoConstraints = false
                travelManView.addSubview(travelView)
                travelView.tag = arrTravel.count
                travelManView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[travelView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["travelView" : travelView]))
                travelManView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(spacing)-[travelView(45)]", options: .DirectionLeadingToTrailing, metrics: ["spacing" : 30 + 45 * (arrTravel.count - 1)], views: ["travelView" : travelView]))
                travelManViewHeightLConstraint.constant = 30 + 45 * CGFloat(arrTravel.count)
                travelView.nameLabel.text = json["EmployeeName"].string
                travelView.departmentLabel.text = json["DepartmentName"].string
                
            }else if tag == 2 {
                let tag = sender.userInfo!["tag"] as! Int
                let alertController = UIAlertController(title: "提示", message: "您确定要删除该乘机人", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (action) in
                    
                }))
                alertController.addAction(UIAlertAction(title: "确定", style: .Default, handler: {[weak self] (action) in
                    self?.arrTravel.removeAtIndex(tag - 1)
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
                self.presentViewController(alertController, animated: true, completion: {
                    
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
    
    func xzCalendarControllerWithModel(model: XZCalendarModel!) {
        if selectedDateFlag > 0 {
            backDateLabel.text = model.toString()
            backModel = model
        }else{
            goDateLabel.text = model.toString()
            goModel = model
        }
    }

}
