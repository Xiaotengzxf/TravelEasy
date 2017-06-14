//
//  FlightPolicyViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/8/28.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import SwiftyJSON
import PopupDialog

class FlightPolicyViewController: UIViewController {

    @IBOutlet weak var bunkNameLabel: UILabel!
    @IBOutlet weak var bunkPriceLabel: UILabel!
    @IBOutlet weak var airportFee: UILabel!
    @IBOutlet weak var oilFeeLabel: UILabel!
    @IBOutlet weak var returnPolicyLabel: UILabel!
    @IBOutlet weak var changePolicyLabel: UILabel!
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var signPolicyLabel: UILabel!
    var policy : JSON!
    var flightInfo : JSON!
    var indexPath : NSIndexPath!
    weak var popupDidalog : PopupDialog?
    var flag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        returnPolicyLabel.text = policy["ReturnPolicyDesc"].string
        changePolicyLabel.text = "\(policy["SignPolicyDesc"].stringValue)\(policy["ChangePolicyDesc"].stringValue)"
        signPolicyLabel.text = policy["SignPolicyDesc"].string
        airportFee.text = "¥\(flightInfo["AirportFee"].intValue)"
        oilFeeLabel.text = "¥\(flightInfo["OilFee"].intValue)"
        bunkNameLabel.text = flightInfo["Bunks" , indexPath.row , "BunkName"].string
        
        let attributeString = NSMutableAttributedString(string: "¥\(flightInfo["Bunks" , indexPath.row , "BunkPrice" , "FactBunkPrice"].stringValue)")
        attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR) , NSFontAttributeName : UIFont.systemFontOfSize(11)], range: NSMakeRange(0, 1))
        attributeString.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR) , NSFontAttributeName : UIFont.systemFontOfSize(18)], range: NSMakeRange(1, attributeString.length - 1))
        bunkPriceLabel.attributedText = attributeString
        if flag == 1 {
            bookButton.setTitle("确定", forState: .Normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeView(sender: AnyObject) {
        popupDidalog?.dismiss()
    }
    
    @IBAction func bookAirportTicket(sender: AnyObject) {
        popupDidalog?.dismiss()
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
