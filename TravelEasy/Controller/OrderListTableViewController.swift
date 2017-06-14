//
//  OrderListTableViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/14.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import MJRefresh
import JLToast
import SwiftyJSON
import PopupDialog

class OrderListTableViewController: UITableViewController {
    
    var pageNumber = 1
    var pageSize = 10
    var totalCount = 0
    var arrOrder : [JSON] = []
    var selectedRow = -1
    var emptyView : EmptyView!
    var bEmpty = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.pageNumber = 1
            self?.arrOrder.removeAll()
            self?.tableView.reloadData()
            self?.getOrderList()
            
        })
        self.tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: { [weak self] in
            self?.pageNumber += 1
            self?.getOrderList()
        })
        emptyView = EmptyManager.getInstance.insertEmptyView(with: self.navigationController!.view!, top: 64, emptyType: .noData)
        emptyView.hidden = true
        self.tableView.mj_header.beginRefreshing()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OrderListTableViewController.handleNotification(_:)), name: "OrderListTableViewController", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        emptyView.hidden = bEmpty
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        emptyView.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Methods
    func getOrderList() {
        emptyView.hidden = true
        bEmpty = true
        let manager = URLCollection()
        if let token = manager.validateToken() {
            manager.getRequest(manager.getMyFlightOrders, params: ["pageNumber" : pageNumber , "pageSize" : pageSize], headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                self?.tableView.mj_header.endRefreshing()
                self?.tableView.mj_footer.endRefreshing()
                if let json = jsonObject {
                    if let code = json["Code"].int where code == 0 {
                        self?.totalCount = json["TotalCount"].intValue
                        let array = json["Orders"].arrayValue
                        self?.arrOrder += array
                        self?.tableView.reloadData()
                        if self?.arrOrder.count == self?.totalCount {
                            self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                        }
                        if self!.pageNumber == 1 && array.count == 0 {
                            self?.emptyView.hidden = false
                            self?.bEmpty = false
                        }
                    }else{
                        if let message = json["Message"].string {
                            JLToast.makeText(message).show()
                        }
                    }
                }else{
                    JLToast.makeText("网络不给力，请检查网络!").show()
                }
                })
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOrder.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! OrderTableViewCell
        let order = arrOrder[indexPath.row]
        cell.tag = indexPath.row
        cell.cityLabel.text = "\(order["DepartureCityName"].stringValue)-\(order["ArrivalCityName"].stringValue)"
        cell.statusLabel.text = order["Status"].stringValue
        cell.airlineNameLabel.text = order["AirlineName"].stringValue
        cell.flightNoLabel.text = order["FlightNo"].stringValue
        let discount = order["Discount"].intValue
        cell.discountLabel.text =  "\(discount < 100 ? "\(Float(discount) / 10)折" : "全价")\(order["BunkName"].stringValue)"
        cell.priceLabel.text = "¥\(order["PaymentAmount"].intValue)"
        let time = order["DepartureDateTime"].stringValue
        if time.characters.count == 16 {
            cell.dateLabel.text = "\(time.substringWithRange(time.startIndex.advancedBy(5)..<time.startIndex.advancedBy(7)))月\(time.substringWithRange(time.startIndex.advancedBy(8)..<time.startIndex.advancedBy(10)))日 \(time.substringFromIndex(time.endIndex.advancedBy(-5)))"
        }else{
            cell.dateLabel.text = time
        }
        cell.passengerLabel.text = order["PassengerName"].stringValue
        let canCancel = order["CanCancel"].boolValue
        let canPayment = order["CanPayment"].boolValue
        let canReturn = order["CanReturn"].boolValue
        let canChange = order["CanChange"].boolValue
        let canNetCheckIn = order["CanNetCheckIn"].boolValue
        if canCancel {
            cell.cancelButton.hidden = false
            cell.cancelButtonWidthConstraint.constant = 50
            cell.payToCancelLConstraint.constant = 10
        }else{
            cell.cancelButton.hidden = true
            cell.cancelButtonWidthConstraint.constant = 0
            cell.payToCancelLConstraint.constant = 0
        }
        if canPayment {
            cell.payButton.hidden = false
            cell.payButtonWidthConstraint.constant = 50
            cell.refundToPayLConstraint.constant = 10
        }else{
            cell.payButton.hidden = true
            cell.payButtonWidthConstraint.constant = 0
            cell.refundToPayLConstraint.constant = 0
        }
        if canReturn {
            cell.refundButton.hidden = false
            cell.refundButtonWidthConstraint.constant = 50
            cell.changeToRefundLConstraint.constant = 10
        }else{
            cell.refundButton.hidden = true
            cell.refundButtonWidthConstraint.constant = 0
            cell.changeToRefundLConstraint.constant = 0
        }
        if canChange {
            cell.changeButton.hidden = false
            cell.changeButtonWidthConstraint.constant = 50
            cell.netCheckInToChangeLConsraint.constant = 10
        }else{
            cell.changeButton.hidden = true
            cell.changeButtonWidthConstraint.constant = 0
            cell.netCheckInToChangeLConsraint.constant = 0
        }
        if canNetCheckIn {
            cell.netCheckInButton.hidden = false
            cell.netCheckInButtonWidthConstraint.constant = 70
        }else{
            cell.netCheckInButton.hidden = true
            cell.netCheckInButtonWidthConstraint.constant = 0
        }
        if !canCancel && !canPayment && !canReturn && !canChange && !canNetCheckIn {
            cell.buttonsView.hidden = true
            cell.buttonsViewHeightLConstraint.constant = 0
        }else{
            cell.buttonsView.hidden = false
            cell.buttonsViewHeightLConstraint.constant = 44
        }
        cell.selectionStyle = .None
        return cell
    }
 
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 160
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? OrderDetailViewController {
            controller.orderDetail = arrOrder[selectedRow]
        }else if let controller = segue.destinationViewController as? OrderEventTableViewController {
            controller.orderId = arrOrder[selectedRow]["OrderId"].intValue
            controller.title = "退票"
        }else if let controller = segue.destinationViewController as? NetCheckInViewController {
            controller.orderId = arrOrder[selectedRow]["OrderId"].intValue
        }
    }
    
    
    func handleNotification(sender : NSNotification)  {
        if let tag = sender.object as? Int {
            if tag == 1 {
                if let row = sender.userInfo?["tag"] as? Int {
                    selectedRow = row
                    self.performSegueWithIdentifier("toOrderDetail", sender: self)
                }
            }else if tag == 2 {
                if let row = sender.userInfo?["tag"] as? Int {
                    selectedRow = row / 10
                    switch row % 10 {
                    case 1:
                        cancelFlight(selectedRow)
                    case 2:
                        payOrder()
                    case 3:
                        self.performSegueWithIdentifier("toOrderEvent", sender: self)
                    case 4:
                        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("OrderEvent") as! OrderEventTableViewController
                        controller.flag = 1
                        controller.orderDetail = arrOrder[selectedRow]
                        controller.title = "改签原因"
                        self.navigationController?.pushViewController(controller, animated: true)
                        
                    case 5:
                        self.performSegueWithIdentifier("toNetCheckIn", sender: self)
                    default:
                        fatalError()
                    }
                }
            }else if tag == 3 {
                self.tableView.mj_header.beginRefreshing()
            }
        }
    }

    func cancelFlight(row : Int) {
        let alertController = UIAlertController(title: "提示", message: "您确定要取消该订单", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (action) in
            
        }))
        alertController.addAction(UIAlertAction(title: "确定", style: .Default, handler: {[weak self] (action) in
            let orderId = self!.arrOrder[row]["OrderId"].intValue
            self?.requestCancelFlight(orderId)
        }))
        self.presentViewController(alertController, animated: true) { 
            
        }
    }
    
    func requestCancelFlight(orderId : Int)  {
        let manager = URLCollection()
        if let token = manager.validateToken() {
            let hud = showHUD()
            manager.postRequest(manager.cancelApply, params: ["orderId" : orderId] , encoding : .URLEncodedInURL, headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                hud.hideAnimated(true)
                if let json = jsonObject {
                    if let code = json["Code"].int where code == 0 {
                        JLToast.makeText("取消成功").show()
                        self?.tableView.mj_header.beginRefreshing()
                    }else{
                        if let message = json["Message"].string {
                            JLToast.makeText(message).show()
                        }
                    }
                }else{
                    JLToast.makeText("网络不给力，请检查网络!").show()
                }
                })
        }
    }
    
    func payOrder() {
        let orderDetail = arrOrder[selectedRow]
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("ConfirmOrder") as! ConfirmOrderViewController
        controller.passengerName = orderDetail["PassengerName"].stringValue
        controller.travelLine = orderDetail["DepartureCityName"].stringValue + "-" + orderDetail["ArrivalCityName"].stringValue
        controller.date = orderDetail["DepartureDateTime"].stringValue + " 出发"
        controller.money = "¥\(orderDetail["PaymentAmount"].intValue)"
        
        let dialog = PopupDialog(viewController: controller)
        controller.popupDidalog = dialog
        if let contentView = dialog.view as? PopupDialogContainerView {
            contentView.cornerRadius = 10
        }
        let cancelButton = PopupDialogButton(title: "取消", dismissOnTap: true, action: {
            
        })
        cancelButton.buttonColor = UIColor.hexStringToColor(BACKGROUNDCOLOR)
        cancelButton.titleColor = UIColor.hexStringToColor(FONTCOLOR)
        cancelButton.titleFont = UIFont.systemFontOfSize(15)
        
        let okButton = PopupDialogButton(title: "确认支付", dismissOnTap: true, action: { [weak self] in
            self?.askOrderConfirmByCorpCredit(orderDetail["OrderId"].intValue)
            
            })
        okButton.buttonColor = UIColor.hexStringToColor(TEXTCOLOR)
        okButton.titleColor = UIColor.whiteColor()
        okButton.titleFont = UIFont.systemFontOfSize(15)
        dialog.addButtons([cancelButton , okButton])
        dialog.buttonAlignment = .Horizontal
        self.presentViewController(dialog, animated: true, completion: {
            
        })
    }
    
    func askOrderConfirmByCorpCredit(askOrderId : Int) {
        let manager = URLCollection()
        let hud = showHUD()
        if let token = manager.validateToken() {
            manager.postRequest(manager.askOrderConfirmByCorpCredit, params: [ "askOrderId" : askOrderId], encoding : .URLEncodedInURL ,headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                hud.hideAnimated(true)
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        self?.tableView.mj_header.beginRefreshing()
                    }else{
                        if let message = model["Message"].string {
                            JLToast.makeText(message).show()
                        }
                    }
                }else{
                    JLToast.makeText("网络不给力，请检查网络！").show()
                }
                })
        }
    }

}
