//
//  OrderListTableViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/14.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import MJRefresh
import Toaster
import SwiftyJSON
import PopupDialog
import Alamofire

class OrderListTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    var pageNumber = 1
    var pageSize = 10
    var totalCount = 0
    var arrOrder : [JSON] = []
    var selectedRow = -1
    var emptyView : EmptyView!
    var bEmpty = true
    var searchController: UISearchController!
    var passengerName = ""

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
        emptyView.isHidden = true
        self.tableView.mj_header.beginRefreshing()
        NotificationCenter.default.addObserver(self, selector: #selector(OrderListTableViewController.handleNotification(_:)), name: NSNotification.Name(rawValue: "OrderListTableViewController"), object: nil)
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emptyView.isHidden = bEmpty
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emptyView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Methods
    func getOrderList() {
        emptyView.isHidden = true
        bEmpty = true
        let manager = URLCollection()
        if let token = manager.validateToken() {
            manager.getRequest(manager.getMyFlightOrders, params: ["pageNumber" : pageNumber , "pageSize" : pageSize, "passengerName" : passengerName], headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                self?.tableView.mj_header.endRefreshing()
                self?.tableView.mj_footer.endRefreshing()
                if let json = jsonObject {
                    if let code = json["Code"].int, code == 0 {
                        self?.totalCount = json["TotalCount"].intValue
                        let array = json["Orders"].arrayValue
                        self?.arrOrder += array
                        self?.tableView.reloadData()
                        if self?.arrOrder.count == self?.totalCount {
                            self?.tableView.mj_footer.endRefreshingWithNoMoreData()
                        }
                        if self!.pageNumber == 1 && array.count == 0 {
                            self?.emptyView.isHidden = false
                            self?.bEmpty = false
                        }
                    }else{
                        if let message = json["Message"].string {
                            Toast(text: message).show()
                        }
                    }
                }else{
                    Toast(text: "网络不给力，请检查网络!").show()
                }
                })
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOrder.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! OrderTableViewCell
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
            cell.dateLabel.text = "\(time.substring(with: time.characters.index(time.startIndex, offsetBy: 5)..<time.characters.index(time.startIndex, offsetBy: 7)))月\(time.substring(with: time.characters.index(time.startIndex, offsetBy: 8)..<time.characters.index(time.startIndex, offsetBy: 10)))日 \(time.substring(from: time.characters.index(time.endIndex, offsetBy: -5)))"
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
            cell.cancelButton.isHidden = false
            cell.cancelButtonWidthConstraint.constant = 50
            cell.payToCancelLConstraint.constant = 10
        }else{
            cell.cancelButton.isHidden = true
            cell.cancelButtonWidthConstraint.constant = 0
            cell.payToCancelLConstraint.constant = 0
        }
        if canPayment {
            cell.payButton.isHidden = false
            cell.payButtonWidthConstraint.constant = 50
            cell.refundToPayLConstraint.constant = 10
        }else{
            cell.payButton.isHidden = true
            cell.payButtonWidthConstraint.constant = 0
            cell.refundToPayLConstraint.constant = 0
        }
        if canReturn {
            cell.refundButton.isHidden = false
            cell.refundButtonWidthConstraint.constant = 50
            cell.changeToRefundLConstraint.constant = 10
        }else{
            cell.refundButton.isHidden = true
            cell.refundButtonWidthConstraint.constant = 0
            cell.changeToRefundLConstraint.constant = 0
        }
        if canChange {
            cell.changeButton.isHidden = false
            cell.changeButtonWidthConstraint.constant = 50
            cell.netCheckInToChangeLConsraint.constant = 10
        }else{
            cell.changeButton.isHidden = true
            cell.changeButtonWidthConstraint.constant = 0
            cell.netCheckInToChangeLConsraint.constant = 0
        }
        if canNetCheckIn {
            cell.netCheckInButton.isHidden = false
            cell.netCheckInButtonWidthConstraint.constant = 70
        }else{
            cell.netCheckInButton.isHidden = true
            cell.netCheckInButtonWidthConstraint.constant = 0
        }
        if !canCancel && !canPayment && !canReturn && !canChange && !canNetCheckIn {
            cell.buttonsView.isHidden = true
            cell.buttonsViewHeightLConstraint.constant = 0
        }else{
            cell.buttonsView.isHidden = false
            cell.buttonsViewHeightLConstraint.constant = 44
        }
        cell.selectionStyle = .none
        return cell
    }
 
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? OrderDetailViewController {
            controller.orderDetail = arrOrder[selectedRow]
        }else if let controller = segue.destination as? OrderEventTableViewController {
            controller.orderId = arrOrder[selectedRow]["OrderId"].intValue
            controller.title = "退票"
        }else if let controller = segue.destination as? NetCheckInViewController {
            controller.orderId = arrOrder[selectedRow]["OrderId"].intValue
        }
    }
    
    
    func handleNotification(_ sender : Notification)  {
        if let tag = sender.object as? Int {
            if tag == 1 {
                if searchController.isActive {
                    return
                }
                if let row = sender.userInfo?["tag"] as? Int {
                    selectedRow = row
                    self.performSegue(withIdentifier: "toOrderDetail", sender: self)
                }
            }else if tag == 2 {
                if searchController.isActive {
                    return
                }
                if let row = sender.userInfo?["tag"] as? Int {
                    selectedRow = row / 10
                    switch row % 10 {
                    case 1:
                        cancelFlight(selectedRow)
                    case 2:
                        payOrder()
                    case 3:
                        self.performSegue(withIdentifier: "toOrderEvent", sender: self)
                    case 4:
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "OrderEvent") as! OrderEventTableViewController
                        controller.flag = 1
                        controller.orderDetail = arrOrder[selectedRow]
                        controller.title = "改签原因"
                        self.navigationController?.pushViewController(controller, animated: true)
                        
                    case 5:
                        self.performSegue(withIdentifier: "toNetCheckIn", sender: self)
                    default:
                        fatalError()
                    }
                }
            }else if tag == 3 {
                self.tableView.mj_header.beginRefreshing()
            }
        }
    }

    func cancelFlight(_ row : Int) {
        let alertController = UIAlertController(title: "提示", message: "您确定要取消该订单", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: {[weak self] (action) in
            let orderId = self!.arrOrder[row]["OrderId"].intValue
            self?.requestCancelFlight(orderId)
        }))
        self.present(alertController, animated: true) { 
            
        }
    }
    
    func requestCancelFlight(_ orderId : Int)  {
        let manager = URLCollection()
        if let token = manager.validateToken() {
            let hud = showHUD()
            manager.postRequest(manager.cancelApply, params: ["orderId" : orderId] , encoding : URLEncoding.default, headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                hud.hide(animated: true)
                if let json = jsonObject {
                    if let code = json["Code"].int, code == 0 {
                        Toast(text: "取消成功").show()
                        self?.tableView.mj_header.beginRefreshing()
                    }else{
                        if let message = json["Message"].string {
                            Toast(text: message).show()
                        }
                    }
                }else{
                    Toast(text: "网络不给力，请检查网络!").show()
                }
                })
        }
    }
    
    func payOrder() {
        let orderDetail = arrOrder[selectedRow]
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmOrder") as! ConfirmOrderViewController
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
        cancelButton.titleFont = UIFont.systemFont(ofSize: 15)
        
        let okButton = PopupDialogButton(title: "确认支付", dismissOnTap: true, action: { [weak self] in
            self?.askOrderConfirmByCorpCredit(orderDetail["OrderId"].intValue)
            
            })
        okButton.buttonColor = UIColor.hexStringToColor(TEXTCOLOR)
        okButton.titleColor = UIColor.white
        okButton.titleFont = UIFont.systemFont(ofSize: 15)
        dialog.addButtons([cancelButton , okButton])
        dialog.buttonAlignment = .horizontal
        self.present(dialog, animated: true, completion: {
            
        })
    }
    
    func askOrderConfirmByCorpCredit(_ askOrderId : Int) {
        let manager = URLCollection()
        let hud = showHUD()
        if let token = manager.validateToken() {
            manager.postRequest(manager.askOrderConfirmByCorpCredit, params: ["askOrderId" : askOrderId], encoding : URLEncoding.default ,headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                hud.hide(animated: true)
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        self?.tableView.mj_header.beginRefreshing()
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
    
    
    // delegate
    func updateSearchResults(for searchController: UISearchController) {
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let strSearchText = searchBar.text {
            passengerName = strSearchText
            self.pageNumber = 1
            self.arrOrder.removeAll()
            self.tableView.reloadData()
            self.getOrderList()
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        passengerName = ""
        self.pageNumber = 1
        self.arrOrder.removeAll()
        self.tableView.reloadData()
        self.getOrderList()
    }

}
