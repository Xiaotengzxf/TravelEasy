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
import Toaster

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
            manager.getRequest(manager.getApprovals, params: [ "start" : flightInfo["Departure" , "DateTime"].stringValue as AnyObject , "end" : flightInfo["Arrival" , "DateTime"].stringValue as AnyObject , "pageSize" : 1000 as AnyObject , "pageNumber" : 1 as AnyObject , "travelEmployeeId" : employeeId as AnyObject], headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                hud.hide(animated: true)
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        self?.approvals += model["Approvals"].arrayValue
                        self?.tableView.reloadData()
                    }else{
                        if let message = model["Message"].string {
                            Toast(text: message).show()
                        }
                    }
                }else{
                    Toast(text: "网络不给力，请检查网络！").show()
                }
                })
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return approvals.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let approvalNoLabel  = cell.contentView.viewWithTag(1) as! UILabel
        let cityLabel = cell.contentView.viewWithTag(2) as! UILabel
        let dateLabel = cell.contentView.viewWithTag(3) as! UILabel
        approvalNoLabel.text = approvals[indexPath.row]["ApprovalNo"].string
        cityLabel.text = approvals[indexPath.row]["TravelDestination"].string
        dateLabel.text = "\(approvals[indexPath.row]["TravelDateStart"].stringValue)至\(approvals[indexPath.row]["TravelDateEnd"].stringValue)"
        cell.accessoryView = UIImageView(image: UIImage(named: "icon_radio_un"))
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        let approvalNoLabel  = cell?.contentView.viewWithTag(1) as! UILabel
        let cityLabel = cell?.contentView.viewWithTag(2) as! UILabel
        let dateLabel = cell?.contentView.viewWithTag(3) as! UILabel
        approvalNoLabel.textColor = UIColor.hexStringToColor(TEXTCOLOR)
        cityLabel.textColor = UIColor.hexStringToColor(TEXTCOLOR)
        dateLabel.textColor = UIColor.hexStringToColor(TEXTCOLOR)
        cell?.accessoryView = UIImageView(image: UIImage(named: "icon_radio_pr"))
        self.perform(#selector(ChooseApprovalNoTableViewController.chooseApprovalSuccess(_:)), with: indexPath, afterDelay: 0.2)
    }

    func chooseApprovalSuccess(_ indexPath : IndexPath)  {
        delegate?.chooseApprovalNoWithJSON(approvals[indexPath.row])
        self.navigationController?.popViewController(animated: true)
        
    }
}

protocol ChooseApprovalNoTableViewControllerDelegate {
    func chooseApprovalNoWithJSON(_ approval : JSON)
}
