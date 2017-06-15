//
//  ChooseProjectTableViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/3.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import SwiftyJSON
import MBProgressHUD
import Toaster

class ChooseProjectTableViewController: UITableViewController {
    
    var arrProject : [JSON] = []
    var delegate : ChooseProjectTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        getProjects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        print("ChooseProjectTableViewController")
    }
    
    // MARK: - Custom Action
    
    func getProjects() {
        let manager = URLCollection()
        let hud = showHUD()
        if let token = manager.validateToken() {
            manager.getRequest(manager.getProjects, params: ["nameLike" : "" as AnyObject , "pageSize" : 1000 as AnyObject , "pageNumber" : 1 as AnyObject], headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                hud.hide(animated: true)
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        self?.arrProject += model["Projects"].arrayValue
                        self?.tableView.reloadData()
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

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrProject.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.textLabel?.textColor = UIColor.hexStringToColor(FONTCOLOR)
        cell.accessoryView = UIImageView(image: UIImage(named: "icon_radio_un"))
        cell.selectionStyle = .none
        cell.textLabel?.text = arrProject[indexPath.row ]["ProjectName"].string
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        cell?.textLabel?.textColor = UIColor.hexStringToColor(TEXTCOLOR)
        cell?.accessoryView = UIImageView(image: UIImage(named: "icon_radio_pr"))
        self.perform(#selector(ChooseProjectTableViewController.chooseProjectSuccess(_:)), with: indexPath, afterDelay: 0.2)
    }
    
    func chooseProjectSuccess(_ indexPath : IndexPath)  {
        delegate?.chooseProjectWithJSON(arrProject[indexPath.row])
        self.navigationController?.popViewController(animated: true)
        
    }

}

protocol ChooseProjectTableViewControllerDelegate {
    func chooseProjectWithJSON(_ project : JSON)
}
