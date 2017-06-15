//
//  ToAndFromAirlineViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/12.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import SwiftyJSON
import PopupDialog

class ToAndFromAirlineViewController: UIViewController {
    
    @IBOutlet weak var togoDateLabel: UILabel!
    @IBOutlet weak var tobackDateLabel: UILabel!
    @IBOutlet weak var togoTimeLabel: UILabel!
    @IBOutlet weak var tobackTimeLabel: UILabel!
    @IBOutlet weak var togoAirportLabel: UILabel!
    @IBOutlet weak var tobackAirportLabel: UILabel!
    @IBOutlet weak var toflightInfoLabel: UILabel!
    @IBOutlet weak var fromgoDateLabel: UILabel!
    @IBOutlet weak var frombackDateLabel: UILabel!
    @IBOutlet weak var fromgoTimeLabel: UILabel!
    @IBOutlet weak var frombackTimeLabel: UILabel!
    @IBOutlet weak var fromgoAirportLabel: UILabel!
    @IBOutlet weak var frombackAirportLabel: UILabel!
    @IBOutlet weak var fromflightInfoLabel: UILabel!
    @IBOutlet weak var toStopLocationLabel: UILabel!
    @IBOutlet weak var fromStopLocationLabel: UILabel!
    var popupDialog : PopupDialog!
    var flightInfo : JSON! // 航程信息
    var backFlightInfo : JSON! // 返程信息

    override func viewDidLoad() {
        super.viewDidLoad()
        if let departureDateTime = flightInfo["Departure" , "DateTime"].string, departureDateTime.characters.count > 10 {
            let dateAndTime = departureDateTime.components(separatedBy: " ")
            let date = dateAndTime[0].components(separatedBy: "-").map{UInt($0)}
            let calendar = XZCalendarModel.calendarDay(withYear: date[0]!, month: date[1]!, day: date[2]!)
            togoDateLabel.text = "\((calendar?.month)! > 9 ? "\(calendar?.month)" : "0\(calendar?.month)")月\((calendar?.day)! > 9 ? "\(calendar?.day)" : "0\(calendar?.day)")日\(calendar?.getWeek()!)"
            togoTimeLabel.text = dateAndTime[1]
        }
        if let departureDateTime = flightInfo["Arrival" , "DateTime"].string, departureDateTime.characters.count > 10 {
            let dateAndTime = departureDateTime.components(separatedBy: " ")
            let date = dateAndTime[0].components(separatedBy: "-").map{UInt($0)}
            let calendar = XZCalendarModel.calendarDay(withYear: date[0]!, month: date[1]!, day: date[2]!)
            tobackDateLabel.text = "\((calendar?.month)! > 9 ? "\(calendar?.month)" : "0\(calendar?.month)")月\((calendar?.day)! > 9 ? "\(calendar?.day)" : "0\(calendar?.day)")日\(calendar?.getWeek()!)"
            tobackTimeLabel.text = dateAndTime[1]
        }
        togoAirportLabel.text = "\(flightInfo["Departure" , "AirportName"].stringValue)机场\(flightInfo["Departure" , "Terminal"].stringValue)"
        tobackAirportLabel.text = "\(flightInfo["Arrival" , "AirportName"].stringValue)机场\(flightInfo["Arrival" , "Terminal"].stringValue)"
        toflightInfoLabel.text = "\(flightInfo["AirlineName"].stringValue)\(flightInfo["FlightNo"].stringValue) | \(flightInfo["PlanType"].stringValue) ｜ \(flightInfo["Meal"].stringValue)餐食"
        
        if let departureDateTime = backFlightInfo["Departure" , "DateTime"].string, departureDateTime.characters.count > 10 {
            let dateAndTime = departureDateTime.components(separatedBy: " ")
            let date = dateAndTime[0].components(separatedBy: "-").map{UInt($0)}
            let calendar = XZCalendarModel.calendarDay(withYear: date[0]!, month: date[1]!, day: date[2]!)
            fromgoDateLabel.text = "\((calendar?.month)! > 9 ? "\(calendar?.month)" : "0\(calendar?.month)")月\((calendar?.day)! > 9 ? "\(calendar?.day)" : "0\(calendar?.day)")日\(calendar?.getWeek()!)"
            fromgoTimeLabel.text = dateAndTime[1]
        }
        if let departureDateTime = backFlightInfo["Arrival" , "DateTime"].string, departureDateTime.characters.count > 10 {
            let dateAndTime = departureDateTime.components(separatedBy: " ")
            let date = dateAndTime[0].components(separatedBy: "-").map{UInt($0)}
            let calendar = XZCalendarModel.calendarDay(withYear: date[0]!, month: date[1]!, day: date[2]!)
            frombackDateLabel.text = "\((calendar?.month)! > 9 ? "\(calendar?.month)" : "0\(calendar?.month)")月\((calendar?.day)! > 9 ? "\(calendar?.day)" : "0\(calendar?.day)")日\(calendar?.getWeek()!)"
            frombackTimeLabel.text = dateAndTime[1]
        }
        fromgoAirportLabel.text = "\(backFlightInfo["Departure" , "AirportName"].stringValue)机场\(backFlightInfo["Departure" , "Terminal"].stringValue)"
        frombackAirportLabel.text = "\(backFlightInfo["Arrival" , "AirportName"].stringValue)机场\(backFlightInfo["Arrival" , "Terminal"].stringValue)"
        fromflightInfoLabel.text = "\(backFlightInfo["AirlineName"].stringValue)\(backFlightInfo["FlightNo"].stringValue) | \(backFlightInfo["PlanType"].stringValue) ｜ \(backFlightInfo["Meal"].stringValue)餐食"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeDialog(_ sender: AnyObject) {
        popupDialog.dismiss()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
