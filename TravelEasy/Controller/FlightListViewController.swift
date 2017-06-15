//
//  FlightListViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/8/16.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toaster
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
    var indexPath : IndexPath!
    var backIndexPath : IndexPath!
    var flightInfo : JSON!
    var backFlightInfo : JSON!
    var bunkSelectedRow = 0
    var airlineSelectedRows : [Int] = []
    var goDate : Date!
    var backDate : Date!
    var policyItems : [String] = [] // 员工差旅标准
    var flag = 0 // 标示
    var reason : String!
    
    var dicSelectedRow : [Int : Int] = [:]
    var dicBackSelectedRow : [Int : Int] = [:]
    
    var emptyView : EmptyView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "HeaderFooterView" , bundle:  nil ), forHeaderFooterViewReuseIdentifier: "IdentifierCell")
        if let dateString = params["FlightDate"] as? String {
            let dateArray = dateString.components(separatedBy: "-").map({UInt($0)})
            let dateModel = XZCalendarModel.calendarDay(withYear: dateArray[0] ?? 0, month: dateArray[1] ?? 0, day: dateArray[2] ?? 0)
            dateLabel.text = "\((dateModel?.month)! < 10 ? "0\(dateModel?.month )" : "\(dateModel?.month)")月\((dateModel?.day)! < 10 ? "0\(dateModel?.day)" : "\(dateModel?.day)")日\(dateModel?.getWeek()!)"
            if compareDateWithOtherDate(goDate) <= 0 {
                theDayBeforeButton.isEnabled = false
            }
            if compareDateWithOtherDate(goDate) >= 365 {
                theDayLateButton.isEnabled = false
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(FlightListViewController.handleNotification(_:)), name: NSNotification.Name(rawValue: "FlightListViewController\(flag)"), object: nil)
        emptyView = EmptyManager.getInstance.insertEmptyView(with: self.view, top: 30, emptyType: .noFlightData , bottom : 49)
        emptyView.isHidden = true
        
        if flag == 2 {
            tabBar.isHidden = true
            constraint.constant = -49
        }
        getFlightList()
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.perform(#selector(FlightListViewController.hideTableViewHeader), with: nil, afterDelay: 0.3)
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleNotification(_ sender : Notification) {
        if let value = sender.object as? Int {
            if value == 1 {
                if let indexPath = sender.userInfo?["indexPath"] as? IndexPath {
                    getFlightPolicy(indexPath)
                }
            }else if value == 2 {
                if let indexPath = sender.userInfo?["indexPath"] as? IndexPath {
                    if flag == 2 {
                        let writeOrder = self.storyboard?.instantiateViewController(withIdentifier: "WriteOrder") as! WriteOrderViewController
                        writeOrder.indexPath = indexPath
                        writeOrder.flightInfo = flights[indexPath.section]
                        writeOrder.travelPolicy = backFlightInfo
                        writeOrder.goDate = (self.goDate as! NSDate) as Date!
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
                        flights = originalFlights.filter({ rows.contains((Array(arrAirline).index(of: $0["AirlineName"].stringValue)  ?? -2) + 1) })
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
                                    if bunkType.contains(bType) {
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
    
    func getFlightPolicy(_ indexPath : IndexPath) {
        if let info = UserDefaults.standard.object(forKey: "info") as? [String : AnyObject] {
            if let token = info["Token"] as? String {
                let airlineCode = flights[indexPath.section]["Airline"].stringValue
                let bunkCode = flights[indexPath.section]["Bunks" , indexPath.row , "BunkCode"].stringValue
                var departureDate = flights[indexPath.section]["Departure" , "DateTime"].stringValue
                if departureDate.characters.count > 10 {
                    departureDate = departureDate.substring(to: departureDate.characters.index(departureDate.startIndex, offsetBy: 10))
                }
                let departureCode = flights[indexPath.section]["Departure" , "AirportCode"].stringValue
                let arrivalCode = flights[indexPath.section]["Arrival" , "AirportCode"].stringValue
                let params = ["airlineCode" : airlineCode , "bunkCode" : bunkCode , "departureDate" : departureDate , "departureAirportCode" : departureCode , "arrivalAirportCode" : arrivalCode]
                let hud = showHUD()
                let manager = URLCollection()
                manager.getRequest(manager.getFlightPolicy, params: params as [String : AnyObject], headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                    hud.hide(animated: true)
                    if let json = jsonObject {
                        if json["Code"].int == 0 {
                            let controller = self?.storyboard?.instantiateViewController(withIdentifier: "FlightPolicy") as! FlightPolicyViewController
                            controller.policy = json
                            controller.flightInfo = self!.flights[indexPath.section]
                            controller.indexPath = indexPath
                            let dialog = PopupDialog(viewController: controller)
                            controller.popupDidalog = dialog
                            if let contentView = dialog.view as? PopupDialogContainerView {
                                contentView.cornerRadius = 10
                            }
                            self?.present(dialog, animated: true, completion: {
                                
                            })
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
    
    func bookValidate(_ indexPath : IndexPath) {
        if let info = UserDefaults.standard.object(forKey: "info") as? [String : AnyObject] {
            if let token = info["Token"] as? String {
                let flightNo = flights[indexPath.section]["FlightNo"].stringValue
                let bunkCode = flights[indexPath.section]["Bunks" , indexPath.row , "BunkCode"].stringValue
                let factBunkPrice = flights[indexPath.section]["Bunks" , indexPath.row ,"BunkPrice" ,"FactBunkPrice"].intValue
                var departureDate = flights[indexPath.section]["Departure" , "DateTime"].stringValue
                if departureDate.characters.count > 10 {
                    departureDate = departureDate.substring(to: departureDate.characters.index(departureDate.startIndex, offsetBy: 10))
                }
                let departureCode = flights[indexPath.section]["Departure" , "AirportCode"].stringValue
                let arrivalCode = flights[indexPath.section]["Arrival" , "AirportCode"].stringValue
                let params : [String : AnyObject] = ["FlightNo" : flightNo as AnyObject , "BunkCode" : bunkCode as AnyObject , "FlightDate" : departureDate as AnyObject , "DepartureCode" : departureCode as AnyObject , "ArrivalCode" : arrivalCode as AnyObject , "FactBunkPrice" : factBunkPrice as AnyObject]
                let hud = showHUD()
                let manager = URLCollection()
                manager.postRequest(manager.bookingValidate, params: params, headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                    hud.hide(animated: true)
                    if let json = jsonObject {
                        if json["Code"].int == 0 {
                            if self?.flag == 1 {
                                let writeOrder = self?.storyboard?.instantiateViewController(withIdentifier: "WriteOrder") as! WriteOrderViewController
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
                                    let flightlist = self?.storyboard?.instantiateViewController(withIdentifier: "FlightList") as! FlightListViewController
                                    flightlist.flag = 1
                                    let scode = self!.params["DepartureCode"] as? String ?? ""
                                    let isCity = self!.params["DepartureCodeIsCity"] as? Bool ?? false
                                    let aCode = self!.params["ArrivalCode"] as? String ?? ""
                                    let aIsCity = self!.params["ArrivalCodeIsCity"] as? Bool ?? false
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "yyyy-MM-dd"
                                    let flightDate = formatter.string(from: self!.backDate)
                                    var dicParam : [String : AnyObject] = [:]
                                    dicParam["DepartureCode"] = aCode as AnyObject
                                    dicParam["DepartureCodeIsCity"] = aIsCity as AnyObject
                                    dicParam["ArrivalCode"] = scode as AnyObject
                                    dicParam["ArrivalCodeIsCity"] = isCity as AnyObject
                                    dicParam["FlightDate"] = flightDate as AnyObject
                                    dicParam["BunkType"] = self?.params["BunkType"]
                                    flightlist.params = dicParam
                                    flightlist.title = self?.title?.components(separatedBy: "-").reversed().joined(separator: "-")
                                    self?.indexPath = indexPath
                                    flightlist.indexPath = indexPath
                                    flightlist.flightInfo = json["Flight"]
                                    flightlist.goDate = self?.goDate
                                    flightlist.backDate = self?.backDate
                                    
                                    self?.navigationController?.pushViewController(flightlist, animated: true)
                                }else{
                                    let writeOrder = self?.storyboard?.instantiateViewController(withIdentifier: "WriteOrder") as! WriteOrderViewController
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
                                self?.performSegue(withIdentifier: "toTravelStandard", sender: self!)
                            }else{
                                self?.travelData = json["WarningInfo"]
                                self?.indexPath = indexPath
                                self?.flightInfo = json["Flight"]
                                self?.performSegue(withIdentifier: "toTravelStandard", sender: self!)
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
    }
    
    /**
     获取航班数据
     */
    func getFlightList()  {
        emptyView.isHidden = true
        if let info = UserDefaults.standard.object(forKey: "info") as? [String : AnyObject] {
            if let token = info["Token"] as? String {
                let hud = showHUD()
                let manager = URLCollection()
                manager.postRequest(manager.getFlights, params: params, headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                    hud.hide(animated: true)
                    if let json = jsonObject {
                        if json["Code"].int == 0 {
                            if let flights = json["Flights"].array {
                                if flights.count == 0 {
                                    self?.emptyView.isHidden = false
                                }
                                self?.flights.removeAll()
                                if self!.flag == 2 {
                                    for flight in flights {
                                        if let airline = flight["AirlineName"].string, airline.characters.count > 0 {
                                            if airline == self?.backFlightInfo["AirlineName"].string {
                                                self?.flights.append(flight)
                                            }
                                        }
                                    }
                                }else{
                                    self?.flights += flights
                                    DispatchQueue.global().async(execute: {
                                        self?.originalFlights.removeAll()
                                        self?.originalFlights += flights
                                        for flight in flights {
                                            if let airline = flight["AirlineName"].string, airline.characters.count > 0 {
                                                self?.arrAirline.insert(airline)
                                            }
                                            
                                        }
                                    })
                                }  
                            }
                            self?.tableView.reloadData()
                            
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
    
    // 差旅标准
    @IBAction func travelStandrad(_ sender: AnyObject) {
        if policyItems.count == 0 {
            let manager = URLCollection()
            if let token = manager.validateToken() {
                let hud = showHUD()
                manager.getRequest(manager.getEmployeePolicyInfo, params: nil, headers: ["token" : token], callback: {[weak self] (jsonObject, error) in
                    hud.hide(animated: true)
                    if let json = jsonObject {
                        if json["Code"].int == 0 {
                            if let policies = json["PolicyItems"].arrayObject as? [String] {
                                self!.policyItems += policies
                                let controller = self?.storyboard?.instantiateViewController(withIdentifier: "PolicyStandrad") as! PolicyStandradViewController
                                controller.content = policies.joined(separator: "\n")
                                let dialog = PopupDialog(viewController: controller)
                                controller.popupDidalog = dialog
                                if let contentView = dialog.view as? PopupDialogContainerView {
                                    contentView.cornerRadius = 10
                                }
                                self?.present(dialog, animated: true, completion: {
                                    
                                })
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
        }else{
            let controller = storyboard?.instantiateViewController(withIdentifier: "PolicyStandrad") as! PolicyStandradViewController
            controller.content = policyItems.joined(separator: "\n")
            let dialog = PopupDialog(viewController: controller)
            controller.popupDidalog = dialog
            if let contentView = dialog.view as? PopupDialogContainerView {
                contentView.cornerRadius = 10
            }
            present(dialog, animated: true, completion: {
                
            })
        }
    }
    
    @IBAction func toTheDayBefore(_ sender: AnyObject) {
        let date = (flag == 1 ? backDate : goDate).addingTimeInterval(-3600 * 24)
        if flag == 1 {
            backDate = date
        }else{
            goDate = date
        }
        if compareDateWithOtherDate(date) <= 0 {
            theDayBeforeButton.isEnabled = false
        }
        if compareDateWithOtherDate(date) < 365 {
            theDayLateButton.isEnabled = true
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        let dateArray = dateString.components(separatedBy: "-").map{UInt($0)!}
        let dateModel = XZCalendarModel.calendarDay(withYear: dateArray[0] ?? 0, month: dateArray[1] ?? 0, day: dateArray[2] ?? 0)
        dateLabel.text = "\((dateModel?.month)! < 10 ? "0\(dateModel?.month )" : "\(dateModel?.month)")月\((dateModel?.day)! < 10 ? "0\(dateModel?.day)" : "\(dateModel?.day)")日\(dateModel?.getWeek()!)"
        
        params["FlightDate"] = dateString as AnyObject
        
        getFlightList()
    }
    
    @IBAction func toTheDayLate(_ sender: AnyObject) {
        let date = (flag == 1 ? backDate : goDate).addingTimeInterval(3600 * 24)
        if flag == 1 {
            backDate = date
        }else{
            goDate = date
        }
        if compareDateWithOtherDate(date) >= 365 {
            theDayLateButton.isEnabled = false
        }
        if compareDateWithOtherDate(date) > 0 {
            theDayBeforeButton.isEnabled = true
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        let dateArray = dateString.components(separatedBy: "-").map{UInt($0)!}
        let dateModel = XZCalendarModel.calendarDay(withYear: dateArray[0] ?? 0, month: dateArray[1] ?? 0, day: dateArray[2] ?? 0)
        dateLabel.text = "\((dateModel?.month)! < 10 ? "0\(dateModel?.month )" : "\(dateModel?.month)")月\((dateModel?.day)! < 10 ? "0\(dateModel?.day)" : "\(dateModel?.day)")日\(dateModel?.getWeek()!)"
        
        params["FlightDate"] = dateString as AnyObject
        getFlightList()
    }
    
    func compareDateWithOtherDate(_ date : Date) -> Int {
        let today = Date()
        let calendar = Calendar.current
        let unitflag : NSCalendar.Unit = [.year , .month , .day]
        let component = (calendar as NSCalendar).components(unitflag, from: today)
        let componentDate = (calendar as NSCalendar).components(unitflag, from: date)
        let time = calendar.date(from: component)
        let timeD = calendar.date(from: componentDate)
        let dis = timeD!.timeIntervalSince(time!)
        return Int(dis)/(24 * 3600)
    }
    
    
    
    // MARK : - table view data source and delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isExtand = flightSelectedRows[section] ?? false
        if isExtand {
            if let array = flights[section]["Bunks"].array {
                return array.count
            }
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return flights.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "IdentifierCell") as! HeaderFooterView
        cell.delegate = self
        cell.tag = section
        cell.isExtand = flightSelectedRows[section] ?? false
        if let time = flights[section]["Departure" , "DateTime"].string, time.characters.count > 11 {
            cell.startTimeLabel.text = time.substring(from: time.characters.index(time.startIndex, offsetBy: 11))
        }
        if let time = flights[section]["Arrival" , "DateTime"].string, time.characters.count > 11 {
            cell.arriveTimeLabel.text = time.substring(from: time.characters.index(time.startIndex, offsetBy: 11))
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
            let price = bunkPrices.min(by: {$0["BunkPrice" , "FactBunkPrice"].intValue < $1["BunkPrice" , "FactBunkPrice"].intValue})
            let attributeString = NSMutableAttributedString(string: "¥\(price?["BunkPrice" , "FactBunkPrice"].int ?? 0) 起")
            attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR) , NSFontAttributeName : UIFont.systemFont(ofSize: 11)], range: NSMakeRange(0, 1))
            attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR) , NSFontAttributeName : UIFont.systemFont(ofSize: 18)], range: NSMakeRange(1, attributeString.length - 2))
            attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(FONTCOLOR) , NSFontAttributeName : UIFont.systemFont(ofSize: 11)], range: NSMakeRange(attributeString.length - 1, 1))
            cell.flightMoneyLabel.attributedText = attributeString
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell" , for: indexPath) as! FlightTableViewCell
        cell.indexPath = indexPath
        cell.bunkNameLabel.text = flights[indexPath.section]["Bunks" , indexPath.row , "BunkName"].string
        let factDiscount = flights[indexPath.section]["Bunks" , indexPath.row , "BunkPrice" , "FactDiscount"].intValue
        cell.discountInfoLabel.text = "\(factDiscount >= 100 ? "全价" : "\(Float(factDiscount) / 10)折")/\(flights[indexPath.section]["Bunks" , indexPath.row , "BunkCode" ].stringValue)"
        let price = flights[indexPath.section]["Bunks" , indexPath.row , "BunkPrice" , "FactBunkPrice"].intValue
        let attributeString = NSMutableAttributedString(string: "¥\(price)")
        attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR) , NSFontAttributeName : UIFont.systemFont(ofSize: 11)], range: NSMakeRange(0, 1))
        attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR) , NSFontAttributeName : UIFont.systemFont(ofSize: 18)], range: NSMakeRange(1, attributeString.length - 1))
        cell.bunkPriceLabel.attributedText = attributeString
        let remainNum = flights[indexPath.section]["Bunks" , indexPath.row , "RemainNum"].intValue
        cell.remainNumLabel.text = "\(remainNum)张"
        if remainNum > 5 {
            cell.remainNumLabel.isHidden = true
        }else{
            cell.remainNumLabel.isHidden = false
        }
        if flag == 2 {
            cell.bookButton.setTitle("改签", for: UIControlState())
        }
        cell.selectionStyle = .none
        cell.flag = flag
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? TravelStandardTableViewController {
            if flag == 1 {
                controller.data = travelData
                controller.backData = backTravelData
                controller.indexPath = (indexPath as! NSIndexPath) as IndexPath!
                controller.flightInfo = flightInfo
                controller.goDate = (goDate as! NSDate) as Date!
                controller.backData = backTravelData
                controller.backIndexPath = (backIndexPath as! NSIndexPath) as IndexPath!
                controller.backFlightInfo = backFlightInfo
                controller.backDate = (backDate as! NSDate) as Date!
                controller.flag = flag
            }else{
                controller.data = travelData
                controller.indexPath = (indexPath as! NSIndexPath) as IndexPath!
                controller.flightInfo = flightInfo
                controller.goDate = (goDate as! NSDate) as Date!
                controller.backDate = (backDate as! NSDate) as Date!
                controller.flag = flag
                controller.nextTitle = title
                controller.params = params
            }
        }
    }
    
    // MARK: - HeadFootViewDelegate
    func headerFooterViewIsExtandBunk(_ isExtand: Bool, tag: Int) {
        flightSelectedRows[tag] = isExtand
        tableView.reloadSections(IndexSet(integer: tag), with: .none)
    }
    
    // MARK: - UITabbarDelegate 弹框
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 4 {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "AirlineList") as! AirlineListViewController
            controller.arrAirline = ["不限"] + Array(arrAirline)
            controller.modalPresentationStyle = .overCurrentContext
            controller.modalTransitionStyle = .crossDissolve
            controller.arrSelectedRow = Set(airlineSelectedRows)
            controller.flag = flag
            self.present(controller, animated: true, completion: { 
                
            })
        }else if item.tag == 3 {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "BunkList") as! BunkListViewController
            controller.selectedRow = bunkSelectedRow
            controller.bunks = ["不限舱位" , "经济舱" , "公务／头等舱"]
            controller.modalPresentationStyle = .overCurrentContext
            controller.modalTransitionStyle = .crossDissolve
            controller.flag = flag
            self.present(controller, animated: true, completion: { 
                
            })
        }else if item.tag == 2 {
            tableView.mj_header.beginRefreshing()
            flights.sort(by: { (flight1, flight2) -> Bool in
                if let bunkPrices = flight1["Bunks"].array , let bunkPrices2 = flight2["Bunks"].array {
                    let price = bunkPrices.min(by: {$0["BunkPrice" , "FactBunkPrice"].intValue < $1["BunkPrice" , "FactBunkPrice"].intValue})
                    let price2 = bunkPrices2.min(by: {$0["BunkPrice" , "FactBunkPrice"].intValue < $1["BunkPrice" , "FactBunkPrice"].intValue})
                    return price?["BunkPrice" , "FactBunkPrice"].int ?? 0 < price2?["BunkPrice" , "FactBunkPrice"].int ?? 0
                }
                return false
            })
            tableView.reloadData()
        }else{
            tableView.mj_header.beginRefreshing()
            flights.sort(by: { (flight1, flight2) -> Bool in
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
