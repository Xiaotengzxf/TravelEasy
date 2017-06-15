//
//  ApprovalListViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/8.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import MJRefresh
import SwiftyJSON
import Toaster
import MBProgressHUD
import PopupDialog
import Alamofire
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


class ApprovalListViewController: UIViewController , UITableViewDataSource , UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl! // 单选控件
    @IBOutlet weak var indicatorLeftLConstraint: NSLayoutConstraint! // 单选器指示器
    @IBOutlet weak var indicatorWidthLConstraint: NSLayoutConstraint!
    @IBOutlet weak var indicatorImageView: UIImageView!
    @IBOutlet weak var lineImageView: UIImageView!
    var emptyView : EmptyView!
    var tableEmptyView : EmptyView!
    var arrApproval : [JSON] = []
    var pageNumber = 0
    var pageSize = 10
    var segmentItemWidth : CGFloat = 0
    var status = 0
    var totalCount = 0
    var approvalId = 0
    var indexRow = 0
    var approvalRequired = false
    var overrunOption = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.setBackgroundImage(UIImage.imageWithColor("ffffff"), for: UIControlState(), barMetrics: .default)
        segmentedControl.setBackgroundImage(UIImage.imageWithColor("ffffff"), for: .selected, barMetrics: .default)
        segmentedControl.setBackgroundImage(UIImage.imageWithColor("ffffff"), for: .highlighted, barMetrics: .default)
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(FONTCOLOR) , NSFontAttributeName : UIFont.systemFont(ofSize: 13)], for: UIControlState())
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor("0071C4") , NSFontAttributeName : UIFont.systemFont(ofSize: 13)], for: .selected)
        segmentedControl.setDividerImage(UIImage.imageWithColor("ffffff"), forLeftSegmentState: UIControlState(), rightSegmentState: UIControlState(), barMetrics: .default)
        
        emptyView = EmptyManager.getInstance.insertEmptyView(with: self.view, top: 0, emptyType: .noFuction)
        emptyView.isHidden = true
        tableEmptyView = EmptyManager.getInstance.insertEmptyView(with: self.view, top: 44, emptyType: .noData)
        tableEmptyView.isHidden = true
        
        if let info = UserDefaults.standard.object(forKey: "info") as? [String : AnyObject] {
            approvalRequired = info["ApprovalRequired"] as! Bool
            overrunOption = info["OverrunOption"] as! String
            let approvalCount = UserDefaults.standard.integer(forKey: "approvalCount")
            let authorizeCount = UserDefaults.standard.integer(forKey: "authorizeCount")
            if approvalRequired && overrunOption == "WarningAndAuthorize" {
                self.navigationItem.title = "审批授权"
                segmentedControl.setTitle("待审\(approvalCount > 0 ? "(\(approvalCount))" : "")", forSegmentAt: 1)
                segmentedControl.insertSegment(withTitle: "待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", at: 3, animated: false)
                segmentedControl.insertSegment(withTitle: "已授权", at: 4, animated: false)
                indicatorWidthLConstraint.constant = SCREENWIDTH / 5
                segmentItemWidth = SCREENWIDTH / 5
                status = 1
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "填写计划", style: .plain, target: self, action: #selector(ApprovalListViewController.createNewApproval))
            }else if approvalRequired && overrunOption != "WarningAndAuthorize" {
                self.navigationItem.title = "审批"
                indicatorWidthLConstraint.constant = SCREENWIDTH / 3
                segmentItemWidth = SCREENWIDTH / 3
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "填写计划", style: .plain, target: self, action: #selector(ApprovalListViewController.createNewApproval))
                segmentedControl.setTitle("待审\(approvalCount > 0 ? "(\(approvalCount))" : "")", forSegmentAt: 1)
            }else if overrunOption == "WarningAndAuthorize" {
                self.navigationItem.title = "授权"
                indicatorWidthLConstraint.constant = SCREENWIDTH / 2
                segmentedControl.setTitle("待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", forSegmentAt: 0)
                segmentedControl.setTitle("已授权", forSegmentAt: 1)
                segmentedControl.removeSegment(at: 2, animated: false)
                segmentItemWidth = SCREENWIDTH / 2
                status = 2
            }else{
                self.navigationItem.title = "审批"
                segmentedControl.isHidden = true
                indicatorImageView.isHidden = true
                lineImageView.isHidden = true
                tableView.isHidden = true
                emptyView.isHidden = false
            }
        }
        tableView.mj_header = MJRefreshNormalHeader{ [weak self] in
            self?.pageNumber = 1
            self?.arrApproval.removeAll()
            self?.tableView.reloadData()
            self?.getApprovalList()
        }
        tableView.mj_footer = MJRefreshBackNormalFooter{ [weak self] in
            self?.pageNumber += 1
            self?.getApprovalList()
        }
        tableView.mj_header.beginRefreshing()
        NotificationCenter.default.addObserver(self, selector: #selector(ApprovalListViewController.handleNotification(_:)), name: NSNotification.Name(rawValue: "ApprovalListViewController"), object: nil)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     单选器
     
     - parameter sender: segmentControl
     */
    @IBAction func changeValue(_ sender: AnyObject) {
        indicatorLeftLConstraint.constant = CGFloat(segmentedControl.selectedSegmentIndex) * segmentItemWidth
        if segmentedControl.selectedSegmentIndex == 0 {
            if segmentedControl.numberOfSegments > 2 {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "填写计划", style: .plain, target: self, action: #selector(ApprovalListViewController.createNewApproval))
            }
        }else {
            self.navigationItem.rightBarButtonItem = nil
        }
        tableView.mj_header.beginRefreshing()
    }
    
    /**
     填写计划
     */
    func createNewApproval()  {
        self.performSegue(withIdentifier: "toNewApproval", sender: self)
    }
    
    func getApprovalList() {
        self.tableEmptyView.isHidden = true
        let manager = URLCollection()
        if let token = manager.validateToken() {
            var urlString = ""
            if status == 2 {
                if segmentedControl.selectedSegmentIndex == 0 {
                    urlString = manager.getAuthorizeSheetsToAuditForMe
                }else{
                    urlString = manager.getAuthorizeSheetsAuditedByMe
                }
            }else{
                if segmentedControl.selectedSegmentIndex == 0 {
                    urlString = manager.getMyApprovals
                }else if segmentedControl.selectedSegmentIndex == 1 {
                    urlString = manager.getApprovalsToAuditForMe
                }else if segmentedControl.selectedSegmentIndex == 2 {
                    urlString = manager.getApprovalsAuditedByMe
                }else if segmentedControl.selectedSegmentIndex == 3 {
                    urlString = manager.getAuthorizeSheetsToAuditForMe
                }else{
                    urlString = manager.getAuthorizeSheetsAuditedByMe
                }
            }
            manager.getRequest(urlString, params: ["pageNumber" : pageNumber , "pageSize" : pageSize], headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                self?.tableView.mj_header.endRefreshing()
                self?.tableView.mj_footer.endRefreshing()
                if let json = jsonObject {
                    if let code = json["Code"].int, code == 0 {
                        let name = self!.status == 2 || self!.segmentedControl.selectedSegmentIndex >= 3 ? "Authorizes" : "Approvals"
                        if let approvals = json[name].array {
                            self?.arrApproval += approvals
                            self?.tableView.reloadData()
                            self?.totalCount = json["TotalCount"].intValue
                            if self?.arrApproval.count == self?.totalCount {
                                self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                            }
                            let approvalCount = UserDefaults.standard.integer(forKey: "approvalCount")
                            let authorizeCount = UserDefaults.standard.integer(forKey: "authorizeCount")
                            if self!.status == 2 {
                                if self!.segmentedControl.selectedSegmentIndex == 0 {
                                    if authorizeCount != self!.totalCount {
                                        UserDefaults.standard.set(self!.totalCount, forKey: "authorizeCount")
                                        UserDefaults.standard.synchronize()
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: "ApprovalListViewController"), object: 4)
                                    }
                                }
                            }else{
                                if self!.segmentedControl.selectedSegmentIndex == 1 {
                                    if approvalCount != self!.totalCount {
                                        UserDefaults.standard.set(self!.totalCount, forKey: "approvalCount")
                                        UserDefaults.standard.synchronize()
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: "ApprovalListViewController"), object: 4)
                                    }
                                }else if self!.segmentedControl.selectedSegmentIndex == 3 {
                                    if authorizeCount != self!.totalCount {
                                        UserDefaults.standard.set(self!.totalCount, forKey: "authorizeCount")
                                        UserDefaults.standard.synchronize()
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: "ApprovalListViewController"), object: 4)
                                    }
                                }
                            }
                            if self!.pageNumber == 1 && approvals.count == 0 {
                                self!.tableEmptyView.isHidden = false
                            }
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
    
    /**
     审批通过申请单
     
     - parameter row: 列
     */
    func auditPassOrReject(_ row : Int , eventTag : Int , opinion : String?)  {
        let hud = showHUD()
        let manager = URLCollection()
        if let token = manager.validateToken() {
            var urlString = ""
            var params : [String : Any] = [:]
            if status == 2 || segmentedControl.selectedSegmentIndex >= 3 {
                urlString = eventTag > 0 ? manager.auditPassAuthorize : manager.auditRejectAuthorize
                params["AuthorizeId"] = arrApproval[row]["AuthorizeId"].intValue
            }else{
                if segmentedControl.selectedSegmentIndex == 0 {
                    urlString = manager.cancelApproval
                }else{
                    urlString = eventTag > 0 ? manager.auditPassApproval : manager.auditRejectApproval
                }
                params["approvalId"] = arrApproval[row]["ApprovalId"].intValue
            }
            if opinion != nil && opinion?.characters.count > 0 {
                params["opinion"] = opinion!
            }
            manager.postRequest(urlString, params: params , encoding : URLEncoding.default , headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                hud.hide(animated: true)
                if let json = jsonObject {
                    if let code = json["Code"].int, code == 0 {
                        self?.tableView.mj_header.beginRefreshing()
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
    
    func changeDateType(_ date : String) -> String {
        let array = date.components(separatedBy: "-")
        if array.count == 3 {
            return "\(array[0])年\(array[1])月\(array[2])日"
        }else{
            return date
        }
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrApproval.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ApprovalTableViewCell
        cell.tag = indexPath.row
        let json = arrApproval[indexPath.row]
        if status == 2 {
            if segmentedControl.selectedSegmentIndex == 0 {
                cell.nameLabel.text = "\(json["TravellerName"].stringValue)的订单需要您授权"
                cell.oneLabel.text = "出差地点"
                cell.oneContentLabel.text = json["OrderDesc"].stringValue.components(separatedBy: " ")[1]
                cell.twoLabel.text = "出差时间"
                cell.twoContentLabel.text = json["OrderDesc"].stringValue.components(separatedBy: " ")[0]
                cell.statusLabel.text = json["Status"].stringValue
                if let status = json["Status"].string, status == "待订单授权"{
                    cell.cancelButton.isHidden = false
                    cell.okButton.isHidden = false
                    cell.cancelButton.setTitle("拒绝", for: UIControlState())
                    cell.okButton.setTitle("同意", for: UIControlState())
                }else{
                    cell.cancelButton.isHidden = true
                    cell.okButton.isHidden = true
                }
            }else{
                cell.nameLabel.text = "\(json["AskEmployeeName"].stringValue)的订单授权"
                cell.oneLabel.text = "出差地点"
                cell.oneContentLabel.text = json["OrderDesc"].stringValue.components(separatedBy: " ")[1]
                cell.twoLabel.text = "出差时间"
                cell.twoContentLabel.text = json["OrderDesc"].stringValue.components(separatedBy: " ")[0]
                cell.statusLabel.text = json["Status"].stringValue
                cell.cancelButton.isHidden = true
                cell.okButton.isHidden = true
            }
        }else{
            if segmentedControl.selectedSegmentIndex == 0 {
                cell.nameLabel.text = "\(json["AskEmployeeName"].stringValue)的审批"
                cell.oneLabel.text = "出差地点"
                cell.oneContentLabel.text = json["TravelDestination"].stringValue
                cell.twoLabel.text = "出差时间"
                cell.twoContentLabel.text = changeDateType(json["TravelDateStart"].stringValue) + "-" + changeDateType(json["TravelDateEnd"].stringValue)
                cell.statusLabel.text = json["Status"].stringValue
                if let status = json["Status"].string, status == "待审批"{
                    cell.okButton.isHidden = false
                    cell.okButton.setTitle("撤销", for: UIControlState())
                }else{
                    cell.okButton.isHidden = true
                }
                cell.cancelButton.isHidden = true
            }else if segmentedControl.selectedSegmentIndex == 1 {
                cell.nameLabel.text = "\(json["AskEmployeeName"].stringValue)的出差审批需要您审批"
                cell.oneLabel.text = "出差地点"
                cell.oneContentLabel.text = json["TravelDestination"].stringValue
                cell.twoLabel.text = "出差时间"
                cell.twoContentLabel.text = changeDateType(json["TravelDateStart"].stringValue) + "-" + changeDateType(json["TravelDateEnd"].stringValue)
                cell.statusLabel.text = json["Status"].stringValue
                if let status = json["Status"].string, status == "待审批"{
                    cell.cancelButton.isHidden = false
                    cell.okButton.isHidden = false
                    cell.cancelButton.setTitle("拒绝", for: UIControlState())
                    cell.okButton.setTitle("同意", for: UIControlState())
                }else{
                    cell.cancelButton.isHidden = true
                    cell.okButton.isHidden = true
                }
                
            }else if segmentedControl.selectedSegmentIndex == 2 {
                cell.nameLabel.text = "\(json["AskEmployeeName"].stringValue)的审批"
                cell.oneLabel.text = "出差地点"
                cell.oneContentLabel.text = json["TravelDestination"].stringValue
                cell.twoLabel.text = "出差时间"
                cell.twoContentLabel.text = changeDateType(json["TravelDateStart"].stringValue) + "-" + changeDateType(json["TravelDateEnd"].stringValue)
                cell.statusLabel.text = "审批完成(\(json["Status"].stringValue))"
                cell.cancelButton.isHidden = true
                cell.okButton.isHidden = true
            }else if segmentedControl.selectedSegmentIndex == 3 {
                cell.nameLabel.text = "\(json["TravellerName"].stringValue)的订单需要您授权"
                cell.oneLabel.text = "出差地点"
                cell.oneContentLabel.text = json["OrderDesc"].stringValue.components(separatedBy: " ")[1]
                cell.twoLabel.text = "出差时间"
                cell.twoContentLabel.text = json["OrderDesc"].stringValue.components(separatedBy: " ")[0]
                cell.statusLabel.text = json["Status"].stringValue
                if let status = json["Status"].string, status == "待授权"{
                    cell.cancelButton.isHidden = false
                    cell.okButton.isHidden = false
                    cell.cancelButton.setTitle("拒绝", for: UIControlState())
                    cell.okButton.setTitle("同意", for: UIControlState())
                }else{
                    cell.cancelButton.isHidden = true
                    cell.okButton.isHidden = true
                }
            }else{
                cell.nameLabel.text = "\(json["TravellerName"].stringValue)的订单授权"
                cell.oneLabel.text = "出差地点"
                cell.oneContentLabel.text = json["OrderDesc"].stringValue.components(separatedBy: " ")[1]
                cell.twoLabel.text = "出差时间"
                cell.twoContentLabel.text = json["OrderDesc"].stringValue.components(separatedBy: " ")[0]
                cell.statusLabel.text = json["Status"].stringValue
                cell.cancelButton.isHidden = true
                cell.okButton.isHidden = true
                
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK : - TableView Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let controller = segue.destination as? ApprovalDetailViewController {
            if segmentedControl.selectedSegmentIndex == 0 {
                controller.isOwn = true
                controller.title = "出差申请"
            }else{
                if arrApproval.count > 0 {
                    let json = arrApproval[indexRow]
                    controller.title = "\(json["AskEmployeeName"].stringValue)的出差申请"
                }
            }
            controller.approvalId = approvalId
            
        }else if let controller = segue.destination as? AuthorizeDetailViewController {
            controller.authorizeId = approvalId
            if arrApproval.count > 0 {
                let json = arrApproval[indexRow]
                controller.title = "\(json["TravellerName"].stringValue)的订单授权"
            }
        }
    }
    
    
    func handleNotification(_ sender : Notification)  {
        if let tag = sender.object as? Int {
            if tag == 1 {
                if let dict = sender.userInfo {
                    if let eventTag = dict["eventTag"] as? Int {
                        let row = dict["tag"] as! Int
                        if eventTag == 1 {
                            auditPassOrReject(row, eventTag: eventTag , opinion: nil)
                        }else{
                            showDialog(row , eventTag: eventTag)
                        }
                    }
                }
            }else if tag == 2 {
                let row = sender.userInfo!["tag"] as! Int
                indexRow = row
                let json = arrApproval[row]
                if status == 2 {
                    approvalId = json["AuthorizeId"].intValue
                    self.performSegue(withIdentifier: "toAuthorizeDetail", sender: self)
                }else{
                    if segmentedControl.selectedSegmentIndex < 3 {
                        approvalId = json["ApprovalId"].intValue
                        self.performSegue(withIdentifier: "toApprovalDetail", sender: self)
                    }else{
                        approvalId = json["AuthorizeId"].intValue
                        self.performSegue(withIdentifier: "toAuthorizeDetail", sender: self)
                    }
                }
                
            }else if tag == 3 {
                tableView.mj_header.beginRefreshing()
            }else if tag == 4 {
                if segmentedControl.isHidden == false {
                    let approvalCount = UserDefaults.standard.integer(forKey: "approvalCount")
                    let authorizeCount = UserDefaults.standard.integer(forKey: "authorizeCount")
                    if segmentedControl.numberOfSegments == 2 {
                        segmentedControl.setTitle("待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", forSegmentAt: 0)
                    }else if segmentedControl.numberOfSegments == 3 {
                        segmentedControl.setTitle("待审\(approvalCount > 0 ? "(\(approvalCount))" : "")", forSegmentAt: 1)
                    }else if segmentedControl.numberOfSegments == 5 {
                        if approvalCount > 0 {
                            segmentedControl.setTitle("待审\(approvalCount > 0 ? "(\(approvalCount))" : "")", forSegmentAt: 1)
                        }
                        if authorizeCount > 0 {
                            segmentedControl.setTitle("待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", forSegmentAt: 3)
                        }
                    }
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "MTabBarViewController"), object: 13)
                }
            }else if tag == 5 {
                changeSegmentControl()
            }
        }
    }
    
    func showDialog(_ row : Int , eventTag : Int) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "RejectApproval") as! RejectApprovalViewController
        let dialog = PopupDialog(viewController: controller)
        controller.popupDialog = dialog
        if let contentView = dialog.view as? PopupDialogContainerView {
            contentView.cornerRadius = 10
        }
        let cancelButton = PopupDialogButton(title: "取消", dismissOnTap: true, action: {
            
        })
        cancelButton.buttonColor = UIColor.hexStringToColor(BACKGROUNDCOLOR)
        cancelButton.titleColor = UIColor.hexStringToColor(FONTCOLOR)
        cancelButton.titleFont = UIFont.systemFont(ofSize: 15)
        
        let okButton = PopupDialogButton(title: "确认", dismissOnTap: true, action: { [weak self] in
            let text = controller.reasonTextView.text
            if text!.characters.count > 0 && text?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count > 0 {
                self?.auditPassOrReject(row, eventTag: eventTag , opinion: text)
            }else{
                self?.auditPassOrReject(row, eventTag: eventTag , opinion: nil)
            }
            })
        okButton.buttonColor = UIColor.hexStringToColor(TEXTCOLOR)
        okButton.titleColor = UIColor.white
        okButton.titleFont = UIFont.systemFont(ofSize: 15)
        dialog.addButtons([cancelButton , okButton])
        dialog.buttonAlignment = .horizontal
        self.present(dialog, animated: true, completion: {
            
        })
    }
    
    func changeSegmentControl() {
        if let info = UserDefaults.standard.object(forKey: "info") as? [String : AnyObject] {
            emptyView.isHidden = true
            let approvalCount = UserDefaults.standard.integer(forKey: "approvalCount")
            let authorizeCount = UserDefaults.standard.integer(forKey: "authorizeCount")
            if overrunOption.characters.count == 0 {
                approvalRequired = info["ApprovalRequired"] as! Bool
                overrunOption = info["OverrunOption"] as! String
                if approvalRequired && overrunOption == "WarningAndAuthorize" {
                    self.navigationItem.title = "审批授权"
                    segmentedControl.setTitle("待审\(approvalCount > 0 ? "(\(approvalCount))" : "")", forSegmentAt: 1)
                    segmentedControl.insertSegment(withTitle: "待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", at: 3, animated: false)
                    segmentedControl.insertSegment(withTitle: "已授权", at: 4, animated: false)
                    indicatorWidthLConstraint.constant = SCREENWIDTH / 5
                    segmentItemWidth = SCREENWIDTH / 5
                    status = 1
                    segmentedControl.selectedSegmentIndex = 0
                }else if approvalRequired && overrunOption != "WarningAndAuthorize" {
                    self.navigationItem.title = "审批"
                    indicatorWidthLConstraint.constant = SCREENWIDTH / 3
                    segmentItemWidth = SCREENWIDTH / 3
                    segmentedControl.selectedSegmentIndex = 0
                }else if overrunOption == "WarningAndAuthorize" {
                    self.navigationItem.title = "授权"
                    indicatorWidthLConstraint.constant = SCREENWIDTH / 2
                    segmentedControl.setTitle("待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", forSegmentAt: 0)
                    segmentedControl.setTitle("已授权", forSegmentAt: 1)
                    segmentedControl.removeSegment(at: 2, animated: false)
                    segmentItemWidth = SCREENWIDTH / 2
                    status = 2
                    segmentedControl.selectedSegmentIndex = 0
                }else{
                    self.navigationItem.title = "审批"
                    segmentedControl.isHidden = true
                    indicatorImageView.isHidden = true
                    lineImageView.isHidden = true
                    tableView.isHidden = true
                    emptyView.isHidden = false
                }
            }else{
                let approval = info["ApprovalRequired"] as! Bool
                let overrun = info["OverrunOption"] as! String
                if approval != approvalRequired || overrun != overrunOption {
                    if approval && overrun == "WarningAndAuthorize" {
                        self.navigationItem.title = "审批授权"
                        segmentedControl.isHidden = false
                        indicatorImageView.isHidden = false
                        lineImageView.isHidden = false
                        tableView.isHidden = false
                        indicatorWidthLConstraint.constant = SCREENWIDTH / 5
                        segmentItemWidth = SCREENWIDTH / 5
                        status = 1
                        if segmentedControl.numberOfSegments == 5 {
                            
                        }else if segmentedControl.numberOfSegments == 3 {
                            segmentedControl.insertSegment(withTitle: "待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", at: 3, animated: false)
                            segmentedControl.insertSegment(withTitle: "已授权", at: 4, animated: false)
                        }else if segmentedControl.numberOfSegments == 2{
                            segmentedControl.setTitle("我发起", forSegmentAt: 0)
                            segmentedControl.setTitle("待审\(approvalCount > 0 ? "(\(approvalCount))" : "")", forSegmentAt: 1)
                            segmentedControl.insertSegment(withTitle: "已审", at: 2, animated: false)
                            segmentedControl.insertSegment(withTitle: "待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", at: 3, animated: false)
                            segmentedControl.insertSegment(withTitle: "已授权", at: 4, animated: false)
                        }
                        segmentedControl.selectedSegmentIndex = 0
                    }else if approval && overrun != "WarningAndAuthorize" {
                        self.navigationItem.title = "审批"
                        segmentedControl.isHidden = false
                        indicatorImageView.isHidden = false
                        lineImageView.isHidden = false
                        tableView.isHidden = false
                        indicatorWidthLConstraint.constant = SCREENWIDTH / 3
                        segmentItemWidth = SCREENWIDTH / 3
                        status = 0
                        if segmentedControl.numberOfSegments == 5 {
                            segmentedControl.removeSegment(at: 4, animated: false)
                            segmentedControl.removeSegment(at: 3, animated: false)
                        }else if segmentedControl.numberOfSegments == 3 {
                            
                        }else if segmentedControl.numberOfSegments == 2{
                            segmentedControl.setTitle("我发起", forSegmentAt: 0)
                            segmentedControl.setTitle("待审\(approvalCount > 0 ? "(\(approvalCount))" : "")", forSegmentAt: 1)
                            segmentedControl.insertSegment(withTitle: "已审", at: 2, animated: false)
                        }
                        segmentedControl.selectedSegmentIndex = 0
                    }else if overrun == "WarningAndAuthorize" {
                        self.navigationItem.title = "授权"
                        segmentedControl.isHidden = false
                        indicatorImageView.isHidden = false
                        lineImageView.isHidden = false
                        tableView.isHidden = false
                        indicatorWidthLConstraint.constant = SCREENWIDTH / 2
                        segmentItemWidth = SCREENWIDTH / 2
                        status = 2
                        if segmentedControl.numberOfSegments == 5 {
                            segmentedControl.removeSegment(at: 4, animated: false)
                            segmentedControl.removeSegment(at: 3, animated: false)
                            segmentedControl.removeSegment(at: 2, animated: false)
                        }else if segmentedControl.numberOfSegments == 3 {
                            segmentedControl.setTitle("待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", forSegmentAt: 0)
                            segmentedControl.setTitle("已授权", forSegmentAt: 1)
                            segmentedControl.removeSegment(at: 2, animated: false)
                        }else if segmentedControl.numberOfSegments == 2{
                            
                        }
                        segmentedControl.selectedSegmentIndex = 0
                    }else{
                        self.navigationItem.title = "审批"
                        segmentedControl.isHidden = true
                        indicatorImageView.isHidden = true
                        lineImageView.isHidden = true
                        tableView.isHidden = true
                        pageNumber = 1
                        arrApproval.removeAll()
                        tableView.reloadData()
                        emptyView.isHidden = false
                    }
                    
                }
                approvalRequired = approval
                overrunOption = overrun
            }
        }
    }

}



