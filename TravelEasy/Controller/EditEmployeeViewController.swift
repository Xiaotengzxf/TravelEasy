//
//  EditEmployeeViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/3.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import SwiftyJSON
import MBProgressHUD
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
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class EditEmployeeViewController: UIViewController , ChooseProjectTableViewControllerDelegate , ChooseApprovalNoTableViewControllerDelegate {

    @IBOutlet weak var mobileTextField: UITextField!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var departmentView: UIView!
    @IBOutlet weak var chooseUserNameButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var addEnterpriseUserViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var addEnterpriseUserView: UIView!
    @IBOutlet weak var employeeNameLabel: UILabel!
    @IBOutlet weak var credentialTypeLabel: UILabel!
    @IBOutlet weak var credentialNoTextfield: UITextField!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var approvalNoLabel: UILabel!
    @IBOutlet weak var approvalView: UIView!
    @IBOutlet weak var projectView: UIView!
    @IBOutlet weak var lineDImageView: UIImageView!
    @IBOutlet weak var lineImageView: UIImageView!
    @IBOutlet weak var lineImageViewBottomLConstraint: NSLayoutConstraint!
    var flightInfo : JSON!
    var employee : JSON!
    var approvalRequired = false
    var isProjectRequired = false
    var isGreenChannel = false
    var isUser = false
    var isEdit = false
    var canBookingForOthers = false
    var userId = 0  // 当前登录用户的id
    var isEnterpriseUser = false
    var certTypes : [JSON] = []
    var project : JSON!
    var approval : JSON!
    var index = 0
    var selectedRow = 0
    var departmentId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let info = UserDefaults.standard.object(forKey: "info") as? [String : AnyObject] {
            approvalRequired = info["ApprovalRequired"] as? Bool ?? false
            isProjectRequired = info["IsProjectRequired"] as? Bool ?? false
            isGreenChannel = info["IsGreenChannel"] as? Bool ?? false
            canBookingForOthers = info["CanBookingForOthers"] as? Bool ?? false
            userId = info["EmployeeId"] as? Int ?? 0
            if !approvalRequired {
                approvalView.isHidden = true
                lineImageView.isHidden = true
                if isProjectRequired {
                    lineImageViewBottomLConstraint.constant = -45
                }else{
                    projectView.isHidden = true
                }
            }else{
                if !isProjectRequired {
                    lineImageView.isHidden = true
                    projectView.isHidden = true
                }
            }
            if isGreenChannel {
                approvalView.isHidden = true
                lineImageView.isHidden = true
                lineImageViewBottomLConstraint.constant = -45
            }
        }
        if isEdit {
            if !canBookingForOthers {
                isUser = false
                credentialTypeLabel.text = employee["DefaultCertType"].string
                credentialNoTextfield.text = employee["DefaultCertNo"].string
                employeeNameLabel.text = employee["EmployeeName"].string
                departmentLabel.text = employee["DepartmentName"].string
                mobileTextField.text = employee["Mobile"].string
                chooseUserNameButton.isHidden = true
                if approvalRequired {
                    approval = employee["approval"]
                    if approval != nil {
                        approvalNoLabel.text = approval["ApprovalNo"].string
                    }
                }
                if isProjectRequired {
                    project = employee["project"]
                    if project != nil  {
                        projectNameLabel.text = project["ProjectName"].string
                    }
                }
            }else{
                isUser = employee["isUser"].boolValue
                credentialTypeLabel.text = employee["credentialType"].string
                credentialNoTextfield.text = employee["credentialNo"].string
                if approvalRequired {
                    approval = employee["approval"]
                    approvalNoLabel.text = approval["ApprovalNo"].string
                }
                if isProjectRequired {
                    project = employee["project"]
                    projectNameLabel.text = project["ProjectName"].string
                }
                employee = employee["employee"]
                if isUser {
                    employeeNameLabel.text = employee["Name"].string
                    departmentLabel.text = employee["BelongedDepartmentName"].string
                }else{
                    employeeNameLabel.text = employee["EmployeeName"].string
                    departmentLabel.text = employee["DepartmentName"].string
                }
                mobileTextField.text = employee["Mobile"].string
            }
            addEnterpriseUserViewBottomConstraint.constant = -44
        }
        if isEnterpriseUser {
            chooseUserNameButton.isHidden = true
            addEnterpriseUserViewBottomConstraint.constant = -44
        }else{
            tfUserName.isHidden = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(EditEmployeeViewController.handleNotification(_:)), name: NSNotification.Name(rawValue: "EditEmployeeViewController"), object: nil)
    }
    
    func refreshUserView()  {
        if isUser {
            employeeNameLabel.text = employee["Name"].string
            departmentLabel.text = employee["BelongedDepartmentName"].string
            credentialTypeLabel.text = employee["CertType"].string ?? "身份证"
            credentialNoTextfield.text = employee["CertNo"].string
            mobileTextField.text = employee["Mobile"].string
        }else{
            if isEnterpriseUser {
                credentialTypeLabel.text = "身份证"
            }else{
                employeeNameLabel.text = employee["EmployeeName"].string
                departmentLabel.text = employee["DepartmentName"].string
                credentialTypeLabel.text = employee["DefaultCertType"].string ?? "身份证"
                credentialNoTextfield.text = employee["DefaultCertNo"].string
                mobileTextField.text = employee["Mobile"].string
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleNotification(_ sender : Notification ) {
        if let tag = sender.object as? Int {
            if tag == 1 {
                if let row = sender.userInfo?["row"] as? Int {
                    selectedRow = row
                    if certTypes.count > 0 {
                        credentialTypeLabel.text = certTypes[row].stringValue
                        credentialNoTextfield.text = nil
                    }
                }
            }else if tag == 2 {
                departmentLabel.text = sender.userInfo?["name"] as? String
                departmentId = sender.userInfo?["id"] as? Int ?? 0
                if !isEnterpriseUser {
                    if employee != nil {
                        if var dict = employee.dictionaryObject {
                            if isUser {
                                dict["BelongedDepartmentName"] = sender.userInfo?["name"] as? String ?? ""
                                dict["BelongedDepartmentId"] = sender.userInfo?["id"] as? Int ?? 0
                            }else{
                                dict["DepartmentName"] = sender.userInfo?["name"] as? String ?? ""
                                dict["DepartmentId"] = sender.userInfo?["id"] as? Int ?? 0
                            }
                            employee = JSON(dict)
                        }
                    }
                }
            }else if tag == 3 {
                employee = JSON(sender.userInfo!["json"]!)
                isUser = sender.userInfo!["isUser"] as? Bool ?? false
                refreshUserView()
            }
        }
    }
    
    @IBAction func chooseEmployee(_ sender: AnyObject) {
        tfUserName.resignFirstResponder()
        credentialNoTextfield.resignFirstResponder()
        let button = sender as! UIButton
        if button.tag == 1 {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "EditEmployee") as! EditEmployeeViewController
            controller.isEnterpriseUser = true
            controller.title = "企业客户"
            controller.isUser = false
            controller.isEdit = false
            controller.flightInfo = flightInfo
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            self.performSegue(withIdentifier: "toAddressBook", sender: self)
        }
    }

    @IBAction func chooseCredentialType(_ sender: AnyObject) {
        tfUserName.resignFirstResponder()
        credentialNoTextfield.resignFirstResponder()
        if certTypes.count > 0 {
            chooseCertType()
        }else{
            let manager = URLCollection()
            let hud = showHUD()
            if let token = manager.validateToken() {
                manager.getRequest(manager.getCertTypes, params: nil, headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                    hud.hide(animated: true)
                    if let json = jsonObject {
                        if let code = json["Code"].int, code == 0 {
                            self!.certTypes += json["CertTypes"].arrayValue
                            self!.chooseCertType()
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
    }
    
    /**
     选择证件类型
     */
    func chooseCertType() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "BunkList") as! BunkListViewController
        let bunks = certTypes.map{$0.stringValue}
        if let text = credentialTypeLabel.text, text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0 && selectedRow == 0 {
            let index = bunks.index(of: text)
            selectedRow = index ?? 0
        }
        controller.selectedRow = selectedRow
        controller.bunks = bunks
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        controller.flag = 3
        self.present(controller, animated: true, completion: {
            
        })
    }
    
    @IBAction func chooseApprovalNo(_ sender: AnyObject) {
        if !isEnterpriseUser {
            if employee != nil {
                
            }else{
                Toast(text: "请先选择乘机人").show()
                return
            }
        }
        self.performSegue(withIdentifier: "toChooseApprovalNo", sender: self)
    }
    
    @IBAction func chooseProject(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "toChooseProject", sender: self)
    }
    
    /**
     完成
     
     - parameter sender: 按钮
     */
    @IBAction func finishedEdit(_ sender: AnyObject) {
        tfUserName.resignFirstResponder()
        credentialNoTextfield.resignFirstResponder()
        if (tfUserName.text == nil || tfUserName.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0) && isEnterpriseUser  {
            Toast(text: "请输入乘机人").show()
            return
        }else if !isEnterpriseUser && (employeeNameLabel.text?.characters.count == 0) {
            Toast(text: "请选择乘机人").show()
            return
        }else if credentialTypeLabel.text?.characters.count <= 0 {
            Toast(text: "请选择证件类型").show()
            return
        }else if credentialNoTextfield.text?.characters.count <= 0 {
            Toast(text: "请填写证件号码").show()
            return
        }else if departmentLabel.text?.characters.count <= 0 || departmentLabel.text == "必选" {
            Toast(text: "请选择所属部门").show()
            return
        }else {
            if !isGreenChannel {
                if approvalRequired && !(approval != nil) {
                    Toast(text: "请选择审批单号").show()
                    return
                }
            }
            if isProjectRequired && !(project != nil) {
                Toast(text: "请选择所属项目").show()
                return
            }
        }
        if isEnterpriseUser {
            employee = JSON(["DefaultCertNo" : "","DefaultCertType" : "" , "DepartmentId" : departmentId ,"DepartmentName" : "\(departmentLabel.text ?? "")","Email" : "" ,"EmployeeId" : 0 ,"EmployeeName" : "\(tfUserName.text ?? "")" ,"Gender" : "" ,"Mobile" : "\(mobileTextField.text ?? "")" ,"WorkNo" : ""
            ])
        }else{
            if let mobile = mobileTextField.text, mobile.characters.count > 0 {
                if var dict = employee.dictionaryObject {
                    dict["Mobile"] = mobile
                    employee = JSON(dict)
                }
            }
        }
        var userInfo : [String : AnyObject] = [ "credentialType" : credentialTypeLabel.text as AnyObject ?? "" as AnyObject , "credentialNo" : credentialNoTextfield.text as AnyObject ?? "" as AnyObject , "isUser" : isUser as AnyObject , "isEdit" : isEdit as AnyObject , "index" : index as AnyObject]
        if employee != nil {
            userInfo["employee"] = employee.object as AnyObject
        }
        if approval != nil {
            userInfo["approval"] = approval.object as AnyObject
        }
        if project != nil {
            userInfo["project"] = project.object as AnyObject
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "WriteOrderViewController"), object: 1, userInfo: userInfo)
        for viewController in self.navigationController!.viewControllers {
            if viewController is WriteOrderViewController {
                self.navigationController?.popToViewController(viewController, animated: true)
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ChooseProjectTableViewController {
            controller.delegate = self
        }else if let controller = segue.destination as? ChooseApprovalNoTableViewController {
            controller.delegate = self
            controller.flightInfo = flightInfo
            if isUser {
                controller.employeeId = employee["BelongedEmployeeId"].intValue
            }else{
                if isEnterpriseUser {
                    controller.employeeId = userId
                }else{
                    controller.employeeId = employee["EmployeeId"].intValue
                }
            }
        }
    }
    
    // MARK: - ChooseProject TableView Controller Delegate
    func chooseProjectWithJSON(_ project: JSON) {
        projectNameLabel.text = project["ProjectName"].string
        self.project = project
    }
    
    func chooseApprovalNoWithJSON(_ approval: JSON) {
        approvalNoLabel.text = approval["ApprovalNo"].string
        self.approval = approval
    }
    
    @IBAction func chooseDepartment(_ sender: AnyObject) {
        tfUserName.resignFirstResponder()
        credentialNoTextfield.resignFirstResponder()
        self.performSegue(withIdentifier: "toDepartmentList", sender: self)
    }
    
}
