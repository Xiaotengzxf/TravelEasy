//
//  DepartmentListViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 2016/10/12.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import Toaster
import SwiftyJSON

class DepartmentListViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var tableData : [JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    func loadData() {
        let manager = URLCollection()
        let hud = showHUD()
        if let token = manager.validateToken() {
            manager.getRequest(manager.getDepartments, params: nil, headers: ["Token" : token], callback: {[weak self] (jsonObject, error) in
                hud.hide(animated: true)
                if let json = jsonObject {
                    if let code = json["Code"].int, code == 0 {
                        var department = json["Department"]
                        department["level"].int = 1
                        self?.tableData.append(department)
                        let array = json["Department" , "ChildDepartments"].arrayValue
                        for var item in array {
                            item["level"].int = 2
                            self?.tableData.append(item)
                            for var subItem in item["ChildDepartments"].arrayValue {
                                subItem["level"].int = 3
                                self?.tableData.append(subItem)
                            }
                        }
                        self?.tableView.reloadData()
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.row]["Name"].string
        return cell
    }
    
    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if tableData.count > 0 {
            return tableData[indexPath.row]["level"].intValue
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "EditEmployeeViewController"), object: 2, userInfo: ["name" : tableData[indexPath.row]["Name"].stringValue , "id" : tableData[indexPath.row]["Id"].intValue])
        self.navigationController?.popViewController(animated: true)
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
