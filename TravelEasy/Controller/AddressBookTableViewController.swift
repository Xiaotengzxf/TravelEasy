//
//  AddressBookTableViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/1.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import SwiftyJSON
import MBProgressHUD
import Toaster

class AddressBookTableViewController: UITableViewController , UISearchResultsUpdating , UISearchControllerDelegate {
    
    var searchController : UISearchController!
    var dicEmployee : [String : [JSON]] = [:]
    var keys : [String] = []
    var arrCommonUser : [JSON] = []
    var arrFilterEmployee : [JSON] = []
    var hud : MBProgressHUD!
    var finished = 0
    var flag = 0
    var employee : JSON!
    var isUser = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "请输入姓名"
        tableView.tableHeaderView = searchController.searchBar
        tableView.sectionIndexColor = UIColor.hexStringToColor(FONTCOLOR)
        tableView.sectionIndexBackgroundColor = UIColor.clear
        tableView.sectionIndexTrackingBackgroundColor = UIColor.clear
        
        getAllEmployees()
        if flag != 1 {
            getCommonUsers()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.searchBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.searchBar.isHidden = true
        searchController.isActive = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        searchController = nil
    }
    
    // MARK: - Custom Action
    
    
    func getCommonUsers() {
        let manager = URLCollection()
        if let token = manager.validateToken() {
            manager.getRequest(manager.getMyStoredUsers, params: nil, headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        self?.arrCommonUser += model["AppMyStoredUsers"].arrayValue
                    }else{
                        if let message = model["Message"].string {
                            Toast(text: message).show()
                        }
                    }
                }
                self?.finished += 1
                self?.refreshView()
                })
        }
    }
    
    func getAllEmployees() {
        let manager = URLCollection()
        if let token = manager.validateToken() {
            hud = showHUDWindow()
            manager.getRequest(manager.getEmployees, params: ["PageSize" : 10000 , "PageNumber" : 1], headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        if let array = model["Employees"].array {
                            var sKeys : Set<String> = []
                            for model in array {
                                if let name = model["EmployeeName"].string {
                                    let key = String(format: "%c", pinyinFirstLetter(NSString(string : name).character(at: 0))).uppercased()
                                    sKeys.insert(key)
                                    if var arrModel = self?.dicEmployee[key] {
                                        arrModel.append(model)
                                        self?.dicEmployee[key] = arrModel
                                    }else{
                                        self?.dicEmployee[key] = [model]
                                    }
                                }
                            }
                            self?.keys += Array(sKeys).sorted(by: <)
                        }
                    }else{
                        if let message = model["Message"].string {
                            Toast(text: message).show()
                        }
                    }
                }
                self?.finished += 1
                self?.refreshView()
            })
        }
    }
    
    func refreshView() {
        if finished == 2 || (finished == 1 && flag == 1){
            hud.hide(animated: true)
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive {
            return 1
        }else{
            return flag == 1 ? keys.count : arrCommonUser.count + keys.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return arrFilterEmployee.count
        }else{
            if flag == 1 {
                return dicEmployee[keys[section]]!.count
            }else{
                if section == 0 {
                    return arrCommonUser.count
                }else{
                    return dicEmployee[keys[section - 1]]!.count
                }
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if searchController.isActive {
            let model = arrFilterEmployee[indexPath.row]
            cell.textLabel?.text = model["EmployeeName"].string
        }else{
            if flag == 1 {
                let model = dicEmployee[keys[indexPath.section]]![indexPath.row]
                cell.textLabel?.text = model["EmployeeName"].string
            }else {
                if indexPath.section == 0 {
                    let model = arrCommonUser[indexPath.row]
                    cell.textLabel?.text = model["Name"].string
                }else{
                    let model = dicEmployee[keys[indexPath.section - 1]]![indexPath.row]
                    cell.textLabel?.text = model["EmployeeName"].string
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if searchController.isActive {
            return 0
        }else{
            return index
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive {
            return nil
        }else{
            return flag == 1 ? keys : ["#"] + keys
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive {
            return nil
        }else{
            if flag == 1 {
                return keys[section]
            }else{
                if section == 0 {
                    return "常用姓名"
                }else{
                    return keys[section - 1]
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if searchController.isActive {
            employee = arrFilterEmployee[indexPath.row]
        }else{
            if flag == 1 {
                employee = dicEmployee[keys[indexPath.section]]![indexPath.row]
            }else {
                if indexPath.section == 0 {
                    employee = arrCommonUser[indexPath.row]
                    isUser = true
                }else{
                    employee = dicEmployee[keys[indexPath.section - 1]]![indexPath.row]
                }
            }
        }
        if flag == 1 {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "NewApprovalViewController"), object: 1, userInfo: ["json" : employee.object , "isUser" : isUser])
            self.navigationController?.popViewController(animated: true)
        }else{
            NotificationCenter.default.post(name: Notification.Name(rawValue: "EditEmployeeViewController"), object: 3, userInfo: ["json" : employee.object , "isUser" : isUser])
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    // MARK: - Search Results Updating
    func updateSearchResults(for searchController: UISearchController) {
        arrFilterEmployee.removeAll()
        if let text = searchController.searchBar.text {
            for array in dicEmployee.values {
                for model in array {
                    if let name = model["EmployeeName"].string {
                        let predicate = NSPredicate(format: "SELF CONTAINS[c] %@" , text)
                        if predicate.evaluate(with: name) {
                            arrFilterEmployee.append(model)
                        }
                    }
                }
            }
            
        }
        self.tableView.reloadData()
        
    }
    
    // MARK: -Search Controller Delegate
    func willPresentSearchController(_ searchController: UISearchController) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
    }
}
