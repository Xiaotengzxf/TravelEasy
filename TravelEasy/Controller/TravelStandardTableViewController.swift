//
//  TravelStandardTableViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/8/29.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import SwiftyJSON
import JLToast

class TravelStandardTableViewController: UITableViewController {
    
    @IBOutlet weak var waringLabel: UILabel!
    var params : [String : AnyObject]!
    var nextTitle : String!
    var data : JSON!
    var backData : JSON!
    var tableData : [String : [JSON]] = [:]
    var arrKey : [String] = []
    var dicSelectedRow : [Int : Int] = [:]
    var dicBackSelectedRow : [Int : Int] = [:]
    var indexPath : NSIndexPath!
    var backIndexPath : NSIndexPath!
    var flightInfo : JSON!
    var backFlightInfo : JSON!
    var goDate : NSDate!
    var backDate : NSDate!
    var flag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.hexStringToColor(BACKGROUNDCOLOR)
        let lowPriceWaringMsg = data["LowPriceWarningMsg"].stringValue
        let preNDaysWarningMsg = data["PreNDaysWarningMsg"].stringValue
        let discountLimitWarningMsg = data["DiscountLimitWarningMsg"].stringValue
        let twoCabinWarningMsg = data["TwoCabinWarningMsg"].stringValue
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
        let attributeString = NSMutableAttributedString(string: warnString)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        attributeString.addAttributes([NSParagraphStyleAttributeName : style], range: NSMakeRange(0, attributeString.length))
        waringLabel.attributedText = attributeString
        let size = attributeString.boundingRectWithSize(CGSizeMake(SCREENWIDTH - 30, 1000), options: [.UsesLineFragmentOrigin , .UsesFontLeading], context: nil).size
        self.tableView.tableHeaderView?.bounds = CGRectMake(0, 0, SCREENWIDTH, size.height + 20)
        
        if let lowPriceWarningMsg = data["LowPriceWarningMsg"].string {
            let reasons = data["LowPriceReasons"].arrayValue
            tableData[lowPriceWarningMsg] = reasons
            arrKey.append(lowPriceWarningMsg)
        }
        if let preNDaysWarningMsg = data["PreNDaysWarningMsg"].string {
            let reasons = data["PreNDaysReasons"].arrayValue
            tableData[preNDaysWarningMsg] = reasons
            arrKey.append(preNDaysWarningMsg)
        }
        tableView.registerNib(UINib(nibName: "HeaderView", bundle: NSBundle.mainBundle()), forHeaderFooterViewReuseIdentifier: "Header")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func submitTravelStandard(sender: AnyObject) {
        if dicSelectedRow.count == arrKey.count {
            if flag == 1 {
                self.performSegueWithIdentifier("toWriteOrder", sender: self)
            }else{
                if backDate != nil {
                    let flightlist = storyboard?.instantiateViewControllerWithIdentifier("FlightList") as! FlightListViewController
                    let scode = params["DepartureCode"] as! String
                    let isCity = params["DepartureCodeIsCity"] as! Bool
                    let aCode = params["ArrivalCode"] as! String
                    let aIsCity = params["ArrivalCodeIsCity"] as! Bool
                    let formatter = NSDateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let flightDate = formatter.stringFromDate(backDate)
                    var dicParam : [String : AnyObject] = [:]
                    dicParam["DepartureCode"] = aCode
                    dicParam["DepartureCodeIsCity"] = aIsCity
                    dicParam["ArrivalCode"] = scode
                    dicParam["ArrivalCodeIsCity"] = isCity
                    dicParam["FlightDate"] = flightDate
                    dicParam["BunkType"] = params["BunkType"]
                    flightlist.params = dicParam
                    flightlist.title = nextTitle.componentsSeparatedByString("-").reverse().joinWithSeparator("-")
                    flightlist.indexPath = indexPath
                    flightlist.flightInfo = flightInfo
                    flightlist.goDate = goDate
                    flightlist.backDate = backDate
                    flightlist.dicSelectedRow = dicSelectedRow
                    flightlist.travelData = data
                    flightlist.flag = 1
                    self.navigationController?.pushViewController(flightlist, animated: true)
                }else{
                    self.performSegueWithIdentifier("toWriteOrder", sender: self)
                }
            }
        }else{
            JLToast.makeText("请选择原因").show()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return arrKey.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableData[arrKey[section]]?.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.font = UIFont.systemFontOfSize(12)
        
        if let text = tableData[arrKey[indexPath.section]]?[indexPath.row].string {
            cell.textLabel?.text = text
        }
        if let row = dicSelectedRow[indexPath.section] where row == indexPath.row {
            cell.textLabel?.textColor = UIColor.hexStringToColor(TEXTCOLOR)
            cell.accessoryView = UIImageView(image: UIImage(named: "icon_radio_pr"))
        }else{
            cell.textLabel?.textColor = UIColor.hexStringToColor(FONTSECCOLOR)
            cell.accessoryView = UIImageView(image: UIImage(named: "icon_radio_un"))
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("Header") as! HeaderView
        header.backgroundColor = UIColor.hexStringToColor(BACKGROUNDCOLOR)
        header.contentView.backgroundColor = UIColor.hexStringToColor(BACKGROUNDCOLOR)
        if section == 0 {
            if let _ = data["LowPriceWarningMsg"].string {
                header.titleLabel.text = "因您未选择最低价格航班，请您选择原因："
            }else{
                header.titleLabel.text = "因您未提前预订航班，请您选择原因："
            }
        }else{
            header.titleLabel.text = "因您未提前预订航班，请您选择原因："
        }
        
        return header
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dicSelectedRow[indexPath.section] = indexPath.row
        tableView.reloadData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? WriteOrderViewController {
            if flag == 1 {
                controller.travelPolicy = data
                controller.dicTravelSelected = dicSelectedRow
                controller.indexPath = indexPath
                controller.flightInfo = flightInfo
                controller.goDate = goDate
                controller.backTravelPolicy = backData
                controller.dicBackTravelSelected = dicBackSelectedRow
                controller.backIndexPath = backIndexPath
                controller.backFlightInfo = backFlightInfo
                controller.backDate = backDate
            }else{
                controller.travelPolicy = data
                controller.dicTravelSelected = dicSelectedRow
                controller.indexPath = indexPath
                controller.flightInfo = flightInfo
                controller.goDate = goDate
            }
            
        }
    }
    

}
