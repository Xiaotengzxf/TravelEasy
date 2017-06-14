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
import JLToast
import MBProgressHUD
import PopupDialog

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
        segmentedControl.setBackgroundImage(UIImage.imageWithColor("ffffff"), forState: .Normal, barMetrics: .Default)
        segmentedControl.setBackgroundImage(UIImage.imageWithColor("ffffff"), forState: .Selected, barMetrics: .Default)
        segmentedControl.setBackgroundImage(UIImage.imageWithColor("ffffff"), forState: .Highlighted, barMetrics: .Default)
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(FONTCOLOR) , NSFontAttributeName : UIFont.systemFontOfSize(13)], forState: .Normal)
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor("0071C4") , NSFontAttributeName : UIFont.systemFontOfSize(13)], forState: .Selected)
        segmentedControl.setDividerImage(UIImage.imageWithColor("ffffff"), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
        
        emptyView = EmptyManager.getInstance.insertEmptyView(with: self.view, top: 0, emptyType: .noFuction)
        emptyView.hidden = true
        tableEmptyView = EmptyManager.getInstance.insertEmptyView(with: self.view, top: 44, emptyType: .noData)
        tableEmptyView.hidden = true
        
        if let info = NSUserDefaults.standardUserDefaults().objectForKey("info") as? [String : AnyObject] {
            approvalRequired = info["ApprovalRequired"] as! Bool
            overrunOption = info["OverrunOption"] as! String
            let approvalCount = NSUserDefaults.standardUserDefaults().integerForKey("approvalCount")
            let authorizeCount = NSUserDefaults.standardUserDefaults().integerForKey("authorizeCount")
            if approvalRequired && overrunOption == "WarningAndAuthorize" {
                self.navigationItem.title = "审批授权"
                segmentedControl.setTitle("待审\(approvalCount > 0 ? "(\(approvalCount))" : "")", forSegmentAtIndex: 1)
                segmentedControl.insertSegmentWithTitle("待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", atIndex: 3, animated: false)
                segmentedControl.insertSegmentWithTitle("已授权", atIndex: 4, animated: false)
                indicatorWidthLConstraint.constant = SCREENWIDTH / 5
                segmentItemWidth = SCREENWIDTH / 5
                status = 1
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "填写计划", style: .Plain, target: self, action: #selector(ApprovalListViewController.createNewApproval))
            }else if approvalRequired && overrunOption != "WarningAndAuthorize" {
                self.navigationItem.title = "审批"
                indicatorWidthLConstraint.constant = SCREENWIDTH / 3
                segmentItemWidth = SCREENWIDTH / 3
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "填写计划", style: .Plain, target: self, action: #selector(ApprovalListViewController.createNewApproval))
                segmentedControl.setTitle("待审\(approvalCount > 0 ? "(\(approvalCount))" : "")", forSegmentAtIndex: 1)
            }else if overrunOption == "WarningAndAuthorize" {
                self.navigationItem.title = "授权"
                indicatorWidthLConstraint.constant = SCREENWIDTH / 2
                segmentedControl.setTitle("待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", forSegmentAtIndex: 0)
                segmentedControl.setTitle("已授权", forSegmentAtIndex: 1)
                segmentedControl.removeSegmentAtIndex(2, animated: false)
                segmentItemWidth = SCREENWIDTH / 2
                status = 2
            }else{
                self.navigationItem.title = "审批"
                segmentedControl.hidden = true
                indicatorImageView.hidden = true
                lineImageView.hidden = true
                tableView.hidden = true
                emptyView.hidden = false
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ApprovalListViewController.handleNotification(_:)), name: "ApprovalListViewController", object: nil)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     单选器
     
     - parameter sender: segmentControl
     */
    @IBAction func changeValue(sender: AnyObject) {
        indicatorLeftLConstraint.constant = CGFloat(segmentedControl.selectedSegmentIndex) * segmentItemWidth
        if segmentedControl.selectedSegmentIndex == 0 {
            if segmentedControl.numberOfSegments > 2 {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "填写计划", style: .Plain, target: self, action: #selector(ApprovalListViewController.createNewApproval))
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
        self.performSegueWithIdentifier("toNewApproval", sender: self)
    }
    
    func getApprovalList() {
        self.tableEmptyView.hidden = true
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
                    if let code = json["Code"].int where code == 0 {
                        let name = self!.status == 2 || self!.segmentedControl.selectedSegmentIndex >= 3 ? "Authorizes" : "Approvals"
                        if let approvals = json[name].array {
                            self?.arrApproval += approvals
                            self?.tableView.reloadData()
                            self?.totalCount = json["TotalCount"].intValue
                            if self?.arrApproval.count == self?.totalCount {
                                self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                            }
                            let approvalCount = NSUserDefaults.standardUserDefaults().integerForKey("approvalCount")
                            let authorizeCount = NSUserDefaults.standardUserDefaults().integerForKey("authorizeCount")
                            if self!.status == 2 {
                                if self!.segmentedControl.selectedSegmentIndex == 0 {
                                    if authorizeCount != self!.totalCount {
                                        NSUserDefaults.standardUserDefaults().setInteger(self!.totalCount, forKey: "authorizeCount")
                                        NSUserDefaults.standardUserDefaults().synchronize()
                                        NSNotificationCenter.defaultCenter().postNotificationName("ApprovalListViewController", object: 4)
                                    }
                                }
                            }else{
                                if self!.segmentedControl.selectedSegmentIndex == 1 {
                                    if approvalCount != self!.totalCount {
                                        NSUserDefaults.standardUserDefaults().setInteger(self!.totalCount, forKey: "approvalCount")
                                        NSUserDefaults.standardUserDefaults().synchronize()
                                        NSNotificationCenter.defaultCenter().postNotificationName("ApprovalListViewController", object: 4)
                                    }
                                }else if self!.segmentedControl.selectedSegmentIndex == 3 {
                                    if authorizeCount != self!.totalCount {
                                        NSUserDefaults.standardUserDefaults().setInteger(self!.totalCount, forKey: "authorizeCount")
                                        NSUserDefaults.standardUserDefaults().synchronize()
                                        NSNotificationCenter.defaultCenter().postNotificationName("ApprovalListViewController", object: 4)
                                    }
                                }
                            }
                            if self!.pageNumber == 1 && approvals.count == 0 {
                                self!.tableEmptyView.hidden = false
                            }
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
    
    /**
     审批通过申请单
     
     - parameter row: 列
     */
    func auditPassOrReject(row : Int , eventTag : Int , opinion : String?)  {
        let hud = showHUD()
        let manager = URLCollection()
        if let token = manager.validateToken() {
            var urlString = ""
            var params : [String : AnyObject] = [:]
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
            manager.postRequest(urlString, params: params , encoding : .URLEncodedInURL , headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                hud.hideAnimated(true)
                if let json = jsonObject {
                    if let code = json["Code"].int where code == 0 {
                        self?.tableView.mj_header.beginRefreshing()
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
    
    func changeDateType(date : String) -> String {
        let array = date.componentsSeparatedByString("-")
        if array.count == 3 {
            return "\(array[0])年\(array[1])月\(array[2])日"
        }else{
            return date
        }
    }
    
    // MARK: - TableView DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrApproval.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ApprovalTableViewCell
        cell.tag = indexPath.row
        let json = arrApproval[indexPath.row]
        if status == 2 {
            if segmentedControl.selectedSegmentIndex == 0 {
                cell.nameLabel.text = "\(json["TravellerName"].stringValue)的订单需要您授权"
                cell.oneLabel.text = "出差地点"
                cell.oneContentLabel.text = json["OrderDesc"].stringValue.componentsSeparatedByString(" ")[1]
                cell.twoLabel.text = "出差时间"
                cell.twoContentLabel.text = json["OrderDesc"].stringValue.componentsSeparatedByString(" ")[0]
                cell.statusLabel.text = json["Status"].stringValue
                if let status = json["Status"].string where status == "待订单授权"{
                    cell.cancelButton.hidden = false
                    cell.okButton.hidden = false
                    cell.cancelButton.setTitle("拒绝", forState: .Normal)
                    cell.okButton.setTitle("同意", forState: .Normal)
                }else{
                    cell.cancelButton.hidden = true
                    cell.okButton.hidden = true
                }
            }else{
                cell.nameLabel.text = "\(json["AskEmployeeName"].stringValue)的订单授权"
                cell.oneLabel.text = "出差地点"
                cell.oneContentLabel.text = json["OrderDesc"].stringValue.componentsSeparatedByString(" ")[1]
                cell.twoLabel.text = "出差时间"
                cell.twoContentLabel.text = json["OrderDesc"].stringValue.componentsSeparatedByString(" ")[0]
                cell.statusLabel.text = json["Status"].stringValue
                cell.cancelButton.hidden = true
                cell.okButton.hidden = true
            }
        }else{
            if segmentedControl.selectedSegmentIndex == 0 {
                cell.nameLabel.text = "\(json["AskEmployeeName"].stringValue)的审批"
                cell.oneLabel.text = "出差地点"
                cell.oneContentLabel.text = json["TravelDestination"].stringValue
                cell.twoLabel.text = "出差时间"
                cell.twoContentLabel.text = changeDateType(json["TravelDateStart"].stringValue) + "-" + changeDateType(json["TravelDateEnd"].stringValue)
                cell.statusLabel.text = json["Status"].stringValue
                if let status = json["Status"].string where status == "待审批"{
                    cell.okButton.hidden = false
                    cell.okButton.setTitle("撤销", forState: .Normal)
                }else{
                    cell.okButton.hidden = true
                }
                cell.cancelButton.hidden = true
            }else if segmentedControl.selectedSegmentIndex == 1 {
                cell.nameLabel.text = "\(json["AskEmployeeName"].stringValue)的出差审批需要您审批"
                cell.oneLabel.text = "出差地点"
                cell.oneContentLabel.text = json["TravelDestination"].stringValue
                cell.twoLabel.text = "出差时间"
                cell.twoContentLabel.text = changeDateType(json["TravelDateStart"].stringValue) + "-" + changeDateType(json["TravelDateEnd"].stringValue)
                cell.statusLabel.text = json["Status"].stringValue
                if let status = json["Status"].string where status == "待审批"{
                    cell.cancelButton.hidden = false
                    cell.okButton.hidden = false
                    cell.cancelButton.setTitle("拒绝", forState: .Normal)
                    cell.okButton.setTitle("同意", forState: .Normal)
                }else{
                    cell.cancelButton.hidden = true
                    cell.okButton.hidden = true
                }
                
            }else if segmentedControl.selectedSegmentIndex == 2 {
                cell.nameLabel.text = "\(json["AskEmployeeName"].stringValue)的审批"
                cell.oneLabel.text = "出差地点"
                cell.oneContentLabel.text = json["TravelDestination"].stringValue
                cell.twoLabel.text = "出差时间"
                cell.twoContentLabel.text = changeDateType(json["TravelDateStart"].stringValue) + "-" + changeDateType(json["TravelDateEnd"].stringValue)
                cell.statusLabel.text = "审批完成(\(json["Status"].stringValue))"
                cell.cancelButton.hidden = true
                cell.okButton.hidden = true
            }else if segmentedControl.selectedSegmentIndex == 3 {
                cell.nameLabel.text = "\(json["TravellerName"].stringValue)的订单需要您授权"
                cell.oneLabel.text = "出差地点"
                cell.oneContentLabel.text = json["OrderDesc"].stringValue.componentsSeparatedByString(" ")[1]
                cell.twoLabel.text = "出差时间"
                cell.twoContentLabel.text = json["OrderDesc"].stringValue.componentsSeparatedByString(" ")[0]
                cell.statusLabel.text = json["Status"].stringValue
                if let status = json["Status"].string where status == "待授权"{
                    cell.cancelButton.hidden = false
                    cell.okButton.hidden = false
                    cell.cancelButton.setTitle("拒绝", forState: .Normal)
                    cell.okButton.setTitle("同意", forState: .Normal)
                }else{
                    cell.cancelButton.hidden = true
                    cell.okButton.hidden = true
                }
            }else{
                cell.nameLabel.text = "\(json["TravellerName"].stringValue)的订单授权"
                cell.oneLabel.text = "出差地点"
                cell.oneContentLabel.text = json["OrderDesc"].stringValue.componentsSeparatedByString(" ")[1]
                cell.twoLabel.text = "出差时间"
                cell.twoContentLabel.text = json["OrderDesc"].stringValue.componentsSeparatedByString(" ")[0]
                cell.statusLabel.text = json["Status"].stringValue
                cell.cancelButton.hidden = true
                cell.okButton.hidden = true
                
            }
        }
        cell.selectionStyle = .None
        return cell
    }
    
    // MARK : - TableView Delegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let controller = segue.destinationViewController as? ApprovalDetailViewController {
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
            
        }else if let controller = segue.destinationViewController as? AuthorizeDetailViewController {
            controller.authorizeId = approvalId
            if arrApproval.count > 0 {
                let json = arrApproval[indexRow]
                controller.title = "\(json["TravellerName"].stringValue)的订单授权"
            }
        }
    }
    
    
    func handleNotification(sender : NSNotification)  {
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
                    self.performSegueWithIdentifier("toAuthorizeDetail", sender: self)
                }else{
                    if segmentedControl.selectedSegmentIndex < 3 {
                        approvalId = json["ApprovalId"].intValue
                        self.performSegueWithIdentifier("toApprovalDetail", sender: self)
                    }else{
                        approvalId = json["AuthorizeId"].intValue
                        self.performSegueWithIdentifier("toAuthorizeDetail", sender: self)
                    }
                }
                
            }else if tag == 3 {
                tableView.mj_header.beginRefreshing()
            }else if tag == 4 {
                if segmentedControl.hidden == false {
                    let approvalCount = NSUserDefaults.standardUserDefaults().integerForKey("approvalCount")
                    let authorizeCount = NSUserDefaults.standardUserDefaults().integerForKey("authorizeCount")
                    if segmentedControl.numberOfSegments == 2 {
                        segmentedControl.setTitle("待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", forSegmentAtIndex: 0)
                    }else if segmentedControl.numberOfSegments == 3 {
                        segmentedControl.setTitle("待审\(approvalCount > 0 ? "(\(approvalCount))" : "")", forSegmentAtIndex: 1)
                    }else if segmentedControl.numberOfSegments == 5 {
                        if approvalCount > 0 {
                            segmentedControl.setTitle("待审\(approvalCount > 0 ? "(\(approvalCount))" : "")", forSegmentAtIndex: 1)
                        }
                        if authorizeCount > 0 {
                            segmentedControl.setTitle("待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", forSegmentAtIndex: 3)
                        }
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("MTabBarViewController", object: 13)
                }
            }else if tag == 5 {
                changeSegmentControl()
            }
        }
    }
    
    func showDialog(row : Int , eventTag : Int) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("RejectApproval") as! RejectApprovalViewController
        let dialog = PopupDialog(viewController: controller)
        controller.popupDialog = dialog
        if let contentView = dialog.view as? PopupDialogContainerView {
            contentView.cornerRadius = 10
        }
        let cancelButton = PopupDialogButton(title: "取消", dismissOnTap: true, action: {
            
        })
        cancelButton.buttonColor = UIColor.hexStringToColor(BACKGROUNDCOLOR)
        cancelButton.titleColor = UIColor.hexStringToColor(FONTCOLOR)
        cancelButton.titleFont = UIFont.systemFontOfSize(15)
        
        let okButton = PopupDialogButton(title: "确认", dismissOnTap: true, action: { [weak self] in
            let text = controller.reasonTextView.text
            if text.characters.count > 0 && text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count > 0 {
                self?.auditPassOrReject(row, eventTag: eventTag , opinion: text)
            }else{
                self?.auditPassOrReject(row, eventTag: eventTag , opinion: nil)
            }
            })
        okButton.buttonColor = UIColor.hexStringToColor(TEXTCOLOR)
        okButton.titleColor = UIColor.whiteColor()
        okButton.titleFont = UIFont.systemFontOfSize(15)
        dialog.addButtons([cancelButton , okButton])
        dialog.buttonAlignment = .Horizontal
        self.presentViewController(dialog, animated: true, completion: {
            
        })
    }
    
    func changeSegmentControl() {
        if let info = NSUserDefaults.standardUserDefaults().objectForKey("info") as? [String : AnyObject] {
            emptyView.hidden = true
            let approvalCount = NSUserDefaults.standardUserDefaults().integerForKey("approvalCount")
            let authorizeCount = NSUserDefaults.standardUserDefaults().integerForKey("authorizeCount")
            if overrunOption.characters.count == 0 {
                approvalRequired = info["ApprovalRequired"] as! Bool
                overrunOption = info["OverrunOption"] as! String
                if approvalRequired && overrunOption == "WarningAndAuthorize" {
                    self.navigationItem.title = "审批授权"
                    segmentedControl.setTitle("待审\(approvalCount > 0 ? "(\(approvalCount))" : "")", forSegmentAtIndex: 1)
                    segmentedControl.insertSegmentWithTitle("待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", atIndex: 3, animated: false)
                    segmentedControl.insertSegmentWithTitle("已授权", atIndex: 4, animated: false)
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
                    segmentedControl.setTitle("待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", forSegmentAtIndex: 0)
                    segmentedControl.setTitle("已授权", forSegmentAtIndex: 1)
                    segmentedControl.removeSegmentAtIndex(2, animated: false)
                    segmentItemWidth = SCREENWIDTH / 2
                    status = 2
                    segmentedControl.selectedSegmentIndex = 0
                }else{
                    self.navigationItem.title = "审批"
                    segmentedControl.hidden = true
                    indicatorImageView.hidden = true
                    lineImageView.hidden = true
                    tableView.hidden = true
                    emptyView.hidden = false
                }
            }else{
                let approval = info["ApprovalRequired"] as! Bool
                let overrun = info["OverrunOption"] as! String
                if approval != approvalRequired || overrun != overrunOption {
                    if approval && overrun == "WarningAndAuthorize" {
                        self.navigationItem.title = "审批授权"
                        segmentedControl.hidden = false
                        indicatorImageView.hidden = false
                        lineImageView.hidden = false
                        tableView.hidden = false
                        indicatorWidthLConstraint.constant = SCREENWIDTH / 5
                        segmentItemWidth = SCREENWIDTH / 5
                        status = 1
                        if segmentedControl.numberOfSegments == 5 {
                            
                        }else if segmentedControl.numberOfSegments == 3 {
                            segmentedControl.insertSegmentWithTitle("待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", atIndex: 3, animated: false)
                            segmentedControl.insertSegmentWithTitle("已授权", atIndex: 4, animated: false)
                        }else if segmentedControl.numberOfSegments == 2{
                            segmentedControl.setTitle("我发起", forSegmentAtIndex: 0)
                            segmentedControl.setTitle("待审\(approvalCount > 0 ? "(\(approvalCount))" : "")", forSegmentAtIndex: 1)
                            segmentedControl.insertSegmentWithTitle("已审", atIndex: 2, animated: false)
                            segmentedControl.insertSegmentWithTitle("待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", atIndex: 3, animated: false)
                            segmentedControl.insertSegmentWithTitle("已授权", atIndex: 4, animated: false)
                        }
                        segmentedControl.selectedSegmentIndex = 0
                    }else if approval && overrun != "WarningAndAuthorize" {
                        self.navigationItem.title = "审批"
                        segmentedControl.hidden = false
                        indicatorImageView.hidden = false
                        lineImageView.hidden = false
                        tableView.hidden = false
                        indicatorWidthLConstraint.constant = SCREENWIDTH / 3
                        segmentItemWidth = SCREENWIDTH / 3
                        status = 0
                        if segmentedControl.numberOfSegments == 5 {
                            segmentedControl.removeSegmentAtIndex(4, animated: false)
                            segmentedControl.removeSegmentAtIndex(3, animated: false)
                        }else if segmentedControl.numberOfSegments == 3 {
                            
                        }else if segmentedControl.numberOfSegments == 2{
                            segmentedControl.setTitle("我发起", forSegmentAtIndex: 0)
                            segmentedControl.setTitle("待审\(approvalCount > 0 ? "(\(approvalCount))" : "")", forSegmentAtIndex: 1)
                            segmentedControl.insertSegmentWithTitle("已审", atIndex: 2, animated: false)
                        }
                        segmentedControl.selectedSegmentIndex = 0
                    }else if overrun == "WarningAndAuthorize" {
                        self.navigationItem.title = "授权"
                        segmentedControl.hidden = false
                        indicatorImageView.hidden = false
                        lineImageView.hidden = false
                        tableView.hidden = false
                        indicatorWidthLConstraint.constant = SCREENWIDTH / 2
                        segmentItemWidth = SCREENWIDTH / 2
                        status = 2
                        if segmentedControl.numberOfSegments == 5 {
                            segmentedControl.removeSegmentAtIndex(4, animated: false)
                            segmentedControl.removeSegmentAtIndex(3, animated: false)
                            segmentedControl.removeSegmentAtIndex(2, animated: false)
                        }else if segmentedControl.numberOfSegments == 3 {
                            segmentedControl.setTitle("待授权\(authorizeCount > 0 ? "(\(authorizeCount))" : "")", forSegmentAtIndex: 0)
                            segmentedControl.setTitle("已授权", forSegmentAtIndex: 1)
                            segmentedControl.removeSegmentAtIndex(2, animated: false)
                        }else if segmentedControl.numberOfSegments == 2{
                            
                        }
                        segmentedControl.selectedSegmentIndex = 0
                    }else{
                        self.navigationItem.title = "审批"
                        segmentedControl.hidden = true
                        indicatorImageView.hidden = true
                        lineImageView.hidden = true
                        tableView.hidden = true
                        pageNumber = 1
                        arrApproval.removeAll()
                        tableView.reloadData()
                        emptyView.hidden = false
                    }
                    
                }
                approvalRequired = approval
                overrunOption = overrun
            }
        }
    }

}



