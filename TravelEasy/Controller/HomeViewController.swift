//
//  HomeViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/8/10.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import JLToast

class HomeViewController: UIViewController , XZCalendarControllerDelegate , BunkTypeSelectViewDelegate , CityViewControllerDelegate {
    
    @IBOutlet weak var arriveCityLabel: UILabel! // 到达城市标签
    @IBOutlet weak var startCityLabel: UILabel! // 出发城市标签
    @IBOutlet weak var bunkLabel: UILabel! // 舱位标签
    @IBOutlet weak var dateLabel: UILabel! // 日期标签
    @IBOutlet weak var backDateLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl! // 单选控件
    @IBOutlet weak var indicatorLeftLConstraint: NSLayoutConstraint! // 单选器指示器
    @IBOutlet weak var viewTopLConstraint: NSLayoutConstraint!
    @IBOutlet weak var okButton: UIButton!
    var bunkTypeSelectedView : BunkTypeSelectView! // 舱位选择控件
    let bunks = ["不限舱位" , "经济舱" , "公务／头等舱"] // nil , Y , F
    var bunkSelectRow = 0
    var startCity : [String : AnyObject] = [:]
    var arriveCity : [String : AnyObject] = [:]
    var dateModel : XZCalendarModel!
    var backDateModel : XZCalendarModel!
    var selectedDateFlag = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let imageView = UIImageView(image: UIImage(named: "logo_top"))
        imageView.bounds = CGRectMake(0, 0, 104, 25)
        self.navigationItem.titleView = imageView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.setBackgroundImage(UIImage.imageWithColor("ffffff"), forState: .Normal, barMetrics: .Default)
        segmentedControl.setBackgroundImage(UIImage.imageWithColor("ffffff"), forState: .Selected, barMetrics: .Default)
        segmentedControl.setBackgroundImage(UIImage.imageWithColor("ffffff"), forState: .Highlighted, barMetrics: .Default)
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(FONTCOLOR) , NSFontAttributeName : UIFont.systemFontOfSize(15)], forState: .Normal)
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor("0071C4") , NSFontAttributeName : UIFont.systemFontOfSize(15)], forState: .Selected)
        segmentedControl.setDividerImage(UIImage.imageWithColor("ffffff"), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
        
        dateLabel.text = dateToString(86400, back: false)
        backDateLabel.text = dateToString(86400 * 2 , back: true)
        
        okButton.setBackgroundImage(UIImage.imageWithColor(BUTTON3BGCOLORHIGHLIGHT), forState: .Highlighted)
        okButton.setBackgroundImage(UIImage.imageWithColor(BUTTON3BGCOLORDISABLE), forState: .Disabled)
        
        if let info = NSUserDefaults.standardUserDefaults().objectForKey("info") as? [String : AnyObject] {
            let defaultCity = info["DefaultCity"] as? String ?? ""
            if defaultCity.characters.count > 0 {
                let array = defaultCity.componentsSeparatedByString(",")
                if array.count > 1 {
                    startCityLabel.text = array[1]
                    startCity = ["Code" : array[0] , "IsCity" : true , "Name" : array[1]]
                    if array[1] == "北京" {
                        arriveCity = ["Code" : "SHA" , "IsCity" : true , "Name" : "上海"]
                        arriveCityLabel.text = "上海"
                    }else{
                        arriveCity = ["Code" : "BJS" , "IsCity" : true , "Name" : "北京"]
                        arriveCityLabel.text = "北京"
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dateToString(distance : Double , back : Bool) -> String {
        let date = NSDate().dateByAddingTimeInterval(distance)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.stringFromDate(date)
        let dateArray = dateString.componentsSeparatedByString("-").map({UInt($0)})
        let dateModel = XZCalendarModel.calendarDayWithYear(dateArray[0] ?? 0, month: dateArray[1] ?? 0, day: dateArray[2] ?? 0)
        if back {
            backDateModel = dateModel
        }else{
            self.dateModel = dateModel
        }
        return "\(dateModel.month < 10 ? "0\(dateModel.month )" : "\(dateModel.month)")月\(dateModel.day < 10 ? "0\(dateModel.day)" : "\(dateModel.day)")日\(dateModel.getWeek())"
    }
    
    /**
     单选器 单程或者双程
     
     - parameter sender: segmentControl
     */
    @IBAction func changeValue(sender: AnyObject) {
        if segmentedControl.selectedSegmentIndex == 0 {
            indicatorLeftLConstraint.constant = 0
            viewTopLConstraint.constant = 0
        }else{
            indicatorLeftLConstraint.constant = SCREENWIDTH / 2
            viewTopLConstraint.constant = 70
        }
    }
    
    /**
     搜索航班
     
     - parameter sender: 按钮
     */
    @IBAction func lookForFlight(sender: AnyObject) {
        if startCity.count == 0 {
            JLToast.makeText("出发城市不能为空").show()
            return
        }
        if arriveCity.count == 0 {
            JLToast.makeText("到达城市不能为空").show()
            return
        }
        if segmentedControl.selectedSegmentIndex == 1 {
            if backDateModel.date().timeIntervalSinceDate(dateModel.date()) < 0 {
                JLToast.makeText("出发时间不能晚于返程时间").show()
                return
            }
        }
        self.performSegueWithIdentifier("toFlightList", sender: self)
    }
    
    /**
     出发时间
     
     - parameter sender: 按钮
     */
    @IBAction func chooseDate(sender: AnyObject) {
        let button = sender as! UIButton
        let calender = XZCalendarController()
        calender.start = "1"
        calender.delegate = self
        calender.title = button.tag > 0 ? "选择返程日期" : "选择出发日期"
        selectedDateFlag = button.tag
        self.navigationController?.pushViewController(calender, animated: true)
    }
    
    /**
     选择舱位
     
     - parameter sender: 按钮
     */
    @IBAction func chooseBunk(sender: AnyObject) {
        if bunkTypeSelectedView == nil {
            bunkTypeSelectedView = BunkTypeSelectView(frame : CGRectZero)
            bunkTypeSelectedView.translatesAutoresizingMaskIntoConstraints = false
            bunkTypeSelectedView.delegate = self
            self.view.window?.addSubview(bunkTypeSelectedView)
            
            self.view.window?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bunkTypeSelectedView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["bunkTypeSelectedView" : bunkTypeSelectedView]))
            self.view.window?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bunkTypeSelectedView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["bunkTypeSelectedView" : bunkTypeSelectedView]))
        }
        
        bunkTypeSelectedView.performSelector(#selector(bunkTypeSelectedView.show), withObject: nil, afterDelay: 0.1)
    }
    
    /**
     选择城市
     
     - parameter sender: 按钮
     */
    @IBAction func chooseCity(sender: AnyObject) {
        if let button = sender as? UIButton {
            let tag = button.tag
            let cityController = CityViewController(nibName: "CityViewController", bundle: nil);
            cityController.delegate = self;
            cityController.bStart = (tag == 1)
            self.navigationController?.pushViewController(cityController, animated: true)
        }
        
    }
    
    //出发城市月到达城市互换
    @IBAction func changeStartAndEndCity(sender: AnyObject) {
        let text = startCityLabel.text
        startCityLabel.text = arriveCityLabel.text
        arriveCityLabel.text = text
        let city = startCity
        startCity = arriveCity
        arriveCity = city
        
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? FlightListViewController {
            
            let sCode = startCity["Code"] as? String ?? ""
            let isCity = startCity["IsCity"] as? Bool ?? false
            let aCode = arriveCity["Code"] as? String ?? ""
            let aIsCity = arriveCity["IsCity"] as? Bool ?? false
            let flightDate = "\(dateModel.year)-\(dateModel.month)-\(dateModel.day)"
            var params : [String : AnyObject] = ["DepartureCode" : sCode , "DepartureCodeIsCity" : isCity , "ArrivalCode" : aCode , "ArrivalCodeIsCity" : aIsCity , "FlightDate" : flightDate]
            controller.title = "\(startCity["Name"] as? String ?? "") - \(arriveCity["Name"] as? String ?? "")"
            if bunkSelectRow > 0 {
                if bunkSelectRow == 1 {
                    params["BunkType"] = "Y"
                }else{
                    params["BunkType"] = "F"
                }
            }
            controller.params = params
            if segmentedControl.selectedSegmentIndex == 1 {
                controller.backDate = backDateModel.date()
            }
            controller.goDate = dateModel.date()
        }
    }
 
    func xzCalendarControllerWithModel(model: XZCalendarModel!) {
        if selectedDateFlag > 0 {
            backDateLabel.text = "\(model.month < 10 ? "0\(model.month )" : "\(model.month)")月\(model.day < 10 ? "0\(model.day)" : "\(model.day)")日\(model.getWeek())"
            backDateModel = model
        }else{
            dateLabel.text = "\(model.month < 10 ? "0\(model.month )" : "\(model.month)")月\(model.day < 10 ? "0\(model.day)" : "\(model.day)")日\(model.getWeek())"
            dateModel = model
        }
    }
    
    /**
     选择舱位回调
     
     - parameter row: 选定行
     */
    func bunkTypeSelectedViewWithSelectedRow(row: NSInteger) {
        bunkLabel.text = bunks[row]
        bunkSelectRow = row
    }
    
    /**
     选择城市回调
     
     - parameter bStart: 是否为出发
     - parameter city:   城市资料
     */
    func selectCity(bStart : Bool , city: [String : AnyObject]) {
        if bStart {
            startCity = city
            startCityLabel.text = startCity["Name"] as? String
        }else{
            arriveCity = city
            arriveCityLabel.text = arriveCity["Name"] as? String
        }
    }
}
