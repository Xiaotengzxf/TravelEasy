//
//  NetCheckInViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/18.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster
import Alamofire

class NetCheckInViewController: UIViewController {
    
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var passengerLabel: UILabel!
    var orderId = 0
    var orderDetail : JSON!
    var positions : Set<Int> = []
    var arrPostion = ["前排" , "后排" , "靠窗" , "靠近过道" , "靠近紧急出口" , "其他"]

    override func viewDidLoad() {
        super.viewDidLoad()
        getOrderDetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getOrderDetail() {
        let manager = URLCollection()
        let hud = showHUD()
        if let token = manager.validateToken() {
            manager.getRequest(manager.getOrderDetail, params: ["orderId" : orderId as AnyObject], headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                hud.hide(animated: true)
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        self?.orderDetail = model["Order"]
                        self?.passengerLabel.text = self?.orderDetail["Passenger" , "PassengerName"].string
                    }else{
                        if let message = model["Message"].string {
                            Toast(text: message).show()
                        }
                    }
                }else{
                    Toast(text: "网络不给力，请检查网络！").show()
                }
            })
        }
    }
    
    func differTime(_ dateString : String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        let date = formatter.date(from: dateString)
        let differ = date?.timeIntervalSince(Date())
        return "离网上机票还有\(differ! / 60 * 60)小时\(differ!.truncatingRemainder(dividingBy: 60))分钟"
    }
    
    @IBAction func choosePosition(_ sender: AnyObject) {
        let button = sender as! UIButton
        if button.isSelected {
            positions.remove(button.tag - 1)
            button.isSelected = false
        }else{
            positions.insert(button.tag - 1)
            button.isSelected = true
        }
    }
    
    @IBAction func submitPostition(_ sender: AnyObject) {
        contentTextField.resignFirstResponder()
        if positions.count > 0 {
            var content = ""
            if positions.contains(5) {
                content = contentTextField.text ?? ""
                if content.characters.count == 0 || content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count == 0 {
                    Toast(text: "请输入其他原因！").show()
                    return
                }
            }
            arrPostion[5] = content
            let manager = URLCollection()
            let hud = showHUD()
            if let token = manager.validateToken() {
                manager.postRequest(manager.netCheckInApply, params: ["orderId" : orderId as AnyObject , "seatRequirement" : positions.map{arrPostion[$0]}.joined(separator: ",") as AnyObject], encoding : URLEncoding.default , headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                    hud.hide(animated: true)
                    if let model = jsonObject {
                        if model["Code"].int == 0 {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OrderListTableViewController"), object: 3)
                            let controller = self?.storyboard?.instantiateViewController(withIdentifier: "OrderSuccess") as! OrderSuccessViewController
                            controller.intApproval = 2
                            controller.flightInfo = self!.orderDetail
                            self?.navigationController?.pushViewController(controller, animated: true)
                            if var viewControllers = self?.navigationController?.viewControllers {
                                for (index , viewController) in  viewControllers.enumerated() {
                                    if viewController is NetCheckInViewController {
                                        viewControllers.remove(at: index)
                                        break
                                    }
                                }
                                self?.navigationController?.viewControllers = viewControllers
                            }
                        }else{
                            if let message = model["Message"].string {
                                Toast(text: message).show()
                            }
                        }
                    }else{
                        Toast(text: "网络不给力，请检查网络！").show()
                    }
                    })
            }
        }else{
            Toast(text: "请选择值机座位偏好").show()
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
