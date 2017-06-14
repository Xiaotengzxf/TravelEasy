//
//  WriteOrderViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/1.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import SwiftyJSON
import JLToast
import MBProgressHUD
import PopupDialog

class WriteOrderViewController: UIViewController {

    var travelPolicy : JSON! // 去的差旅标准
    var backTravelPolicy : JSON! // 返的差旅标准
    var dicTravelSelected : [Int : Int]! // 去选中的原因
    var dicBackTravelSelected : [Int : Int]! // 返选中的原因
    var flightInfo : JSON! // 航程信息
    var backFlightInfo : JSON! // 返程信息
    var indexPath : NSIndexPath! // 索引
    var backIndexPath : NSIndexPath! // 返航索引
    var goDate : NSDate!
    var backDate : NSDate!
    var fee = 0
    var airportFee = 0
    var oilFee = 0
    var accidentFee = 0
    var delayFee = 0
    var arrEmployee : [JSON] = []
    var email = ""
    var canBookingForOthers = false
    var airInsuranceRequired = false
    var isGreenChannel = false
    var approvalRequired = false
    var isProjectRequired = false
    var flag = 0
    var reason : String!
    var bottomDetailCount = 0 // 底部明细费用大于0的数量
    var bHiddenLine = false
    
    @IBOutlet weak var billTipView: UIView!
    @IBOutlet weak var payWayView: UIView!
    @IBOutlet weak var accidentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var accidentView: UIView!
    @IBOutlet weak var ticketPriceLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var goImageView: UIImageView!
    @IBOutlet weak var goDateAndBunkLabel: UILabel!
    @IBOutlet weak var goAirportLabel: UILabel!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var backDateAndBunkLabel: UILabel!
    @IBOutlet weak var backAirportLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var returnAndChnageButton: UIButton!
    @IBOutlet weak var accidentInsuranceLabel: UILabel!
    @IBOutlet weak var contacterTextfield: UITextField!
    @IBOutlet weak var mobileTextfield: UITextField!
    @IBOutlet weak var passengersView: UIView!
    @IBOutlet weak var totalMoneyLabel: UILabel!
    @IBOutlet weak var passengersViewHeightLConstraint: NSLayoutConstraint!
    @IBOutlet weak var singleFeeLabel: UILabel!
    @IBOutlet weak var airportFeeLabel: UILabel!
    @IBOutlet weak var airportFeeTipLabel: UILabel!
    @IBOutlet weak var airportFeeTipTopLConstraint: NSLayoutConstraint!
    @IBOutlet weak var oilFeeLabel: UILabel!
    @IBOutlet weak var oilFeeTipLabel: UILabel!
    @IBOutlet weak var accidentFeeLabel: UILabel!
    @IBOutlet weak var accidentFeeTipLabel: UILabel!
    @IBOutlet weak var accidentFeeTipTopLConstraint: NSLayoutConstraint!
    @IBOutlet weak var oilFeeTipTopLConstraint: NSLayoutConstraint!
    @IBOutlet weak var serviceFeeLabel: UILabel!
    @IBOutlet weak var serviceFeeTipLabel: UILabel!
    @IBOutlet weak var serviceFeeTipLConstraint: NSLayoutConstraint!
    @IBOutlet weak var feeDetailView: UIView!
    @IBOutlet weak var detailViewBottomLConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var accidentButton: UIButton!
    @IBOutlet weak var addPassengerButton: UIButton!
    @IBOutlet weak var dashedLineImageView: UIImageView!
    @IBOutlet weak var dashedLineTopLConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if flag != 1 {
            if indexPath != nil {
                indexPath = NSIndexPath(forRow: 0, inSection: indexPath.section)
            }
            if backIndexPath != nil {
                backIndexPath = NSIndexPath(forRow: 0, inSection: backIndexPath.section)
            }
            
        }
        print(flightInfo.dictionaryValue)
        self.title = "\(flightInfo["Departure" , "CityName"].stringValue)-\(flightInfo["Arrival" , "CityName"])(因公)"
        goDateAndBunkLabel.text = "\(dateToString(goDate)) \(flightInfo["Bunks" , indexPath.row , "BunkName"].stringValue)"
        goAirportLabel.text = "\(flightInfo["Departure" , "AirportName"].stringValue)机场\(flightInfo["Departure" , "Terminal"].stringValue)-\(flightInfo["Arrival" , "AirportName"].stringValue)机场\(flightInfo ["Arrival" , "Terminal"].stringValue)"
        fee = flightInfo["Bunks" , indexPath.row , "BunkPrice" , "FactBunkPrice"].intValue + (backIndexPath != nil ? backFlightInfo["Bunks" , backIndexPath.row , "BunkPrice" , "FactBunkPrice"].intValue : 0)
        airportFee = flightInfo["AirportFee"].intValue + (backIndexPath != nil ? backFlightInfo["AirportFee"].intValue : 0)
        oilFee = flightInfo["OilFee"].intValue + (backIndexPath != nil ? backFlightInfo["OilFee"].intValue : 0)
        accidentFee = flightInfo["InsuranceFeeUnitPrice"].intValue + (backIndexPath != nil ? backFlightInfo["InsuranceFeeUnitPrice"].intValue : 0)
        delayFee = flightInfo["TicketServiceFee"].intValue + (backIndexPath != nil ? backFlightInfo["TicketServiceFee"].intValue : 0)
        accidentInsuranceLabel.text = "¥\(backIndexPath != nil ? (accidentFee / 2) : accidentFee )/份"
        let attributeString = NSMutableAttributedString(string: "票价 ¥\(fee) 机建 ¥\(airportFee) 燃油 ¥\(oilFee)")
        var length = String(fee).characters.count + 3
        attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(2, length))
        var location = length + 4
        length = String(airportFee).characters.count + 3
        attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(location, length))
        location += length + 2
        length = String(oilFee).characters.count + 2
        attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(location, length))
        feeLabel.attributedText = attributeString
        
        if backIndexPath != nil {
            goImageView.hidden = false
            backImageView.hidden = false
            let backDateString = dateToString(backDate)
            let bunkName = backFlightInfo["Bunks" , backIndexPath.row , "BunkName"].stringValue
            backDateAndBunkLabel.text = "\(backDateString) \(bunkName)"
            backAirportLabel.text = "\(backFlightInfo["Departure" , "AirportName"].stringValue)机场\(backFlightInfo["Departure" , "Terminal"].stringValue)-\(backFlightInfo["Arrival" , "AirportName"].stringValue)机场\(backFlightInfo ["Arrival" , "Terminal"].stringValue)"
        }else{
            backImageView.hidden = true
        }
        if let info = NSUserDefaults.standardUserDefaults().objectForKey("info") as? [String : AnyObject] {
            contacterTextfield.text = info["EmployeeName"] as? String
            mobileTextfield.text = info["Mobile"] as? String
            email = info["Email"] as? String ?? ""
            airInsuranceRequired = info["AirInsuranceRequired"] as? Bool ?? false
            isGreenChannel = info["IsGreenChannel"] as? Bool ?? false
            approvalRequired = info["ApprovalRequired"] as? Bool ?? false
            isProjectRequired = info["IsProjectRequired"] as? Bool ?? false
            if airInsuranceRequired {
                accidentButton.selected = true
                accidentButton.userInteractionEnabled = false
            }
            if flag != 1 {
                canBookingForOthers = info["CanBookingForOthers"] as? Bool ?? false
                if !canBookingForOthers {
                    addPassengerButton.hidden = true
                    getEmployeeInfo(info["EmployeeId"] as! Int)
                }
            }
        }
        if flag == 1 {
            addPassengerButton.hidden = true
            payWayView.hidden = true
            billTipView.hidden = true
            addPassenger(travelPolicy)
            submitButton.setTitle("确认改签", forState: .Normal)
            ticketPriceLabel.text = "机票差价"
            accidentViewBottomConstraint.constant = -44
        }else{
            setTotalMoney()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WriteOrderViewController.handleNotification(_:)), name: "WriteOrderViewController", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func handleNotification(sender : NSNotification) {
        if let tag = sender.object as? Int {
            if tag == 1 {
                let json = JSON(sender.userInfo!)
                if json["isEdit"].boolValue {
                    let index = json["index"].intValue
                    var employee = json["employee"]
                    employee["DefaultCertType"].string = json["credentialType"].stringValue
                    employee["DefaultCertNo"].string = json["credentialNo"].stringValue
                    if approvalRequired {
                        employee["approval"] = json["approval"]
                    }
                    if isProjectRequired {
                        employee["project"] = json["project"]
                    }
                    arrEmployee[index] = employee
                    if let passengerView = passengersView.viewWithTag(index + 1) as? PassengerView {
                        assignDataForPassengerView(passengerView, json: employee)
                    }
                    
                }else{
                    addPassenger(json)
                }
            }else if tag == 2 {
                let tag = sender.userInfo!["tag"] as! Int
                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("EditEmployee") as! EditEmployeeViewController
                controller.employee = arrEmployee[tag - 1]
                controller.flightInfo = flightInfo
                controller.isEdit = true
                controller.index = tag - 1
                self.navigationController?.pushViewController(controller, animated: true)
            }else if tag == 3 {
                let tag = sender.userInfo!["tag"] as! Int
                let alertController = UIAlertController(title: "提示", message: "您确定要删除该乘机人", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (action) in
                    
                }))
                alertController.addAction(UIAlertAction(title: "确定", style: .Default, handler: {[weak self] (action) in
                    self?.arrEmployee.removeAtIndex(tag - 1)
                    if let passengerView = self?.passengersView.viewWithTag(tag) as? PassengerView {
                        passengerView.removeFromSuperview()
                    }
                    
                    if tag <= self!.arrEmployee.count {
                        for i in tag+1..<self!.arrEmployee.count+1 {
                            if let passengerView = self?.passengersView.viewWithTag(i) as? PassengerView {
                                passengerView.tag -= 1
                            }
                            for constraint in self!.passengersView.constraints {
                                if constraint.constant == CGFloat(30 + i * 75) {
                                    constraint.constant -= 75
                                }
                            }
                        }
                    }
                    self?.passengersViewHeightLConstraint.constant -= 75
                }))
                self.presentViewController(alertController, animated: true, completion: { 
                    
                })
            }
        }
    }
    
    // 添加乘机人
    func addPassenger(json : JSON)  {
        if arrEmployee.count > 0 {
            let name = getPassengerName(json)
            if name.characters.count > 0 {
                for employee in arrEmployee {
                    let employeename = getPassengerName(employee)
                    if name == employeename {
                        JLToast.makeText("不可以重复添加乘机人").show()
                        return
                    }
                }
            }
        }
        arrEmployee.append(json)
        let passengerView = NSBundle.mainBundle().loadNibNamed("PassengerView", owner: nil, options: nil)!.last as! PassengerView
        passengerView.translatesAutoresizingMaskIntoConstraints = false
        passengersView.addSubview(passengerView)
        passengerView.tag = arrEmployee.count
        passengersView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[passengerView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["passengerView" : passengerView]))
        passengersView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(spacing)-[passengerView(75)]", options: .DirectionLeadingToTrailing, metrics: ["spacing" : 30 + (arrEmployee.count - 1) * 75], views: ["passengerView" : passengerView]))
        
        assignDataForPassengerView(passengerView, json: json)
    }
    
    func getPassengerName(json : JSON) -> String {
        if flag == 1 {
            return ""
        }else{
            if canBookingForOthers == false {
                return ""
            }else{
                if let isUser = json["isUser"].bool where isUser {
                    return json["employee" , "Name"].stringValue
                }else{
                    return json["employee" , "EmployeeName"].stringValue
                }
            }
        }
    }
    
    func assignDataForPassengerView(passengerView : PassengerView , json : JSON) {
        if flag == 1 {
            passengerView.nameLabel.text = json["PassengerName"].string
            passengerView.deleteButton.hidden = true
            passengerView.detailButton.hidden = true
            passengerView.approvalTipLabel.hidden = true
            passengerView.departmentTipLabel.hidden = true
        }else{
            if canBookingForOthers == false {
                passengerView.nameLabel.text = json["EmployeeName"].string
                passengerView.departmentLabel.text = json["DepartmentName"].string
                passengerView.numberLabel.text = isGreenChannel ? "无" : (approvalRequired ? json["approval" , "ApprovalNo"].string : "无")
                passengerView.projectLabel.text = isProjectRequired ? json["project" , "ProjectName"].string : "无"
                passengerView.deleteButton.hidden = true
            }else{
                if let isUser = json["isUser"].bool where isUser {
                    passengerView.nameLabel.text = json["employee" , "Name"].string
                    passengerView.departmentLabel.text = json["employee" , "BelongedDepartmentName"].string
                }else{
                    passengerView.nameLabel.text = json["employee" , "EmployeeName"].string
                    passengerView.departmentLabel.text = json["employee" , "DepartmentName"].string
                    
                }
                passengerView.numberLabel.text = isGreenChannel ? "无" : (approvalRequired ? json["approval" , "ApprovalNo"].string : "无")
                passengerView.projectLabel.text = isProjectRequired ? json["project" , "ProjectName"].string : "无"
            }
        }
        passengersViewHeightLConstraint.constant = 30 + 75 * CGFloat(arrEmployee.count)
        setTotalMoney()
    }
    
    func setTotalMoney()  {
        let factPrice = flag == 1 ? travelPolicy["FactTicketPrice"].intValue : 0
        let extraFee = flag == 1 ? 0 : (airportFee + oilFee + ((accidentButton.selected ? accidentFee : 0) + delayFee))
        totalMoneyLabel.text = "¥\((fee + extraFee) * arrEmployee.count - factPrice)"
        singleFeeLabel.attributedText = setAttributeText("¥\(fee - factPrice)×\(arrEmployee.count)人")
        if airportFee <= 0 || flag == 1 {
            airportFeeLabel.hidden = true
            airportFeeTipLabel.hidden = true
            airportFeeLabel.attributedText = nil
            airportFeeTipLabel.text = nil
            airportFeeTipTopLConstraint.constant = 0
        }else{
            bottomDetailCount += 1
            airportFeeLabel.hidden = false
            airportFeeTipLabel.hidden = false
            airportFeeLabel.attributedText = setAttributeText("¥\(airportFee)×\(arrEmployee.count)人")
            airportFeeTipLabel.text = "机建"
            airportFeeTipTopLConstraint.constant = 10
        }
        if oilFee <= 0 || flag == 1 {
            oilFeeTipLabel.hidden = true
            oilFeeLabel.hidden = true
            oilFeeTipLabel.text = nil
            oilFeeLabel.attributedText = nil
            oilFeeTipTopLConstraint.constant = 0
        }else{
            bottomDetailCount += 1
            oilFeeTipLabel.hidden = false
            oilFeeLabel.hidden = false
            oilFeeTipLabel.text = "燃油"
            oilFeeLabel.attributedText = setAttributeText("¥\(oilFee)×\(arrEmployee.count)人")
            oilFeeTipTopLConstraint.constant = 10
        }
        var temp = 0
        if accidentFee <= 0 || flag == 1 {
            
            accidentFeeLabel.hidden = true
            accidentFeeTipLabel.hidden = true
            accidentFeeLabel.attributedText = nil
            accidentFeeTipLabel.text = nil
            accidentFeeTipTopLConstraint.constant = 0
        }else{
            temp += 1
            bottomDetailCount += 1
            accidentFeeLabel.hidden = false
            accidentFeeTipLabel.hidden = false
            accidentFeeLabel.attributedText = setAttributeText("¥\(accidentFee)×\(accidentButton.selected ? arrEmployee.count : 0)人")
            accidentFeeTipLabel.text = "航意险"
            accidentFeeTipTopLConstraint.constant = 10
        }
        if delayFee <= 0 || flag == 1 {
            
            serviceFeeLabel.hidden = true
            serviceFeeTipLabel.hidden = true
            serviceFeeTipLabel.text = nil
            serviceFeeLabel.attributedText = nil
            serviceFeeTipLConstraint.constant = 0
        }else{
            temp += 1
            bottomDetailCount += 1
            serviceFeeLabel.hidden = false
            serviceFeeTipLabel.hidden = false
            serviceFeeTipLabel.text = "服务费"
            serviceFeeLabel.attributedText = setAttributeText("¥\(delayFee)×\(arrEmployee.count)人")
            serviceFeeTipLConstraint.constant = 10
        }
        if temp > 0 {
            dashedLineImageView.hidden = false
            dashedLineTopLConstraint.constant = 10
            bHiddenLine = false
        }else{
            bHiddenLine = true
            dashedLineImageView.hidden = true
            dashedLineTopLConstraint.constant = 0
        }
    }
    
    func setAttributeText(text : String) -> NSMutableAttributedString {
        let attributeString = NSMutableAttributedString(string: text)
        attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(0, attributeString.length - 3))
        return attributeString
    }
    
    @IBAction func showFlightInfo(sender: AnyObject) {
        contacterTextfield.resignFirstResponder()
        mobileTextfield.resignFirstResponder()
        if backIndexPath != nil {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("ToAndFromAirline") as! ToAndFromAirlineViewController
            controller.flightInfo = flightInfo
            controller.backFlightInfo = backFlightInfo
            let dialog = PopupDialog(viewController: controller)
            controller.popupDialog = dialog
            if let contentView = dialog.view as? PopupDialogContainerView {
                contentView.cornerRadius = 10
            }
            presentViewController(dialog, animated: true, completion: {
                
            })
        }else{
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("ToAirline") as! ToAirlineViewController
            controller.flightInfo = flightInfo
            let dialog = PopupDialog(viewController: controller)
            controller.popupDialog = dialog
            if let contentView = dialog.view as? PopupDialogContainerView {
                contentView.cornerRadius = 10
            }
            presentViewController(dialog, animated: true, completion: {
                
            })
        }
    }

    @IBAction func addEmployee(sender: AnyObject) {
        contacterTextfield.resignFirstResponder()
        mobileTextfield.resignFirstResponder()
        self.performSegueWithIdentifier("toEdit", sender: self)
    }
    
    @IBAction func addAccidentInsuranceFee(sender: AnyObject) {
        contacterTextfield.resignFirstResponder()
        mobileTextfield.resignFirstResponder()
        accidentButton.selected = !accidentButton.selected
        setTotalMoney()
    }
 
    /**
     日期转字符串
     
     - parameter date: 日期
     
     - returns: 字符串
     */
    func dateToString(date : NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.stringFromDate(date)
        let dateArray = dateString.componentsSeparatedByString("-").map{UInt($0)!}
        let dateModel = XZCalendarModel.calendarDayWithYear(dateArray[0] ?? 0, month: dateArray[1] ?? 0, day: dateArray[2] ?? 0)
        return "\(dateModel.month < 10 ? "0\(dateModel.month )" : "\(dateModel.month)")月\(dateModel.day < 10 ? "0\(dateModel.day)" : "\(dateModel.day)")日\(dateModel.getWeek())"
    }
    
    @IBAction func sumbitOrder(sender: AnyObject) {
        contacterTextfield.resignFirstResponder()
        mobileTextfield.resignFirstResponder()
        if flag == 1 {
            changeTicket()
            return
        }
        if arrEmployee.count == 0 {
            JLToast.makeText("请先添加乘机人").show()
            return
        }
        showConfirmDialog()
    }
    
    func submitFlightOrder() {
        
        let manager = URLCollection()
        let hud = showHUD()
        if let token = manager.validateToken() {
            var params : [String : AnyObject] = [:]
            var passengers : [[String : AnyObject]] = []
            for employ in arrEmployee {
                var dictionary : [String : AnyObject] = [:]
                if canBookingForOthers {
                    dictionary["PassengerName"] = employ["isUser"].boolValue ?  employ["employee" , "Name"].stringValue : employ["employee" , "EmployeeName"].stringValue
                    let isEmployee =  employ["isUser"].boolValue ?  employ["employee" , "IsEmployee"].boolValue : (employ["employee" , "EmployeeId"].intValue == 0 ? false : true)
                    dictionary["IsEmployee"] = isEmployee
                    if isEmployee {
                        dictionary["EmployeeId"] = employ["isUser"].boolValue ?  employ["employee" , "BelongedEmployeeId"].intValue : employ["employee" , "EmployeeId"].intValue
                    }
                    dictionary["PassengerType"] = "Adult"
                    dictionary["CertType"] = employ["credentialType"].stringValue
                    dictionary["CertNo"] = employ["credentialNo"].stringValue
                    dictionary["Mobile"] = employ["employee" , "Mobile"].stringValue
                    dictionary["BelongedDeptId"] = employ["isUser"].boolValue ?  employ["employee" , "BelongedDepartmentId"].intValue : employ["employee" , "DepartmentId"].intValue
                    if !isGreenChannel {
                        if approvalRequired {
                            dictionary["ApprovalId"] = employ["approval" , "ApprovalId"].intValue
                        }
                    }
                    if isProjectRequired {
                        dictionary["ProjectId"] = employ["project" , "ProjectId"].intValue
                    }
                    dictionary["InsuranceCount"] = accidentButton.selected ? 1 : 0
                    dictionary["ReceiveFlightDynamic"] = true
                }else{
                    dictionary["PassengerName"] =  employ["EmployeeName"].stringValue
                    dictionary["IsEmployee"] = true
                    dictionary["EmployeeId"] = employ["EmployeeId"].intValue
                    dictionary["PassengerType"] = "Adult"
                    dictionary["CertType"] = employ["DefaultCertType"].stringValue
                    dictionary["CertNo"] = employ["DefaultCertNo"].stringValue
                    dictionary["Mobile"] = employ["Mobile"].stringValue
                    dictionary["BelongedDeptId"] =  employ["DepartmentId"].intValue
                    if !isGreenChannel {
                        if approvalRequired {
                            dictionary["ApprovalId"] = employ["approval" , "ApprovalId"].intValue
                        }
                    }
                    if isProjectRequired {
                        dictionary["ProjectId"] = employ["project" , "ProjectId"].intValue
                    }
                    dictionary["InsuranceCount"] = accidentButton.selected ? 1 : 0
                    dictionary["ReceiveFlightDynamic"] = true
                }
                passengers.append(dictionary)
            }
            params["Passengers"] = passengers
            params["ContactName"] = contacterTextfield.text ?? ""
            let mobileContact = mobileTextfield.text ?? ""
            if mobileContact.characters.count > 0 {
                params["ContactMobile"] = mobileContact
            }
            params["ContactEmail"] = email
            //let bunkInfo = flightInfo["Bunks" , indexPath.row]
            //flightInfo["Bunks"] = JSON([bunkInfo])
            params["FirstRoute"] = flightInfo.object
            if travelPolicy != nil && dicTravelSelected != nil && dicTravelSelected.count > 0 {
                var dictionary : [String : AnyObject] = [:]
                dictionary["DiscountLimitWarningMsg"] = travelPolicy["DiscountLimitWarningMsg"].stringValue
                dictionary["LowPriceWarningMsg"] = travelPolicy["LowPriceWarningMsg"].stringValue
                dictionary["NotLowPriceReason"] = travelPolicy["LowPriceWarningMsg"].string != nil ? travelPolicy["LowPriceReasons" , dicTravelSelected[0]!].stringValue : ""
                dictionary["NotPreNDaysReason"] = travelPolicy["PreNDaysWarningMsg"].string != nil ? (dicTravelSelected.count > 1 ? travelPolicy["PreNDaysReasons" , dicTravelSelected[1]!].stringValue  : travelPolicy["PreNDaysReasons" , dicTravelSelected[0]!].stringValue ) : ""
                dictionary["PreNDaysWarningMsg"] = travelPolicy["PreNDaysWarningMsg"].stringValue
                dictionary["TwoCabinWarningMsg"] = travelPolicy["TwoCabinWarningMsg"].stringValue
                params["FirstRoutePolicyInfo"] = dictionary
            }
            if backFlightInfo != nil {
                //let bunkInfo = backFlightInfo["Bunks" , backIndexPath.row]
                //backFlightInfo["Bunks"] = JSON([bunkInfo])
                params["SecondRoute"] = backFlightInfo.object
            }
            if backTravelPolicy != nil && dicBackTravelSelected != nil && dicBackTravelSelected.count > 0 {
                var dictionary : [String : AnyObject] = [:]
                dictionary["DiscountLimitWarningMsg"] = backTravelPolicy["DiscountLimitWarningMsg"].stringValue
                dictionary["LowPriceWarningMsg"] = backTravelPolicy["LowPriceWarningMsg"].stringValue
                dictionary["NotLowPriceReason"] = backTravelPolicy["LowPriceWarningMsg"].string != nil ? backTravelPolicy["LowPriceReasons" , dicBackTravelSelected[0]!].stringValue : ""
                dictionary["NotPreNDaysReason"] = backTravelPolicy["PreNDaysWarningMsg"].string != nil ? (dicBackTravelSelected.count > 1 ? backTravelPolicy["PreNDaysReasons" , dicBackTravelSelected[1]!].stringValue  : backTravelPolicy["PreNDaysReasons" , dicBackTravelSelected[0]!].stringValue ) : ""
                dictionary["PreNDaysWarningMsg"] = backTravelPolicy["PreNDaysWarningMsg"].stringValue
                dictionary["TwoCabinWarningMsg"] = backTravelPolicy["TwoCabinWarningMsg"].stringValue
                params["SecondRoutePolicyInfo"] = dictionary
            }
            print(params)
            manager.postRequest(manager.placeAskOrder, params: params, headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                hud.hideAnimated(true)
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        self?.askOrderConfirmByCorpCredit(model["AskOrderId"].intValue)
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
    
    func showConfirmDialog() {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("ConfirmOrder") as! ConfirmOrderViewController
        var travelManName = ""
        for json in self.arrEmployee {
            if let isUser = json["isUser"].bool where isUser {
                travelManName += json["employee" , "Name"].stringValue + " "
            }else{
                travelManName += json["employee" , "EmployeeName"].stringValue + " "
            }
        }
        controller.passengerName = travelManName
        controller.travelLine = self.flightInfo["Departure" , "CityName"].stringValue + "-" + self.flightInfo["Arrival" , "CityName"].stringValue + " \(self.backFlightInfo != nil ? "(往返)" : "")"
        controller.date = self.flightInfo["Departure" , "DateTime"].stringValue + " 出发"
        controller.money = self.totalMoneyLabel.text
        
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
        
        let okButton = PopupDialogButton(title: "确认出票", dismissOnTap: true, action: { [weak self] in
            self?.submitFlightOrder()
            
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
     改签
     */
    func changeTicket()  {
        let manager = URLCollection()
        let hud = showHUD()
        if let token = manager.validateToken() {
            let factPrice = flag == 1 ? travelPolicy["FactTicketPrice"].intValue : 0
            var params : [String : AnyObject] = [:]
            params["SrcOrderId"] = travelPolicy["OrderId"].intValue
            params["ChangeReason"] = reason
            params["ChangeDifferencePrice"] = fee - factPrice
            let bunkInfo = flightInfo["Bunks" , indexPath.row]
            if var dict = flightInfo.dictionaryObject {
                dict["Bunks"] = [bunkInfo.dictionaryObject!]
                params["ChangeRoute"] = dict
            }
            print(params)
            manager.postRequest(manager.changeApply, params: params, headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                hud.hideAnimated(true)
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        NSNotificationCenter.defaultCenter().postNotificationName("OrderListTableViewController", object: 3)
                        for viewController in self!.navigationController!.viewControllers {
                            if viewController is OrderListTableViewController {
                                self?.navigationController?.popToViewController(viewController, animated: true)
                                break
                            }
                        }
                        JLToast.makeText("改签成功").show()
                        
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
    
    func getEmployeeInfo(employeeId : Int) {
        let manager = URLCollection()
        let hud = showHUD()
        if let token = manager.validateToken() {
            manager.getRequest(manager.getEmployee, params: [ "employeeId" : employeeId], headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                hud.hideAnimated(true)
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        self?.addPassenger(model["Employee"])
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
    
    func askOrderConfirmByCorpCredit(askOrderId : Int) {
        let manager = URLCollection()
        let hud = showHUD()
        if let token = manager.validateToken() {
            manager.postRequest(manager.askOrderConfirmByCorpCredit, params: [ "askOrderId" : askOrderId], encoding : .URLEncodedInURL ,headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                hud.hideAnimated(true)
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        NSNotificationCenter.defaultCenter().postNotificationName("OrderListTableViewController", object: 3)
                        let controller = self?.storyboard?.instantiateViewControllerWithIdentifier("OrderSuccess") as! OrderSuccessViewController
                        controller.flightInfo = self?.flightInfo
                        controller.backFlightInfo = self?.backFlightInfo
                        var travelManName = ""
                        for json in self!.arrEmployee {
                            if let isUser = json["isUser"].bool where isUser {
                                travelManName += json["employee" , "Name"].stringValue + " "
                            }else{
                                travelManName += json["employee" , "EmployeeName"].stringValue + " "
                            }
                        }
                        controller.passengerName = travelManName
                        self?.navigationController?.pushViewController(controller, animated: true)
                        
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
    
    // 显示订单详情
    @IBAction func showOrderDetail(sender: AnyObject) {
        contacterTextfield.resignFirstResponder()
        mobileTextfield.resignFirstResponder()
        if arrEmployee.count == 0 {
            let alertController = UIAlertController(title: nil, message: "请先添加乘机人", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: { (action) in
                
            }))
            self.presentViewController(alertController, animated: true, completion: {
                
            })
            return
        }
        let height : CGFloat = CGFloat(-((165 - (47 + bottomDetailCount * 27)) - (bHiddenLine ? 0 : 11)))
        if detailViewBottomLConstraint.constant == (flag == 1 ? height : -47) {
            detailViewBottomLConstraint.constant = -165
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .CurveEaseInOut, animations: { 
                [weak self] in
                self?.feeDetailView.layoutIfNeeded()
                self?.arrowImageView.transform = CGAffineTransformIdentity
                }, completion: {[weak self] (finished) in
                    self?.feeDetailView.hidden = true
            })
        }else{
            detailViewBottomLConstraint.constant = (flag == 1 ? height : -47)
            feeDetailView.hidden = false
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .CurveEaseInOut, animations: { 
                    [weak self] in
                self?.feeDetailView.layoutIfNeeded()
                self?.arrowImageView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                }, completion: { (finished) in
                    
            })
        }
    }
    
    @IBAction func showFlightPolicy(sender: AnyObject) {
        contacterTextfield.resignFirstResponder()
        mobileTextfield.resignFirstResponder()
        if let info = NSUserDefaults.standardUserDefaults().objectForKey("info") as? [String : AnyObject] {
            if let token = info["Token"] as? String {
                let airlineCode = flightInfo["Airline"].stringValue
                let bunkCode = flightInfo["Bunks" , indexPath.row , "BunkCode"].stringValue
                var departureDate = flightInfo["Departure" , "DateTime"].stringValue
                if departureDate.characters.count > 10 {
                    departureDate = departureDate.substringToIndex(departureDate.startIndex.advancedBy(10))
                }
                let departureCode = flightInfo["Departure" , "AirportCode"].stringValue
                let arrivalCode = flightInfo["Arrival" , "AirportCode"].stringValue
                let params = ["airlineCode" : airlineCode , "bunkCode" : bunkCode , "departureDate" : departureDate , "departureAirportCode" : departureCode , "arrivalAirportCode" : arrivalCode]
                let hud = showHUD()
                let manager = URLCollection()
                manager.getRequest(manager.getFlightPolicy, params: params, headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                    hud.hideAnimated(true)
                    if let json = jsonObject {
                        if json["Code"].int == 0 {
                            let controller = self?.storyboard?.instantiateViewControllerWithIdentifier("FlightPolicy") as! FlightPolicyViewController
                            controller.policy = json
                            controller.flightInfo = self!.flightInfo
                            controller.indexPath = self!.indexPath
                            controller.flag = 1
                            let dialog = PopupDialog(viewController: controller)
                            controller.popupDidalog = dialog
                            if let contentView = dialog.view as? PopupDialogContainerView {
                                contentView.cornerRadius = 10
                            }
                            self?.presentViewController(dialog, animated: true, completion: {
                                
                            })
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
    }
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? EditEmployeeViewController {
            controller.flightInfo = flightInfo
            controller.title = "乘机人"
        }
    }

    @IBAction func callCustomService(sender: AnyObject) {
        contacterTextfield.resignFirstResponder()
        mobileTextfield.resignFirstResponder()
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MobileCall") as! MobileCallViewController
        controller.mobile = "400-600-2084"
        let dialog = PopupDialog(viewController: controller)
       
        if let contentView = dialog.view as? PopupDialogContainerView {
            contentView.cornerRadius = 10
        }
        let cancelButton = PopupDialogButton(title: "取消", dismissOnTap: true, action: {
            
        })
        cancelButton.buttonColor = UIColor.hexStringToColor(BACKGROUNDCOLOR)
        cancelButton.titleColor = UIColor.hexStringToColor(FONTCOLOR)
        cancelButton.titleFont = UIFont.systemFontOfSize(15)
        
        let okButton = PopupDialogButton(title: "呼叫", dismissOnTap: true, action: {
            UIApplication.sharedApplication().openURL(NSURL(string: "tel://4006002084")!)
            })
        okButton.buttonColor = UIColor.hexStringToColor(TEXTCOLOR)
        okButton.titleColor = UIColor.whiteColor()
        okButton.titleFont = UIFont.systemFontOfSize(15)
        dialog.addButtons([cancelButton , okButton])
        dialog.buttonAlignment = .Horizontal
        self.presentViewController(dialog, animated: true, completion: {
            
        })
    }
   
    @IBAction func backWhenFinished(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: flag == 1 ? "您的改签尚未完成，是否确定要离开当前页面" : "您的订单尚未填写完成，是否确定要离开当前页面", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (action) in
            
        }))
        alertController.addAction(UIAlertAction(title: "确定", style: .Default, handler: {[weak self] (action) in
            self?.navigationController?.popViewControllerAnimated(true)
            }))
        self.presentViewController(alertController, animated: true, completion: {
            
        })
    }
    
}