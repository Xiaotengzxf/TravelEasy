//
//  ApprovalDetailViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/8.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON
import Toaster
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


class ApprovalDetailViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var approvalNoLabel: UILabel!
    @IBOutlet weak var applyForDateLabel: UILabel!
    @IBOutlet weak var travelmanLabel: UILabel!
    @IBOutlet weak var travelDateLabel: UILabel!
    @IBOutlet weak var travelCityLabel: UILabel!
    @IBOutlet weak var transportLabel: UILabel!
    @IBOutlet weak var airportAndHotelView: UIView!
    @IBOutlet weak var hisView: UIView!
    @IBOutlet weak var airportAndHotelViewHieghtLContraint: NSLayoutConstraint!
    @IBOutlet weak var hisViewHeightLConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var refuseButton: UIButton!
    var approvalId = 0
    var isOwn = false
    var approvalDetail : JSON!

    override func viewDidLoad() {
        super.viewDidLoad()
        agreeButton.setBackgroundImage(UIImage.imageWithColor(BUTTONBGCOLORHIGHLIGHT), for: .highlighted)
        refuseButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).cgColor
        refuseButton.setTitleColor(UIColor.white, for: .highlighted)
        refuseButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), for: .disabled)
        refuseButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), for: .highlighted)
        if isOwn {
            refuseButton.isHidden = true
            agreeButton.setTitle("撤销", for: UIControlState())
        }
        getApprovalDetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getApprovalDetail() {
        let manager = URLCollection()
        let hud = showHUD()
        if let token = manager.validateToken() {
            manager.getRequest(manager.getApprovalDetail, params: ["approvalId" : approvalId], headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                hud.hide(animated: true)
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        self?.approvalDetail = model["ApprovalDetail"]
                        self?.refreshView()
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
    
    func refreshView() {
        statusLabel.text = approvalDetail["Status"].string
        if let status = approvalDetail["Status"].string {
            if status == "审批通过" {
                statusImageView.image = UIImage(named: "icon_approve_agree")
            }else if status == "审批拒绝" {
                statusImageView.image = UIImage(named: "icon_approve_refuse")
            }else if status == "待审批" {
                statusImageView.image = UIImage(named: "icon_approve_ing")
            }else{
                statusImageView.image = UIImage(named: "icon_approve_cannel")
            }
        }
        reasonLabel.text = approvalDetail["TravelReason"].string
        approvalNoLabel.text = approvalDetail["ApprovalNo"].string
        applyForDateLabel.text = approvalDetail["CreateTime"].string
        travelmanLabel.text = approvalDetail["EmployeeName"].string
        travelDateLabel.text = changeDateType(approvalDetail["TravelDateStart"].stringValue) + "-" + changeDateType(approvalDetail["TravelDateEnd"].stringValue)
        travelCityLabel.text = approvalDetail["TravelDestination"].string
        transportLabel.text = approvalDetail["Transport"].string
        var orders : [JSON] = []
        if let flightOrders = approvalDetail["FlightOrders"].array {
            for (index , item) in flightOrders.enumerated() {
                let approvalFlightOrderView = Bundle.main.loadNibNamed("ApprovalFlightOrderView", owner: nil, options: nil)!.last as! ApprovalFlightOrderView
                approvalFlightOrderView.translatesAutoresizingMaskIntoConstraints = false
                airportAndHotelView.addSubview(approvalFlightOrderView)
                airportAndHotelView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[approvalFlightOrderView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["approvalFlightOrderView" : approvalFlightOrderView]))
                airportAndHotelView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(spacing)-[approvalFlightOrderView(86)]", options: NSLayoutFormatOptions(), metrics: ["spacing" : 86 * index], views: ["approvalFlightOrderView" : approvalFlightOrderView]))
                
                approvalFlightOrderView.cityLabel.text = item["DepartureCityName"].stringValue + "-" + item["ArrivalCityName"].stringValue
                approvalFlightOrderView.discountLabel.text = "\(Float(item["Discount"].intValue) / 10)折\(item["BunkName"].stringValue)"
                approvalFlightOrderView.airportLabel.text = item["AirlineName"].stringValue + item["FlightNo"].stringValue
                approvalFlightOrderView.dateLabel.text = item["FlightDate"].stringValue
                approvalFlightOrderView.priceLabel.text = "¥\(item["Amount"].intValue)"
            }
            
            orders += flightOrders
        }
        var hotelOrders : [JSON] = []
        if let array = approvalDetail["HotelOrders"].array {
            for (index , item) in array.enumerated() {
                let approvalHotelOrderView = Bundle.main.loadNibNamed("ApprovalHotelOrderView", owner: nil, options: nil)!.last as! ApprovalHotelOrderView
                approvalHotelOrderView.translatesAutoresizingMaskIntoConstraints = false
                airportAndHotelView.addSubview(approvalHotelOrderView)
                airportAndHotelView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[approvalHotelOrderView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["approvalHotelOrderView" : approvalHotelOrderView]))
                airportAndHotelView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(spacing)-[approvalHotelOrderView(60)]", options: NSLayoutFormatOptions(), metrics: ["spacing" : 60 * index + orders.count * 86], views: ["approvalHotelOrderView" : approvalHotelOrderView]))
                
                approvalHotelOrderView.cityLabel.text = item["HotelName"].stringValue
                approvalHotelOrderView.BedTypeLabel.text = item["BedType"].stringValue
                approvalHotelOrderView.dateLabel.text = item["CheckInDate"].stringValue + "-" + item["CheckOutDate"].stringValue
                approvalHotelOrderView.priceLabel.text = "¥\(item["Amount"].intValue)"
            }
            hotelOrders += array
        }
        airportAndHotelViewHieghtLContraint.constant = CGFloat(orders.count) * 86 + CGFloat(hotelOrders.count) * 60
        if let array = approvalDetail["ApprovalHis"].array {
            for (index , item) in array.enumerated() {
                let approvalHisView = Bundle.main.loadNibNamed("ApprovalHisView", owner: nil, options: nil)!.last as! ApprovalHisView
                approvalHisView.translatesAutoresizingMaskIntoConstraints = false
                hisView.addSubview(approvalHisView)
                hisView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[approvalHisView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["approvalHisView" : approvalHisView]))
                hisView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(spacing)-[approvalHisView(65)]", options: NSLayoutFormatOptions(), metrics: ["spacing" : 65 * index], views: ["approvalHisView" : approvalHisView]))
                
                approvalHisView.nameLabel.text = item["AuditEmployeeName"].stringValue.characters.count > 0 ? item["AuditEmployeeName"].stringValue : item["AuditPositionEmployeeNames"].stringValue
                approvalHisView.departmentLabel.text = item["AuditPositionName"].stringValue
                if let auditOpinion = item["AuditOpinion"].string, auditOpinion.characters.count > 0 {
                    approvalHisView.statucLabel.text = item["Status"].stringValue + "(\(auditOpinion))"
                }else{
                    approvalHisView.statucLabel.text = item["Status"].stringValue
                }
                
                approvalHisView.timeLabel.text = item["AuditDate"].stringValue
                if index == 0 {
                    approvalHisView.lineImageView.isHidden = true
                }
                // 待审批，审批通过，审批拒绝，已撤消
                if let status = item["Status"].string {
                    if status == "待审批" {
                        approvalHisView.iconImageView.image = UIImage(named: "icon_order_approve2")
                    }else if status == "审批通过" {
                        approvalHisView.iconImageView.image = UIImage(named: "icon_order_approve1")
                    }else if status == "审批拒绝" {
                        approvalHisView.iconImageView.image = UIImage(named: "icon_order_approve3")
                    }else{
                        approvalHisView.iconImageView.image = UIImage(named: "icon_order_approve4")
                    }
                }
            }
            hisViewHeightLConstraint.constant = 65 * CGFloat(array.count)
        }
        if let status = approvalDetail["Status"].string, status == "待审批" {
            toolView.isHidden = false
        }else{
            toolView.isHidden = true
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
    
    @IBAction func agreeApproval(_ sender: AnyObject) {
        handleEvent(true , opinion: nil)
    }
    
    @IBAction func refuseApproval(_ sender: AnyObject) {
        showDialog()
    }

    func handleEvent(_ isAgree : Bool , opinion : String?) {
        let hud = showHUD()
        let manager = URLCollection()
        if let token = manager.validateToken() {
            var urlString = ""
            var params : [String : Any] = [:]
            if isOwn {
                urlString = manager.cancelApproval
            }else{
                urlString = isAgree ? manager.auditPassApproval : manager.auditRejectApproval
            }
            params["approvalId"] = approvalId
            if opinion != nil && opinion?.characters.count > 0 {
                params["opinion"] = opinion!
            }
            manager.postRequest(urlString, params: params , encoding : URLEncoding.default , headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                hud.hide(animated: true)
                if let json = jsonObject {
                    if let code = json["Code"].int, code == 0 {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ApprovalListViewController"), object: 3)
                        self?.navigationController?.popViewController(animated: true)
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
    
    func showDialog() {
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
                self?.handleEvent(false , opinion: text)
            }else{
                self?.handleEvent(false , opinion: nil)
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

}
