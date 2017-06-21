//
//  toAirlineViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/12.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import SwiftyJSON
import PopupDialog

class ToAirlineViewController: UIViewController {
    
    @IBOutlet weak var goDateLabel: UILabel!
    @IBOutlet weak var backDateLabel: UILabel!
    @IBOutlet weak var goTimeLabel: UILabel!
    @IBOutlet weak var backTimeLabel: UILabel!
    @IBOutlet weak var goAirportLabel: UILabel!
    @IBOutlet weak var backAirportLabel: UILabel!
    @IBOutlet weak var flightInfoLabel: UILabel!
    @IBOutlet weak var stopLocationLabel: UILabel!
    var popupDialog : PopupDialog!
    var flightInfo : JSON! // 航程信息

    override func viewDidLoad() {
        super.viewDidLoad()
        if let departureDateTime = flightInfo["Departure" , "DateTime"].string, departureDateTime.characters.count > 10 {
            let dateAndTime = departureDateTime.components(separatedBy: " ")
            let date = dateAndTime[0].components(separatedBy: "-").map{UInt($0)}
            let calendar = XZCalendarModel.calendarDay(withYear: date[0]!, month: date[1]!, day: date[2]!)
            goDateLabel.text = "\(calendar!.month > 9 ? "\(calendar!.month)" : "0\(calendar!.month)")月\(calendar!.day > 9 ? "\(calendar!.day)" : "0\(calendar!.day)")日\(calendar!.getWeek()!)"
            goTimeLabel.text = dateAndTime[1]
        }
        if let departureDateTime = flightInfo["Arrival" , "DateTime"].string, departureDateTime.characters.count > 10 {
            let dateAndTime = departureDateTime.components(separatedBy: " ")
            let date = dateAndTime[0].components(separatedBy: "-").map{UInt($0)}
            let calendar = XZCalendarModel.calendarDay(withYear: date[0]!, month: date[1]!, day: date[2]!)
            backDateLabel.text = "\(calendar!.month > 9 ? "\(calendar!.month)" : "0\(calendar!.month)")月\(calendar!.day > 9 ? "\(calendar!.day)" : "0\(calendar!.day)")日\(calendar!.getWeek()!)"
            backTimeLabel.text = dateAndTime[1]
        }
        goAirportLabel.text = "\(flightInfo["Departure" , "AirportName"].stringValue)机场\(flightInfo["Departure" , "Terminal"].stringValue)"
        backAirportLabel.text = "\(flightInfo["Arrival" , "AirportName"].stringValue)机场\(flightInfo["Arrival" , "Terminal"].stringValue)"
        flightInfoLabel.text = "\(flightInfo["AirlineName"].stringValue)\(flightInfo["FlightNo"].stringValue) | \(flightInfo["PlanType"].stringValue) ｜ \(flightInfo["Meal"].stringValue)餐食"
        
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
