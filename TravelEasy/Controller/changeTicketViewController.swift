//
//  changeTicketViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/20.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import SwiftyJSON
import JLToast

class changeTicketViewController: UIViewController , XZCalendarControllerDelegate {

    @IBOutlet weak var changeAirportLabel: UILabel!
    @IBOutlet weak var airportTimeLabel: UILabel!
    @IBOutlet weak var airportLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var queryButton: UIButton!
    var orderDetail : JSON!
    var reason : String!
    var dateModel : XZCalendarModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeAirportLabel.text = orderDetail["DepartureCityName"].stringValue + "-" + orderDetail["ArrivalCityName"].stringValue
        airportLabel.text = orderDetail["AirlineName"].string
        if let date = orderDetail["DepartureDateTime"].string where date.characters.count > 10{
            let dateString = date.componentsSeparatedByString(" ")[0]
            airportTimeLabel.text = dateString
            let dateArray = dateString.componentsSeparatedByString("-").map{UInt($0)!}
            dateModel = XZCalendarModel.calendarDayWithYear(dateArray[0] ?? 0, month: dateArray[1] ?? 0, day: dateArray[2] ?? 0)
            timeLabel.text = "\(dateModel.month < 10 ? "0\(dateModel.month )" : "\(dateModel.month)")月\(dateModel.day < 10 ? "0\(dateModel.day)" : "\(dateModel.day)")日\(dateModel.getWeek())"
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func queryFlight(sender: AnyObject) {
        if !isLaterToNow(dateModel.toString()) {
            JLToast.makeText("请选择日期").show()
            return
        }else{
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("FlightList") as! FlightListViewController
            let sCode = orderDetail["DepartureCityCode"].stringValue
            let isCity = true
            let aCode = orderDetail["ArrivalCityCode"].stringValue
            let aIsCity = true
            let factTicketPrice = orderDetail["FactTicketPrice"].intValue
            let flightDate = "\(dateModel.year)-\(dateModel.month)-\(dateModel.day)"
            let airlineCode = orderDetail["AirlineCode"].stringValue
            let params : [String : AnyObject] = ["DepartureCode" : sCode , "DepartureCodeIsCity" : isCity , "ArrivalCode" : aCode , "ArrivalCodeIsCity" : aIsCity , "FlightDate" : flightDate , "FactBunkPriceLowestLimit" : factTicketPrice , "Airlines" : airlineCode]
            controller.title = "\(orderDetail["DepartureCityName"].stringValue) - \(orderDetail["ArrivalCityName"].stringValue)"
            controller.params = params
            controller.goDate = dateModel.date()
            controller.flag = 2
            controller.backFlightInfo = orderDetail
            controller.reason = reason
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    func isLaterToNow(fromDate : String) -> Bool {
        let format = NSDateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let from = format.dateFromString(fromDate)
        let toDate = NSDate()
        let toString = format.stringFromDate(toDate)
        let to = format.dateFromString(toString)
        let time = from!.timeIntervalSinceDate(to!)
        return time >= 0
    }

    /**
     选择出发时间
     
     - parameter sender: 按钮
     */
    @IBAction func chooseDate(sender: AnyObject) {
        let calender = XZCalendarController()
        calender.start = "1"
        calender.delegate = self
        calender.title = "选择出发日期"
        self.navigationController?.pushViewController(calender, animated: true)
    }
    
    func xzCalendarControllerWithModel(model: XZCalendarModel!) {
        timeLabel.text = "\(model.month < 10 ? "0\(model.month )" : "\(model.month)")月\(model.day < 10 ? "0\(model.day)" : "\(model.day)")日\(model.getWeek())"
        dateModel = model
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {


    }
    

}
