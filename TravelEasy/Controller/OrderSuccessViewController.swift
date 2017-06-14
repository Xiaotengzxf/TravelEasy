//
//  OrderSuccessViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/11.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON
import JLToast

class OrderSuccessViewController: UIViewController {

    @IBOutlet weak var toAndFromCityLabel: UILabel!
    @IBOutlet weak var goDateAndAirportLabel: UILabel!
    @IBOutlet weak var backDateAndAirportLabel: UILabel!
    @IBOutlet weak var passengersLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var tipOneLabel: UILabel!
    @IBOutlet weak var tipTwoLabel: UILabel!
    @IBOutlet weak var tipThreeLabel: UILabel!
    @IBOutlet weak var backDateAndAirportLabelBottomLConstraint: NSLayoutConstraint!
    var flightInfo : JSON!
    var backFlightInfo: JSON!
    var passengerName : String!
    var intApproval = 0
    var approvalId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).CGColor
        continueButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), forState: .Highlighted)
        continueButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        showButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).CGColor
        showButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), forState: .Highlighted)
        showButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        if intApproval == 1 {
            self.title = "提交成功"
            continueButton.setTitle("继续申请", forState: .Normal)
            showButton.setTitle("查看申请", forState: .Normal)
            toAndFromCityLabel.text = flightInfo["reason"].stringValue
            goDateAndAirportLabel.text = flightInfo["date"].stringValue
            passengersLabel.text = flightInfo["city"].stringValue
            backDateAndAirportLabelBottomLConstraint.constant = 0
            tipOneLabel.text = "您的出差申请已提交，请等"
            let attributeText = NSMutableAttributedString(string: "待领导审批！需要领导审批")
            attributeText.addAttributes([NSForegroundColorAttributeName : UIColor.hexStringToColor(TEXTCOLOR)], range: NSMakeRange(6, 6))
            tipTwoLabel.attributedText = attributeText
            tipThreeLabel.text = "后方可出票。"
            tipThreeLabel.textColor = UIColor.hexStringToColor(TEXTCOLOR)
        }else if intApproval == 2 {
            self.title = "代办值机"
            continueButton.setTitle("订单列表", forState: .Normal)
            showButton.setTitle("查看详情", forState: .Normal)
            tipOneLabel.text = "代办值机提交成功！"
            tipTwoLabel.text = nil
            tipThreeLabel.text = "我们将尽快处理。"
            toAndFromCityLabel.text = flightInfo["Route" , "Departure" , "CityName"].stringValue + "-" + flightInfo["Route" , "Arrival" , "CityName"].stringValue
            backDateAndAirportLabelBottomLConstraint .constant = 0
            passengersLabel.text = "订单号 \(flightInfo["OrderNo"].stringValue)"
        }else{
            toAndFromCityLabel.text = flightInfo["Departure" , "CityName"].stringValue + "-" + flightInfo["Arrival" , "CityName"].stringValue  + " \(backFlightInfo != nil ? "(往返)" : "")"
            goDateAndAirportLabel.text = flightInfo["Departure" , "DateTime"].stringValue + " " + flightInfo["FlightNo"].stringValue
            backDateAndAirportLabel.text = backFlightInfo != nil ? backFlightInfo["Departure" , "DateTime"].stringValue + " " + backFlightInfo["FlightNo"].stringValue + " (返程)" : ""
            passengersLabel.text = passengerName
            if backFlightInfo != nil {
                
            }else{
                backDateAndAirportLabelBottomLConstraint.constant = 0
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backToTopViewController(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func continueOrdering(sender: AnyObject) {
        if intApproval == 1 {
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("NewApproval") as! NewApprovalViewController
            self.navigationController?.pushViewController(controller, animated: true)
            
            if var viewControllers = self.navigationController?.viewControllers {
                for (index , viewController) in  viewControllers.enumerate() {
                    if viewController is OrderSuccessViewController {
                        viewControllers.removeAtIndex(index)
                        break
                    }
                }
                self.navigationController?.viewControllers = viewControllers
            }
        }else{
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
    }

    @IBAction func lookForOrderDetail(sender: AnyObject) {
        if intApproval == 1 {
            self.navigationController?.popToRootViewControllerAnimated(true)
        }else{
            NSNotificationCenter.defaultCenter().postNotificationName("MTabBarViewController", object: 3)
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
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
