//
//  OrderEventTableViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/17.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toaster
import Alamofire

class OrderEventTableViewController: UITableViewController {
    
    @IBOutlet weak var waringLabel: UILabel!
    var arrReason : [String]!
    var policyDesc : String!
    var selectedRow = -1
    var orderId = 0
    var flag = 0
    var orderDetail : JSON!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.hexStringToColor(BACKGROUNDCOLOR)
        tableView.register(UINib(nibName: "HeaderView", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "Header")
        if flag == 1 {
            arrReason = ["行程变动" , "航班延误" , "自愿升舱" , "其他"]
            self.setDesc("改签时需支付机票差价及政策规定的改签手续费。若费用变更，我们将及时联系您。 如有其他问题，请联系客服人员。")
        }else{
            arrReason = ["出行计划取消" , "航班被航空公司取消" , "需要变动行程，该航班不可以改签" , "其他"]
            getOrderDetail()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitTravelStandard(_ sender: AnyObject) {
        if flag == 1 {
            if selectedRow >= 0 {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ChangeTicket") as! changeTicketViewController
                controller.orderDetail = orderDetail
                controller.reason = arrReason[selectedRow]
                self.navigationController?.pushViewController(controller, animated: true)
            }else{
                Toast(text: "请选择改签的原因").show();
            }
        }else{
            submitReason()
        }
    }
    
    func getOrderDetail() {
        let manager = URLCollection()
        let hud = showHUD()
        if let token = manager.validateToken() {
            manager.getRequest(manager.getOrderDetail, params: ["orderId" : orderId as AnyObject], headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                hud.hide(animated: true)
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        self?.setDesc(model["Order" , "Route" , "ReturnPolicy" , "ReturnPolicyDesc"].string ?? "无")
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
    
    func setDesc(_ desc : String) {
        self.policyDesc = desc
        let attributeString = NSMutableAttributedString(string: self.policyDesc)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        attributeString.addAttributes([NSParagraphStyleAttributeName : style], range: NSMakeRange(0, attributeString.length))
        self.waringLabel.attributedText = attributeString
        let size = attributeString.boundingRect(with: CGSize(width: SCREENWIDTH - 30, height: 1000), options: [.usesLineFragmentOrigin , .usesFontLeading], context: nil).size
        self.tableView.tableHeaderView?.bounds = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: size.height + 20)
        self.tableView.reloadData()
    }
    
    func submitReason() {
        let manager = URLCollection()
        let hud = showHUD()
        var params : [String : Any] = [:]
        params["orderId"] = orderId
        if selectedRow >= 0 {
            params["returnReason"] = arrReason[selectedRow]
        }else{
            Toast(text: "请选择退票的原因").show();
        }
        if let token = manager.validateToken() {
            manager.postRequest(manager.returnApply, params: params , encoding : URLEncoding.default , headers: ["Token" : token], callback: {[weak self] (json, error) in
                hud.hide(animated: true)
                if let jsonObject = json {
                    if jsonObject["Code"].int == 0 {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OrderListTableViewController"), object: 3)
                        self?.navigationController?.popViewController(animated: true)
                    }else{
                        if let message = jsonObject["Message"].string {
                            Toast(text: message).show()
                        }
                    }
                }else{
                    Toast(text: "网络故障，请检查网络").show()
                }
                })
        }
        
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrReason.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        
        cell.textLabel?.text = arrReason[indexPath.row]
        
        if selectedRow == indexPath.row {
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
        header.titleLabel.text = flag == 1 ? "请选择改签的原因：" :"请选择退票原因："
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        tableView.reloadData()
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
