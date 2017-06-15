//
//  TravelStandardTableViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/8/29.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster

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
    var indexPath : IndexPath!
    var backIndexPath : IndexPath!
    var flightInfo : JSON!
    var backFlightInfo : JSON!
    var goDate : Date!
    var backDate : Date!
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
        let size = attributeString.boundingRect(with: CGSize(width: SCREENWIDTH - 30, height: 1000), options: [.usesLineFragmentOrigin , .usesFontLeading], context: nil).size
        self.tableView.tableHeaderView?.bounds = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: size.height + 20)
        
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
        tableView.register(UINib(nibName: "HeaderView", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "Header")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func submitTravelStandard(_ sender: AnyObject) {
        if dicSelectedRow.count == arrKey.count {
            if flag == 1 {
                self.performSegue(withIdentifier: "toWriteOrder", sender: self)
            }else{
                if backDate != nil {
                    let flightlist = storyboard?.instantiateViewController(withIdentifier: "FlightList") as! FlightListViewController
                    let scode = params["DepartureCode"] as! String
                    let isCity = params["DepartureCodeIsCity"] as! Bool
                    let aCode = params["ArrivalCode"] as! String
                    let aIsCity = params["ArrivalCodeIsCity"] as! Bool
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let flightDate = formatter.string(from: backDate)
                    var dicParam : [String : AnyObject] = [:]
                    dicParam["DepartureCode"] = aCode as AnyObject
                    dicParam["DepartureCodeIsCity"] = aIsCity as AnyObject
                    dicParam["ArrivalCode"] = scode as AnyObject
                    dicParam["ArrivalCodeIsCity"] = isCity as AnyObject
                    dicParam["FlightDate"] = flightDate as AnyObject
                    dicParam["BunkType"] = params["BunkType"]
                    flightlist.params = dicParam
                    flightlist.title = nextTitle.components(separatedBy: "-").reversed().joined(separator: "-")
                    flightlist.indexPath = (indexPath as! NSIndexPath) as IndexPath!
                    flightlist.flightInfo = flightInfo
                    flightlist.goDate = (goDate as! NSDate) as Date!
                    flightlist.backDate = (backDate as! NSDate) as Date!
                    flightlist.dicSelectedRow = dicSelectedRow
                    flightlist.travelData = data
                    flightlist.flag = 1
                    self.navigationController?.pushViewController(flightlist, animated: true)
                }else{
                    self.performSegue(withIdentifier: "toWriteOrder", sender: self)
                }
            }
        }else{
            Toast(text: "请选择原因").show()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return arrKey.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableData[arrKey[section]]?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        
        if let text = tableData[arrKey[indexPath.section]]?[indexPath.row].string {
            cell.textLabel?.text = text
        }
        if let row = dicSelectedRow[indexPath.section], row == indexPath.row {
            cell.textLabel?.textColor = UIColor.hexStringToColor(TEXTCOLOR)
            cell.accessoryView = UIImageView(image: UIImage(named: "icon_radio_pr"))
        }else{
            cell.textLabel?.textColor = UIColor.hexStringToColor(FONTSECCOLOR)
            cell.accessoryView = UIImageView(image: UIImage(named: "icon_radio_un"))
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header") as! HeaderView
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dicSelectedRow[indexPath.section] = indexPath.row
        tableView.reloadData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? WriteOrderViewController {
            if flag == 1 {
                controller.travelPolicy = data
                controller.dicTravelSelected = dicSelectedRow
                controller.indexPath = (indexPath as! NSIndexPath) as IndexPath!
                controller.flightInfo = flightInfo
                controller.goDate = (goDate as! NSDate) as Date!
                controller.backTravelPolicy = backData
                controller.dicBackTravelSelected = dicBackSelectedRow
                controller.backIndexPath = (backIndexPath as! NSIndexPath) as IndexPath!
                controller.backFlightInfo = backFlightInfo
                controller.backDate = (backDate as! NSDate) as Date!
            }else{
                controller.travelPolicy = data
                controller.dicTravelSelected = dicSelectedRow
                controller.indexPath = (indexPath as! NSIndexPath) as IndexPath!
                controller.flightInfo = flightInfo
                controller.goDate = (goDate as! NSDate) as Date!
            }
            
        }
    }
    

}
