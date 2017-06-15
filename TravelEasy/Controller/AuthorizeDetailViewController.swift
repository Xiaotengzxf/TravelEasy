//
//  AuthorizeDetailViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/9.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON
import Toaster
import Alamofire

class AuthorizeDetailViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var goDateLabel: UILabel!
    @IBOutlet weak var backDateLabel: UILabel!
    @IBOutlet weak var goTimeLabel: UILabel!
    @IBOutlet weak var backTimeLabel: UILabel!
    @IBOutlet weak var goAirportLabel: UILabel!
    @IBOutlet weak var backAirportLabel: UILabel!
    @IBOutlet weak var flightInfoLabel: UILabel!
    @IBOutlet weak var stopLocationLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var authorizedView: UIView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var authorizedViewHeightLConstraint: NSLayoutConstraint!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var refuseButton: UIButton!
    var authorizeId = 0
    var authorizeDetail : JSON!

    override func viewDidLoad() {
        super.viewDidLoad()
        agreeButton.setBackgroundImage(UIImage.imageWithColor(BUTTONBGCOLORHIGHLIGHT), for: .highlighted)
        refuseButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).cgColor
        refuseButton.setTitleColor(UIColor.white, for: .highlighted)
        refuseButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), for: .disabled)
        refuseButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), for: .highlighted)
        getAuthorizeDetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAuthorizeDetail() {
        let manager = URLCollection()
        let hud = showHUD()
        if let token = manager.validateToken() {
            manager.getRequest(manager.getAuthorizeDetail, params: ["authorizeId" : authorizeId], headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                hud.hide(animated: true)
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        self?.authorizeDetail = model["AuthorizeDetail"]
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
        statusLabel.text = authorizeDetail["Status"].string
        if let status = authorizeDetail["Status"].string, status == "待授权" {
            toolView.isHidden = false
        }
        cityLabel.text = authorizeDetail["FlightOrder" , "Route" , "Departure" , "CityName"].stringValue + "-" + authorizeDetail["FlightOrder" , "Route" , "Arrival" , "CityName"].stringValue
        discountLabel.text = "\(Float(authorizeDetail["FlightOrder" , "Route" , "Discount"].intValue) / 10)折\(authorizeDetail["FlightOrder" , "Route" ,"BunkName"].stringValue)"
        priceLabel.text = "¥\(authorizeDetail["FlightOrder" , "FeeInfo" , "PaymentAmount"].intValue)"
        let departureDateTime = authorizeDetail["FlightOrder" , "Route" , "Departure" , "DateTime"].stringValue.components(separatedBy: " ")
        if departureDateTime.count == 2 {
            goTimeLabel.text = departureDateTime[1]
            let time = departureDateTime[0].components(separatedBy: "-").map{UInt($0)}
            if time.count == 3 {
                let calender = XZCalendarModel.calendarDay(withYear: time[0]!, month: time[1]!, day: time[2]!)
                goDateLabel.text = "\((calender?.month)! > 10 ? "\(calender?.month)" : "0\(calender?.month)")月\((calender?.day)! > 10 ? "\(calender?.day)" : "0\(calender?.day)")日\(calender?.getWeek()!)"
            }
        }
        let ArrivalDateTime = authorizeDetail["FlightOrder" , "Route" , "Arrival" , "DateTime"].stringValue.components(separatedBy: " ")
        if ArrivalDateTime.count == 2 {
            backTimeLabel.text = ArrivalDateTime[1]
            let time = ArrivalDateTime[0].components(separatedBy: "-").map{UInt($0)}
            if time.count == 3 {
                let calender = XZCalendarModel.calendarDay(withYear: time[0]!, month: time[1]!, day: time[2]!)
                backDateLabel.text = "\((calender?.month)! > 10 ? "\(calender?.month)" : "0\(calender?.month)")月\((calender?.day)! > 10 ? "\(calender?.day)" : "0\(calender?.day)")日\(calender?.getWeek()!)"
            }
        }
        goAirportLabel.text = "\(authorizeDetail["FlightOrder" , "Route" , "Departure" , "AirportName"].stringValue)机场\(authorizeDetail["FlightOrder" , "Route" , "Departure" , "Terminal"].stringValue)"
        backAirportLabel.text = "\(authorizeDetail["FlightOrder" , "Route" , "Arrival" , "AirportName"].stringValue)机场\(authorizeDetail["FlightOrder" , "Route" , "Arrival" , "Terminal"].stringValue)"
        flightInfoLabel.text = "\(authorizeDetail["FlightOrder" , "Route" ,"AirlineName"].stringValue)\(authorizeDetail["FlightOrder" , "Route" ,"FlightNo"].stringValue) | \(authorizeDetail["FlightOrder" , "Route" , "PlanTypeCode"].stringValue)"
        if let stopCity = authorizeDetail["FlightOrder" , "Route" ,"StopCity"].string {
            stopLocationLabel.text = "经停 \(stopCity)"
        }
        let fee = authorizeDetail["FlightOrder" , "FeeInfo" , "TicketFee"].intValue
        let airportFee = authorizeDetail["FlightOrder" , "FeeInfo" , "AirportFee"].intValue
        let oilFee = authorizeDetail["FlightOrder" , "FeeInfo" , "OilFee"].intValue
        let accidentFee = authorizeDetail["FlightOrder" , "FeeInfo" , "InsuranceFee"].intValue
        let attributeString = NSMutableAttributedString(string: "票价 ¥\(fee) 机建 ¥\(airportFee) 燃油 ¥\(oilFee) 保险 ¥\(accidentFee)")
        var length = String(fee).characters.count + 3
        attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(2, length))
        var location = length + 4
        length = String(airportFee).characters.count + 3
        attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(location, length))
        location += length + 2
        length = String(oilFee).characters.count + 3
        attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(location, length))
        location += length + 2
        length = String(accidentFee).characters.count + 2
        attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(location, length))
        feeLabel.attributedText = attributeString
        
        let lowPriceWaringMsg = authorizeDetail["FlightOrder" ,"Passenger" , "TravelPolicyInfo" , "LowPriceWarningMsg"].stringValue
        let preNDaysWarningMsg = authorizeDetail["FlightOrder" ,"Passenger" , "TravelPolicyInfo" , "PreNDaysWarningMsg"].stringValue
        let discountLimitWarningMsg = authorizeDetail["FlightOrder" ,"Passenger" , "TravelPolicyInfo" , "DiscountLimitWarningMsg"].stringValue
        let twoCabinWarningMsg = authorizeDetail["FlightOrder" ,"Passenger" , "TravelPolicyInfo" , "TwoCabinWarningMsg"].stringValue
        var warnString = ""
        if lowPriceWaringMsg.characters.count > 0 {
            warnString += lowPriceWaringMsg
            warnString += "\n"
        }
        if preNDaysWarningMsg.characters.count > 0 {
            warnString += preNDaysWarningMsg
            warnString += "\n"
        }
        if discountLimitWarningMsg.characters.count > 0 {
            warnString += discountLimitWarningMsg
            warnString += "\n"
        }
        if twoCabinWarningMsg.characters.count > 0 {
            warnString += twoCabinWarningMsg
        }
        if warnString.characters.count == 0 {
            warnString = "无"
        }
        let attributeText = NSMutableAttributedString(string: warnString)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        attributeText.addAttributes([NSParagraphStyleAttributeName : style], range: NSMakeRange(0, attributeText.length))
        warningLabel.attributedText = attributeText
        
        let approvalHisView = Bundle.main.loadNibNamed("ApprovalHisView", owner: nil, options: nil)!.last as! ApprovalHisView
        approvalHisView.translatesAutoresizingMaskIntoConstraints = false
        authorizedView.addSubview(approvalHisView)
        authorizedView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[approvalHisView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["approvalHisView" : approvalHisView]))
        authorizedView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(spacing)-[approvalHisView(65)]", options: NSLayoutFormatOptions(), metrics: ["spacing" : 0], views: ["approvalHisView" : approvalHisView]))
        
        approvalHisView.nameLabel.text = authorizeDetail["AuditEmployeeName"].stringValue.characters.count > 0 ? authorizeDetail["AuditEmployeeName"].stringValue : authorizeDetail["AuditPositionEmployeeNames"].stringValue
        approvalHisView.departmentLabel.text = authorizeDetail["AuditPositionName"].stringValue
        if let auditOpinion = authorizeDetail["AuditOpinion"].string, auditOpinion.characters.count > 0 {
            approvalHisView.statucLabel.text = authorizeDetail["Status"].stringValue + "(\(auditOpinion))"
        }else{
            approvalHisView.statucLabel.text = authorizeDetail["Status"].stringValue
        }
        
        approvalHisView.timeLabel.text = authorizeDetail["AuditDate"].stringValue

        approvalHisView.lineImageView.isHidden = true

        if let status = authorizeDetail["Status"].string {
            if status == "待授权" {
                approvalHisView.iconImageView.image = UIImage(named: "icon_order_approve2")
            }else if status == "授权通过" {
                approvalHisView.iconImageView.image = UIImage(named: "icon_order_approve1")
            }else if status == "授权拒绝" {
                approvalHisView.iconImageView.image = UIImage(named: "icon_order_approve3")
            }else{
                approvalHisView.iconImageView.image = UIImage(named: "icon_order_approve4")
            }
        }
        
        authorizedViewHeightLConstraint.constant = 65
    }

    @IBAction func agreeOrder(_ sender: AnyObject) {
        handleEvent(true)
    }
    
    @IBAction func cancelOrder(_ sender: AnyObject) {
        handleEvent(false)
    }
    
    func handleEvent(_ isAgree : Bool) {
        let hud = showHUD()
        let manager = URLCollection()
        if let token = manager.validateToken() {
            var urlString = ""
            var params : [String : Any] = [:]
            urlString = isAgree ? manager.auditPassAuthorize : manager.auditRejectAuthorize
            params["AuthorizeId"] = authorizeId
            
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

}
