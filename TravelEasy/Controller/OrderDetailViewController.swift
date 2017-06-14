//
//  OrderDetailViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/15.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import SwiftyJSON
import JLToast
import PopupDialog

class OrderDetailViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var orderAuthorizeLabel: UILabel!
    @IBOutlet weak var superAuthorizeLabel: UILabel!
    @IBOutlet weak var totalMoneyLabel: UILabel!
    @IBOutlet weak var orderNoLabel: UILabel!
    @IBOutlet weak var orderTypeLabel: UILabel!
    @IBOutlet weak var payStatusLabel: UILabel!
    @IBOutlet weak var passengersLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var contacterLabel: UILabel!
    @IBOutlet weak var contacterMobileLabel: UILabel!
    @IBOutlet weak var insuranceLabel: UILabel!
    @IBOutlet weak var insuranceFeeLabel: UILabel!
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
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var refundButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var netCheckInButton: UIButton!
    @IBOutlet weak var payToCancelLConstraint: NSLayoutConstraint!
    @IBOutlet weak var refundToPayLConstraint: NSLayoutConstraint!
    @IBOutlet weak var changeToRefundLConstraint: NSLayoutConstraint!
    @IBOutlet weak var netCheckInToChangeLConsraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsViewHeightLConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var payButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var refundButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var changeButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var netCheckInButtonWidthConstraint: NSLayoutConstraint!
    var orderDetail : JSON! // 订单列表传递过来的订单详情
    var orderModel : JSON! // 接口获取到的订单详情
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getOrderDetail()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     获取订单详情
     */
    func getOrderDetail() {
        let manager = URLCollection()
        let hud = showHUD()
        if let token = manager.validateToken() {
            manager.getRequest(manager.getOrderDetail, params: ["orderId" : orderDetail["OrderId"].intValue], headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                hud.hideAnimated(true)
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        self?.orderModel = model["Order"]
                        self?.refreshView()
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
    
    func refreshView()  {
        statusLabel.text = orderModel["Status"].string
        let lowPriceWaringMsg = orderModel["Passenger" , "TravelPolicyInfo" , "LowPriceWarningMsg"].stringValue
        let preNDaysWarningMsg = orderModel["Passenger" , "TravelPolicyInfo" , "PreNDaysWarningMsg"].stringValue
        let discountLimitWarningMsg = orderModel["Passenger" , "TravelPolicyInfo" , "DiscountLimitWarningMsg"].stringValue
        let twoCabinWarningMsg = orderModel["Passenger" , "TravelPolicyInfo" , "TwoCabinWarningMsg"].stringValue
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
        
        cityLabel.text = orderModel[ "Route" , "Departure" , "CityName"].stringValue + "-" + orderModel[ "Route" , "Arrival" , "CityName"].stringValue
        let discount = orderModel[ "Route" , "Discount"].intValue
        discountLabel.text = "\(discount < 100 ? "\(Float(discount) / 10)折" : "全价")\(orderModel[ "Route" ,"BunkName"].stringValue)"
        priceLabel.attributedText = "¥\(orderModel[ "FeeInfo" , "PaymentAmount"].intValue)".attributeMoneyText()
        let departureDateTime = orderModel[ "Route" , "Departure" , "DateTime"].stringValue.componentsSeparatedByString(" ")
        if departureDateTime.count == 2 {
            goTimeLabel.text = departureDateTime[1]
            let time = departureDateTime[0].componentsSeparatedByString("-").map{UInt($0)}
            if time.count == 3 {
                let calender = XZCalendarModel.calendarDayWithYear(time[0]!, month: time[1]!, day: time[2]!)
                goDateLabel.text = "\(calender.month > 10 ? "\(calender.month)" : "0\(calender.month)")月\(calender.day > 10 ? "\(calender.day)" : "0\(calender.day)")日\(calender.getWeek())"
            }
        }
        let ArrivalDateTime = orderModel[ "Route" , "Arrival" , "DateTime"].stringValue.componentsSeparatedByString(" ")
        if ArrivalDateTime.count == 2 {
            backTimeLabel.text = ArrivalDateTime[1]
            let time = ArrivalDateTime[0].componentsSeparatedByString("-").map{UInt($0)}
            if time.count == 3 {
                let calender = XZCalendarModel.calendarDayWithYear(time[0]!, month: time[1]!, day: time[2]!)
                backDateLabel.text = "\(calender.month > 10 ? "\(calender.month)" : "0\(calender.month)")月\(calender.day > 10 ? "\(calender.day)" : "0\(calender.day)")日\(calender.getWeek())"
            }
        }
        goAirportLabel.text = "\(orderModel[ "Route" , "Departure" , "AirportName"].stringValue)机场\(orderModel[ "Route" , "Departure" , "Terminal"].stringValue)"
        backAirportLabel.text = "\(orderModel[ "Route" , "Arrival" , "AirportName"].stringValue)机场\(orderModel[ "Route" , "Arrival" , "Terminal"].stringValue)"
        flightInfoLabel.text = "\(orderModel[ "Route" ,"AirlineName"].stringValue)\(orderModel[ "Route" ,"FlightNo"].stringValue) | \(orderModel[ "Route" , "PlanTypeCode"].stringValue)"
        if let stopCity = orderModel[ "Route" ,"StopCity"].string {
            stopLocationLabel.text = "经停 \(stopCity)"
        }
        let fee = orderModel[ "FeeInfo" , "TicketFee"].intValue
        let airportFee = orderModel[ "FeeInfo" , "AirportFee"].intValue
        let oilFee = orderModel[ "FeeInfo" , "OilFee"].intValue
        let accidentFee = orderModel[ "FeeInfo" , "InsuranceFee"].intValue
        let returnTicketFee = orderModel["FeeInfo" , "ReturnTicketFee"].intValue
        let changeTicketFee = orderModel["FeeInfo" , "ChangeTicketFee"].intValue
        let ticketServiceFee = orderModel["FeeInfo" , "TicketServiceFee"].intValue
        var feeDesc = ""
        if fee != 0 {
            feeDesc += "票价 ¥\(fee) "
        }
        if airportFee != 0 {
            feeDesc += "机建 ¥\(airportFee) "
        }
        if oilFee != 0 {
            feeDesc += "燃油 ¥\(oilFee) "
        }
        if accidentFee != 0 {
            feeDesc += "保险 ¥\(accidentFee) "
        }
        if returnTicketFee != 0 {
            feeDesc += "退票手续费 ¥\(returnTicketFee) "
        }
        if changeTicketFee != 0 {
            feeDesc += "改签手续费 ¥\(changeTicketFee) "
        }
        if ticketServiceFee != 0 {
            feeDesc += "服务费 ¥\(ticketServiceFee) "
        }
        let attributeString = NSMutableAttributedString(string: feeDesc )
        var length = 0
        var location = 2
        if fee != 0 {
            length = String(fee).characters.count + 3
            attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(location, length))
        }
        if airportFee != 0 {
            location += length + 2
            length = String(airportFee).characters.count + 3
            attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(location, length))
        }
        if oilFee != 0 {
            location += length + 2
            length = String(oilFee).characters.count + 3
            attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(location, length))
        }
        if accidentFee != 0 {
            location += length + 2
            length = String(accidentFee).characters.count + 3
            attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(location, length))
        }
        if returnTicketFee != 0 {
            location += length + 5
            length = String(returnTicketFee).characters.count + 3
            attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(location, length))
        }
        if changeTicketFee != 0 {
            location += length + 5
            length = String(changeTicketFee).characters.count + 3
            attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(location, length))
        }
        if ticketServiceFee != 0 {
            location += length + 3
            length = String(ticketServiceFee).characters.count + 3
            attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(location, length))
        }
        feeLabel.attributedText = attributeString
        orderAuthorizeLabel.text = orderModel["ApprovalStatus"].string
        superAuthorizeLabel.text = orderModel["AuthorizeStatus"].string
        totalMoneyLabel.attributedText = "¥\(orderModel["FeeInfo" , "PaymentAmount"].intValue)".attributeMoneyText()
        orderNoLabel.text = orderModel["OrderNo"].string
        orderTypeLabel.text = orderModel["TravelType"].string
        payStatusLabel.text = orderModel["PaymentStatus"].string
        passengersLabel.text = orderModel["Passenger" , "PassengerName"].stringValue
        departmentLabel.text = orderModel["Passenger" , "BelongedDeptName"].stringValue
        contacterLabel.text = orderModel["ContactName"].string
        contacterMobileLabel.text = orderModel["ContactMobile"].string
        insuranceLabel.text = "航意险"
        let insuranceFee = orderModel["FeeInfo" , "InsuranceFee"].intValue
        let attributeFee = NSMutableAttributedString(string: "¥\(insuranceFee)／份 × \(orderModel["Passenger" , "InsuranceCount"].intValue)")
        attributeFee.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(0, 1 + String(insuranceFee).characters.count))
        insuranceFeeLabel.attributedText = attributeFee
        
        cancelButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).CGColor
        cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        cancelButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), forState: .Disabled)
        cancelButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), forState: .Highlighted)
        payButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).CGColor
        payButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        payButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), forState: .Disabled)
        payButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), forState: .Highlighted)
        refundButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).CGColor
        refundButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        refundButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), forState: .Disabled)
        refundButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), forState: .Highlighted)
        changeButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).CGColor
        changeButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        changeButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), forState: .Disabled)
        changeButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), forState: .Highlighted)
        netCheckInButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).CGColor
        netCheckInButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        netCheckInButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), forState: .Disabled)
        netCheckInButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), forState: .Highlighted)
        
        let canCancel = orderModel["CanCancel"].boolValue
        let canPayment = orderModel["CanPayment"].boolValue
        let canReturn = orderModel["CanReturn"].boolValue
        let canChange = orderModel["CanChange"].boolValue
        let canNetCheckIn = orderModel["CanNetCheckIn"].boolValue
        if canCancel {
            cancelButton.hidden = false
            cancelButtonWidthConstraint.constant = 50
            payToCancelLConstraint.constant = 10
        }else{
            cancelButton.hidden = true
            cancelButtonWidthConstraint.constant = 0
            payToCancelLConstraint.constant = 0
        }
        if canPayment {
            payButton.hidden = false
            payButtonWidthConstraint.constant = 50
            refundToPayLConstraint.constant = 10
        }else{
            payButton.hidden = true
            payButtonWidthConstraint.constant = 0
            refundToPayLConstraint.constant = 0
        }
        if canReturn {
            refundButton.hidden = false
            refundButtonWidthConstraint.constant = 50
            changeToRefundLConstraint.constant = 10
        }else{
            refundButton.hidden = true
            refundButtonWidthConstraint.constant = 0
            changeToRefundLConstraint.constant = 0
        }
        if canChange {
            changeButton.hidden = false
            changeButtonWidthConstraint.constant = 50
            netCheckInToChangeLConsraint.constant = 10
        }else{
            changeButton.hidden = true
            changeButtonWidthConstraint.constant = 0
            netCheckInToChangeLConsraint.constant = 0
        }
        if canNetCheckIn {
            netCheckInButton.hidden = false
            netCheckInButtonWidthConstraint.constant = 70
        }else{
            netCheckInButton.hidden = true
            netCheckInButtonWidthConstraint.constant = 0
        }
        if !canCancel && !canPayment && !canReturn && !canChange && !canNetCheckIn {
            buttonsView.hidden = true
            buttonsViewHeightLConstraint.constant = 0
        }else{
            buttonsView.hidden = false
            buttonsViewHeightLConstraint.constant = 44
        }

    }

    @IBAction func handleOrderEvent(sender: AnyObject) {
        let button = sender as! UIButton
        switch button.tag {
        case 1:
            cancelFlight()
        case 2:
            payOrder()
        case 3:
            if let controller = storyboard?.instantiateViewControllerWithIdentifier("OrderEvent") as? OrderEventTableViewController {
                controller.orderId = orderDetail["OrderId"].intValue
                controller.title = "退票"
                self.navigationController?.pushViewController(controller, animated: true)
            }
        case 4:
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("OrderEvent") as! OrderEventTableViewController
            controller.flag = 1
            controller.orderDetail = orderDetail
            controller.title = "改签原因"
            self.navigationController?.pushViewController(controller, animated: true)
            
        case 5:
            if let controller = storyboard?.instantiateViewControllerWithIdentifier("NetCheckIn") as? NetCheckInViewController {
                controller.orderId = orderDetail["OrderId"].intValue
                self.navigationController?.pushViewController(controller, animated: true)
            }
        default:
            fatalError()
        }
    }
    
    /**
     取消航班
     
     */
    func cancelFlight() {
        let alertController = UIAlertController(title: "提示", message: "您确定要取消该订单", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (action) in
            
        }))
        alertController.addAction(UIAlertAction(title: "确定", style: .Default, handler: {[weak self] (action) in
            let orderId = self!.orderModel["OrderId"].intValue
            self?.requestCancelFlight(orderId)
            }))
        self.presentViewController(alertController, animated: true) {
            
        }
    }
    
    /**
     根据订单号提交取消订单
     
     - parameter orderId: 订单号
     */
    func requestCancelFlight(orderId : Int)  {
        let manager = URLCollection()
        if let token = manager.validateToken() {
            let hud = showHUD()
            manager.postRequest(manager.cancelApply, params: ["orderId" : orderId] , encoding : .URLEncodedInURL, headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                hud.hideAnimated(true)
                if let json = jsonObject {
                    if let code = json["Code"].int  where code == 0 {
                        JLToast.makeText("取消成功").show()
                        self?.navigationController?.popViewControllerAnimated(true)
                        NSNotificationCenter.defaultCenter().postNotificationName("OrderListTableViewController", object: 3)
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
     支付订单
     */
    func payOrder() {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("ConfirmOrder") as! ConfirmOrderViewController
        controller.passengerName = orderDetail["PassengerName"].stringValue
        controller.travelLine = orderDetail["DepartureCityName"].stringValue + "-" + orderDetail["ArrivalCityName"].stringValue
        controller.date = orderDetail["DepartureDateTime"].stringValue + " 出发"
        controller.money = "¥\(orderDetail["PaymentAmount"].intValue)"
        
        let dialog = PopupDialog(viewController: controller)
        controller.popupDidalog = dialog
        if let contentView = dialog.view as? PopupDialogContainerView {
            contentView.cornerRadius = 10
        }
        let cancelButton = PopupDialogButton(title: "取消", dismissOnTap: true, action: {
            
        })
        cancelButton.buttonColor = UIColor.hexStringToColor(BACKGROUNDCOLOR)
        cancelButton.titleColor = UIColor.hexStringToColor(FONTCOLOR)
        cancelButton.titleFont = UIFont.systemFontOfSize(15)
        
        let okButton = PopupDialogButton(title: "确认支付", dismissOnTap: true, action: { [weak self] in
            self?.askOrderConfirmByCorpCredit(self!.orderDetail["OrderId"].intValue)
            
            })
        okButton.buttonColor = UIColor.hexStringToColor(TEXTCOLOR)
        okButton.titleColor = UIColor.whiteColor()
        okButton.titleFont = UIFont.systemFontOfSize(15)
        dialog.addButtons([cancelButton , okButton])
        dialog.buttonAlignment = .Horizontal
        self.presentViewController(dialog, animated: true, completion: {
            
        })
    }
    
    /**
     支付成功确认
     
     - parameter askOrderId: 确认单号
     */
    func askOrderConfirmByCorpCredit(askOrderId : Int) {
        let manager = URLCollection()
        let hud = showHUD()
        if let token = manager.validateToken() {
            manager.postRequest(manager.askOrderConfirmByCorpCredit, params: [ "askOrderId" : askOrderId], encoding : .URLEncodedInURL ,headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                hud.hideAnimated(true)
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        JLToast.makeText("支付成功").show()
                        self?.navigationController?.popViewControllerAnimated(true)
                        NSNotificationCenter.defaultCenter().postNotificationName("OrderListTableViewController", object: 3)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    

}
