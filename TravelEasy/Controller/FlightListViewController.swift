//
//  FlightListViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/8/16.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import MBProgressHUD
import JLToast
import SwiftyJSON
import PopupDialog
import MJRefresh

class FlightListViewController: UIViewController , UITableViewDataSource , UITableViewDelegate , HeaderFooterViewDelegate , UITabBarDelegate {

    @IBOutlet weak var constraint: NSLayoutConstraint!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var theDayBeforeButton: UIButton!
    @IBOutlet weak var theDayLateButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var params : [String : AnyObject] = [:]
    var originalFlights : [JSON] = []
    var flights : [JSON] = []
    var arrAirline : Set<String> = []
    var flightSelectedRows : [Int : Bool] = [:]
    var travelData : JSON!
    var backTravelData : JSON!
    var indexPath : NSIndexPath!
    var backIndexPath : NSIndexPath!
    var flightInfo : JSON!
    var backFlightInfo : JSON!
    var bunkSelectedRow = 0
    var airlineSelectedRows : [Int] = []
    var goDate : NSDate!
    var backDate : NSDate!
    var policyItems : [String] = [] // 员工差旅标准
    var flag = 0 // 标示
    var reason : String!
    
    var dicSelectedRow : [Int : Int] = [:]
    var dicBackSelectedRow : [Int : Int] = [:]
    
    var emptyView : EmptyView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "HeaderFooterView" , bundle:  nil ), forHeaderFooterViewReuseIdentifier: "IdentifierCell")
        if let dateString = params["FlightDate"] as? String {
            let dateArray = dateString.componentsSeparatedByString("-").map({UInt($0)})
            let dateModel = XZCalendarModel.calendarDayWithYear(dateArray[0] ?? 0, month: dateArray[1] ?? 0, day: dateArray[2] ?? 0)
            dateLabel.text = "\(dateModel.month < 10 ? "0\(dateModel.month )" : "\(dateModel.month)")月\(dateModel.day < 10 ? "0\(dateModel.day)" : "\(dateModel.day)")日\(dateModel.getWeek())"
            if compareDateWithOtherDate(goDate) <= 0 {
                theDayBeforeButton.enabled = false
            }
            if compareDateWithOtherDate(goDate) >= 365 {
                theDayLateButton.enabled = false
            }
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FlightListViewController.handleNotification(_:)), name: "FlightListViewController\(flag)", object: nil)
        emptyView = EmptyManager.getInstance.insertEmptyView(with: self.view, top: 30, emptyType: .noFlightData , bottom : 49)
        emptyView.hidden = true
        
        if flag == 2 {
            tabBar.hidden = true
            constraint.constant = -49
        }
        getFlightList()
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.performSelector(#selector(FlightListViewController.hideTableViewHeader), withObject: nil, afterDelay: 0.3)
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func handleNotification(sender : NSNotification) {
        if let value = sender.object as? Int {
            if value == 1 {
                if let indexPath = sender.userInfo?["indexPath"] as? NSIndexPath {
                    getFlightPolicy(indexPath)
                }
            }else if value == 2 {
                if let indexPath = sender.userInfo?["indexPath"] as? NSIndexPath {
                    if flag == 2 {
                        let writeOrder = self.storyboard?.instantiateViewControllerWithIdentifier("WriteOrder") as! WriteOrderViewController
                        writeOrder.indexPath = indexPath
                        writeOrder.flightInfo = flights[indexPath.section]
                        writeOrder.travelPolicy = backFlightInfo
                        writeOrder.goDate = self.goDate
                        writeOrder.flag = 1
                        writeOrder.reason = reason
                        self.navigationController?.pushViewController(writeOrder, animated: true)
                    }else{
                        bookValidate(indexPath)
                    }
                }
            }else if value == 3 {
                if let rows = sender.userInfo?["rows"] as? [Int] {
                    tableView.mj_header.beginRefreshing()
                    flightSelectedRows.removeAll()
                    airlineSelectedRows = rows
                    if rows.count == 0 || (rows.count == 1 && rows[0] == 0) {
                        flights = originalFlights
                    }else{
                        flights = originalFlights.filter({ rows.contains((Array(arrAirline).indexOf($0["AirlineName"].stringValue)  ?? -2) + 1) })
                    }
                    tableView.reloadData()
                }
            }else if value == 4 {
                if let row = sender.userInfo?["row"] as? Int {
                    tableView.mj_header.beginRefreshing()
                    flightSelectedRows.removeAll()
                    bunkSelectedRow = row
                    if row == 0 {
                        flights = originalFlights
                    }else{
                        let bunkType = row == 1 ? "Y" : "FC"
                        flights.removeAll()
                        for var flight in originalFlights {
                            if let bunks = flight["Bunks"].array {
                                var array : [JSON] = []
                                for  bunk in bunks {
                                    let bType = bunk["BunkType"].stringValue
                                    if bunkType.containsString(bType) {
                                        array.append(bunk)
                                    }
                                    
                                }
                                if array.count > 0 {
                                    flight["Bunks"].arrayObject = array.map({$0.object})
                                    flights.append(flight)
                                }
                            }
                        }
                    }
                    tableView.reloadData()
                }
            }
        }
    }
    
    func getFlightPolicy(indexPath : NSIndexPath) {
        if let info = NSUserDefaults.standardUserDefaults().objectForKey("info") as? [String : AnyObject] {
            if let token = info["Token"] as? String {
                let airlineCode = flights[indexPath.section]["Airline"].stringValue
                let bunkCode = flights[indexPath.section]["Bunks" , indexPath.row , "BunkCode"].stringValue
                var departureDate = flights[indexPath.section]["Departure" , "DateTime"].stringValue
                if departureDate.characters.count > 10 {
                    departureDate = departureDate.substringToIndex(departureDate.startIndex.advancedBy(10))
                }
                let departureCode = flights[indexPath.section]["Departure" , "AirportCode"].stringValue
                let arrivalCode = flights[indexPath.section]["Arrival" , "AirportCode"].stringValue
                let params = ["airlineCode" : airlineCode , "bunkCode" : bunkCode , "departureDate" : departureDate , "departureAirportCode" : departureCode , "arrivalAirportCode" : arrivalCode]
                let hud = showHUD()
                let manager = URLCollection()
                manager.getRequest(manager.getFlightPolicy, params: params, headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                    hud.hideAnimated(true)
                    if let json = jsonObject {
                        if json["Code"].int == 0 {
                            let controller = self?.storyboard?.instantiateViewControllerWithIdentifier("FlightPolicy") as! FlightPolicyViewController
                            controller.policy = json
                            controller.flightInfo = self!.flights[indexPath.section]
                            controller.indexPath = indexPath
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
    
    func bookValidate(indexPath : NSIndexPath) {
        if let info = NSUserDefaults.standardUserDefaults().objectForKey("info") as? [String : AnyObject] {
            if let token = info["Token"] as? String {
                let flightNo = flights[indexPath.section]["FlightNo"].stringValue
                let bunkCode = flights[indexPath.section]["Bunks" , indexPath.row , "BunkCode"].stringValue
                let factBunkPrice = flights[indexPath.section]["Bunks" , indexPath.row ,"BunkPrice" ,"FactBunkPrice"].intValue
                var departureDate = flights[indexPath.section]["Departure" , "DateTime"].stringValue
                if departureDate.characters.count > 10 {
                    departureDate = departureDate.substringToIndex(departureDate.startIndex.advancedBy(10))
                }
                let departureCode = flights[indexPath.section]["Departure" , "AirportCode"].stringValue
                let arrivalCode = flights[indexPath.section]["Arrival" , "AirportCode"].stringValue
                let params : [String : AnyObject] = ["FlightNo" : flightNo , "BunkCode" : bunkCode , "FlightDate" : departureDate , "DepartureCode" : departureCode , "ArrivalCode" : arrivalCode , "FactBunkPrice" : factBunkPrice]
                let hud = showHUD()
                let manager = URLCollection()
                manager.postRequest(manager.bookingValidate, params: params, headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                    hud.hideAnimated(true)
                    if let json = jsonObject {
                        if json["Code"].int == 0 {
                            if self?.flag == 1 {
                                let writeOrder = self?.storyboard?.instantiateViewControllerWithIdentifier("WriteOrder") as! WriteOrderViewController
                                self?.backIndexPath = indexPath
                                writeOrder.indexPath = self?.indexPath
                                writeOrder.backIndexPath = self?.backIndexPath
                                writeOrder.flightInfo = self!.flightInfo
                                writeOrder.backFlightInfo = json["Flight"]
                                writeOrder.goDate = self!.goDate
                                writeOrder.backDate = self!.backDate
                                self?.navigationController?.pushViewController(writeOrder, animated: true)
                            }else{
                                if self?.backDate != nil {
                                    let flightlist = self?.storyboard?.instantiateViewControllerWithIdentifier("FlightList") as! FlightListViewController
                                    flightlist.flag = 1
                                    let scode = self!.params["DepartureCode"] as? String ?? ""
                                    let isCity = self!.params["DepartureCodeIsCity"] as? Bool ?? false
                                    let aCode = self!.params["ArrivalCode"] as? String ?? ""
                                    let aIsCity = self!.params["ArrivalCodeIsCity"] as? Bool ?? false
                                    let formatter = NSDateFormatter()
                                    formatter.dateFormat = "yyyy-MM-dd"
                                    let flightDate = formatter.stringFromDate(self!.backDate)
                                    var dicParam : [String : AnyObject] = [:]
                                    dicParam["DepartureCode"] = aCode
                                    dicParam["DepartureCodeIsCity"] = aIsCity
                                    dicParam["ArrivalCode"] = scode
                                    dicParam["ArrivalCodeIsCity"] = isCity
                                    dicParam["FlightDate"] = flightDate
                                    dicParam["BunkType"] = self?.params["BunkType"]
                                    flightlist.params = dicParam
                                    flightlist.title = self?.title?.componentsSeparatedByString("-").reverse().joinWithSeparator("-")
                                    self?.indexPath = indexPath
                                    flightlist.indexPath = indexPath
                                    flightlist.flightInfo = json["Flight"]
                                    flightlist.goDate = self?.goDate
                                    flightlist.backDate = self?.backDate
                                    
                                    self?.navigationController?.pushViewController(flightlist, animated: true)
                                }else{
                                    let writeOrder = self?.storyboard?.instantiateViewControllerWithIdentifier("WriteOrder") as! WriteOrderViewController
                                    writeOrder.indexPath = indexPath
                                    writeOrder.flightInfo = json["Flight"]
                                    writeOrder.goDate = self!.goDate
                                    self?.navigationController?.pushViewController(writeOrder, animated: true)
                                }
                            }
                            
                        }else if json["Code"].int == 1{
                            if self?.flag == 1 {
                                self?.backTravelData = json["WarningInfo"]
                                self?.backIndexPath = indexPath
                                self?.backFlightInfo = json["Flight"]
                                self?.performSegueWithIdentifier("toTravelStandard", sender: self!)
                            }else{
                                self?.travelData = json["WarningInfo"]
                                self?.indexPath = indexPath
                                self?.flightInfo = json["Flight"]
                                self?.performSegueWithIdentifier("toTravelStandard", sender: self!)
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
    }
    
    /**
     获取航班数据
     */
    func getFlightList()  {
        emptyView.hidden = true
        if let info = NSUserDefaults.standardUserDefaults().objectForKey("info") as? [String : AnyObject] {
            if let token = info["Token"] as? String {
                let hud = showHUD()
                let manager = URLCollection()
                manager.postRequest(manager.getFlights, params: params, headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                    hud.hideAnimated(true)
                    if let json = jsonObject {
                        if json["Code"].int == 0 {
                            if let flights = json["Flights"].array {
                                if flights.count == 0 {
                                    self?.emptyView.hidden = false
                                }
                                self?.flights.removeAll()
                                if self!.flag == 2 {
                                    for flight in flights {
                                        if let airline = flight["AirlineName"].string where airline.characters.count > 0 {
                                            if airline == self?.backFlightInfo["AirlineName"].string {
                                                self?.flights.append(flight)
                                            }
                                        }
                                    }
                                }else{
                                    self?.flights += flights
                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                                        self?.originalFlights.removeAll()
                                        self?.originalFlights += flights
                                        for flight in flights {
                                            if let airline = flight["AirlineName"].string where airline.characters.count > 0 {
                                                self?.arrAirline.insert(airline)
                                            }
                                            
                                        }
                                    })
                                }  
                            }
                            self?.tableView.reloadData()
                            
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
    
    // 差旅标准
    @IBAction func travelStandrad(sender: AnyObject) {
        if policyItems.count == 0 {
            let manager = URLCollection()
            if let token = manager.validateToken() {
                let hud = showHUD()
                manager.getRequest(manager.getEmployeePolicyInfo, params: nil, headers: ["token" : token], callback: {[weak self] (jsonObject, error) in
                    hud.hideAnimated(true)
                    if let json = jsonObject {
                        if json["Code"].int == 0 {
                            if let policies = json["PolicyItems"].arrayObject as? [String] {
                                self!.policyItems += policies
                                let controller = self?.storyboard?.instantiateViewControllerWithIdentifier("PolicyStandrad") as! PolicyStandradViewController
                                controller.content = policies.joinWithSeparator("\n")
                                let dialog = PopupDialog(viewController: controller)
                                controller.popupDidalog = dialog
                                if let contentView = dialog.view as? PopupDialogContainerView {
                                    contentView.cornerRadius = 10
                                }
                                self?.presentViewController(dialog, animated: true, completion: {
                                    
                                })
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
        }else{
            let controller = storyboard?.instantiateViewControllerWithIdentifier("PolicyStandrad") as! PolicyStandradViewController
            controller.content = policyItems.joinWithSeparator("\n")
            let dialog = PopupDialog(viewController: controller)
            controller.popupDidalog = dialog
            if let contentView = dialog.view as? PopupDialogContainerView {
                contentView.cornerRadius = 10
            }
            presentViewController(dialog, animated: true, completion: {
                
            })
        }
    }
    
    @IBAction func toTheDayBefore(sender: AnyObject) {
        let date = (flag == 1 ? backDate : goDate).dateByAddingTimeInterval(-3600 * 24)
        if flag == 1 {
            backDate = date
        }else{
            goDate = date
        }
        if compareDateWithOtherDate(date) <= 0 {
            theDayBeforeButton.enabled = false
        }
        if compareDateWithOtherDate(date) < 365 {
            theDayLateButton.enabled = true
        }
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.stringFromDate(date)
        let dateArray = dateString.componentsSeparatedByString("-").map{UInt($0)!}
        let dateModel = XZCalendarModel.calendarDayWithYear(dateArray[0] ?? 0, month: dateArray[1] ?? 0, day: dateArray[2] ?? 0)
        dateLabel.text = "\(dateModel.month < 10 ? "0\(dateModel.month )" : "\(dateModel.month)")月\(dateModel.day < 10 ? "0\(dateModel.day)" : "\(dateModel.day)")日\(dateModel.getWeek())"
        
        params["FlightDate"] = dateString
        
        getFlightList()
    }
    
    @IBAction func toTheDayLate(sender: AnyObject) {
        let date = (flag == 1 ? backDate : goDate).dateByAddingTimeInterval(3600 * 24)
        if flag == 1 {
            backDate = date
        }else{
            goDate = date
        }
        if compareDateWithOtherDate(date) >= 365 {
            theDayLateButton.enabled = false
        }
        if compareDateWithOtherDate(date) > 0 {
            theDayBeforeButton.enabled = true
        }
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.stringFromDate(date)
        let dateArray = dateString.componentsSeparatedByString("-").map{UInt($0)!}
        let dateModel = XZCalendarModel.calendarDayWithYear(dateArray[0] ?? 0, month: dateArray[1] ?? 0, day: dateArray[2] ?? 0)
        dateLabel.text = "\(dateModel.month < 10 ? "0\(dateModel.month )" : "\(dateModel.month)")月\(dateModel.day < 10 ? "0\(dateModel.day)" : "\(dateModel.day)")日\(dateModel.getWeek())"
        
        params["FlightDate"] = dateString
        getFlightList()
    }
    
    func compareDateWithOtherDate(date : NSDate) -> Int {
        let today = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let unitflag : NSCalendarUnit = [.Year , .Month , .Day]
        let component = calendar.components(unitflag, fromDate: today)
        let componentDate = calendar.components(unitflag, fromDate: date)
        let time = calendar.dateFromComponents(component)
        let timeD = calendar.dateFromComponents(componentDate)
        let dis = timeD!.timeIntervalSinceDate(time!)
        return Int(dis)/(24 * 3600)
    }
    
    
    
    // MARK : - table view data source and delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isExtand = flightSelectedRows[section] ?? false
        if isExtand {
            if let array = flights[section]["Bunks"].array {
                return array.count
            }
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return flights.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier("IdentifierCell") as! HeaderFooterView
        cell.delegate = self
        cell.tag = section
        cell.isExtand = flightSelectedRows[section] ?? false
        if let time = flights[section]["Departure" , "DateTime"].string where time.characters.count > 11 {
            cell.startTimeLabel.text = time.substringFromIndex(time.startIndex.advancedBy(11))
        }
        if let time = flights[section]["Arrival" , "DateTime"].string where time.characters.count > 11 {
            cell.arriveTimeLabel.text = time.substringFromIndex(time.startIndex.advancedBy(11))
        }
        cell.startAirportLabel.text = "\(flights[section]["Departure" , "AirportName"].stringValue)机场\(flights[section]["Departure" , "Terminal"].stringValue)"
        cell.flightInfoLabel.text = "\(flights[section]["AirlineName"].stringValue)\(flights[section]["FlightNo"].stringValue) | \(flights[section]["PlanType"].stringValue)"
        cell.arriveAirportLabel.text = "\(flights[section]["Arrival" , "AirportName"].stringValue)机场\(flights[section]["Arrival" , "Terminal"].stringValue)"
        if let _ = flights[section]["StopInfo"].dictionary {
            cell.stopLocationLabel.text = "经停"
        }else{
            cell.stopLocationLabel.text = nil
        }
        if let bunkPrices = flights[section]["Bunks"].array {
            let price = bunkPrices.minElement({$0["BunkPrice" , "FactBunkPrice"].intValue < $1["BunkPrice" , "FactBunkPrice"].intValue})
            let attributeString = NSMutableAttributedString(string: "¥\(price?["BunkPrice" , "FactBunkPrice"].int ?? 0) 起")
            attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR) , NSFontAttributeName : UIFont.systemFontOfSize(11)], range: NSMakeRange(0, 1))
            attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR) , NSFontAttributeName : UIFont.systemFontOfSize(18)], range: NSMakeRange(1, attributeString.length - 2))
            attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(FONTCOLOR) , NSFontAttributeName : UIFont.systemFontOfSize(11)], range: NSMakeRange(attributeString.length - 1, 1))
            cell.flightMoneyLabel.attributedText = attributeString
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell" , forIndexPath: indexPath) as! FlightTableViewCell
        cell.indexPath = indexPath
        cell.bunkNameLabel.text = flights[indexPath.section]["Bunks" , indexPath.row , "BunkName"].string
        let factDiscount = flights[indexPath.section]["Bunks" , indexPath.row , "BunkPrice" , "FactDiscount"].intValue
        cell.discountInfoLabel.text = "\(factDiscount >= 100 ? "全价" : "\(Float(factDiscount) / 10)折")/\(flights[indexPath.section]["Bunks" , indexPath.row , "BunkCode" ].stringValue)"
        let price = flights[indexPath.section]["Bunks" , indexPath.row , "BunkPrice" , "FactBunkPrice"].intValue
        let attributeString = NSMutableAttributedString(string: "¥\(price)")
        attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR) , NSFontAttributeName : UIFont.systemFontOfSize(11)], range: NSMakeRange(0, 1))
        attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR) , NSFontAttributeName : UIFont.systemFontOfSize(18)], range: NSMakeRange(1, attributeString.length - 1))
        cell.bunkPriceLabel.attributedText = attributeString
        let remainNum = flights[indexPath.section]["Bunks" , indexPath.row , "RemainNum"].intValue
        cell.remainNumLabel.text = "\(remainNum)张"
        if remainNum > 5 {
            cell.remainNumLabel.hidden = true
        }else{
            cell.remainNumLabel.hidden = false
        }
        if flag == 2 {
            cell.bookButton.setTitle("改签", forState: .Normal)
        }
        cell.selectionStyle = .None
        cell.flag = flag
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? TravelStandardTableViewController {
            if flag == 1 {
                controller.data = travelData
                controller.backData = backTravelData
                controller.indexPath = indexPath
                controller.flightInfo = flightInfo
                controller.goDate = goDate
                controller.backData = backTravelData
                controller.backIndexPath = backIndexPath
                controller.backFlightInfo = backFlightInfo
                controller.backDate = backDate
                controller.flag = flag
            }else{
                controller.data = travelData
                controller.indexPath = indexPath
                controller.flightInfo = flightInfo
                controller.goDate = goDate
                controller.backDate = backDate
                controller.flag = flag
                controller.nextTitle = title
                controller.params = params
            }
        }
    }
    
    // MARK: - HeadFootViewDelegate
    func headerFooterViewIsExtandBunk(isExtand: Bool, tag: Int) {
        flightSelectedRows[tag] = isExtand
        tableView.reloadSections(NSIndexSet(index: tag), withRowAnimation: .None)
    }
    
    // MARK: - UITabbarDelegate 弹框
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item.tag == 4 {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("AirlineList") as! AirlineListViewController
            controller.arrAirline = ["不限"] + Array(arrAirline)
            controller.modalPresentationStyle = .OverCurrentContext
            controller.modalTransitionStyle = .CrossDissolve
            controller.arrSelectedRow = Set(airlineSelectedRows)
            controller.flag = flag
            self.presentViewController(controller, animated: true, completion: { 
                
            })
        }else if item.tag == 3 {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BunkList") as! BunkListViewController
            controller.selectedRow = bunkSelectedRow
            controller.bunks = ["不限舱位" , "经济舱" , "公务／头等舱"]
            controller.modalPresentationStyle = .OverCurrentContext
            controller.modalTransitionStyle = .CrossDissolve
            controller.flag = flag
            self.presentViewController(controller, animated: true, completion: { 
                
            })
        }else if item.tag == 2 {
            tableView.mj_header.beginRefreshing()
            flights.sortInPlace({ (flight1, flight2) -> Bool in
                if let bunkPrices = flight1["Bunks"].array , let bunkPrices2 = flight2["Bunks"].array {
                    let price = bunkPrices.minElement({$0["BunkPrice" , "FactBunkPrice"].intValue < $1["BunkPrice" , "FactBunkPrice"].intValue})
                    let price2 = bunkPrices2.minElement({$0["BunkPrice" , "FactBunkPrice"].intValue < $1["BunkPrice" , "FactBunkPrice"].intValue})
                    return price?["BunkPrice" , "FactBunkPrice"].int ?? 0 < price2?["BunkPrice" , "FactBunkPrice"].int ?? 0
                }
                return false
            })
            tableView.reloadData()
        }else{
            tableView.mj_header.beginRefreshing()
            flights.sortInPlace({ (flight1, flight2) -> Bool in
                if let time1 = flight1["Departure" , "DateTime"].string , let time2 = flight2["Departure" , "DateTime"].string{
                    return time1 < time2
                }
                return false
            })
            tableView.reloadData()
        }
        //tabBar.selectedItem = nil
    }
    
    func hideTableViewHeader() {
        tableView.mj_header.endRefreshing()
    }
    
}
