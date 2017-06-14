//
//  ChooseApprovalNoTableViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/3.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import SwiftyJSON
import MBProgressHUD
import JLToast

class ChooseApprovalNoTableViewController: UITableViewController {
    
    var approvals : [JSON] = []
    var flightInfo : JSON!
    var employeeId : Int = 0
    var delegate : ChooseApprovalNoTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        getApprovals()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getApprovals() {
        let manager = URLCollection()
        let hud = showHUD()
        if let token = manager.validateToken() {
            manager.getRequest(manager.getApprovals, params: [ "start" : flightInfo["Departure" , "DateTime"].stringValue , "end" : flightInfo["Arrival" , "DateTime"].stringValue , "pageSize" : 1000 , "pageNumber" : 1 , "travelEmployeeId" : employeeId], headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                hud.hideAnimated(true)
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        self?.approvals += model["Approvals"].arrayValue
                        self?.tableView.reloadData()
                    }else{
                        if let message = model["Message"].string {
                            JLToast.makeText(message).show()
                        }
                    }
                }else{
                    JLToast.makeText("网络不给力，请检查网络！").show()
                }
                })
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return approvals.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let approvalNoLabel  = cell.contentView.viewWithTag(1) as! UILabel
        let cityLabel = cell.contentView.viewWithTag(2) as! UILabel
        let dateLabel = cell.contentView.viewWithTag(3) as! UILabel
        approvalNoLabel.text = approvals[indexPath.row]["ApprovalNo"].string
        cityLabel.text = approvals[indexPath.row]["TravelDestination"].string
        dateLabel.text = "\(approvals[indexPath.row]["TravelDateStart"].stringValue)至\(approvals[indexPath.row]["TravelDateEnd"].stringValue)"
        cell.accessoryView = UIImageView(image: UIImage(named: "icon_radio_un"))
        cell.selectionStyle = .None
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let approvalNoLabel  = cell?.contentView.viewWithTag(1) as! UILabel
        let cityLabel = cell?.contentView.viewWithTag(2) as! UILabel
        let dateLabel = cell?.contentView.viewWithTag(3) as! UILabel
        approvalNoLabel.textColor = UIColor.hexStringToColor(TEXTCOLOR)
        cityLabel.textColor = UIColor.hexStringToColor(TEXTCOLOR)
        dateLabel.textColor = UIColor.hexStringToColor(TEXTCOLOR)
        cell?.accessoryView = UIImageView(image: UIImage(named: "icon_radio_pr"))
        self.performSelector(#selector(ChooseApprovalNoTableViewController.chooseApprovalSuccess(_:)), withObject: indexPath, afterDelay: 0.2)
    }

    func chooseApprovalSuccess(indexPath : NSIndexPath)  {
        delegate?.chooseApprovalNoWithJSON(approvals[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
        
    }
}

protocol ChooseApprovalNoTableViewControllerDelegate {
    func chooseApprovalNoWithJSON(approval : JSON)
}
