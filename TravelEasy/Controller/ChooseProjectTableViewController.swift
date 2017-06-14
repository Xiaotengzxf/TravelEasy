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
import JLToast

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
            manager.getRequest(manager.getProjects, params: ["nameLike" : "" , "pageSize" : 1000 , "pageNumber" : 1], headers: ["token" : token], callback: { [weak self] (jsonObject, error) in
                hud.hideAnimated(true)
                if let model = jsonObject {
                    if model["Code"].int == 0 {
                        self?.arrProject += model["Projects"].arrayValue
                        self?.tableView.reloadData()
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

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrProject.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.font = UIFont.systemFontOfSize(13)
        cell.textLabel?.textColor = UIColor.hexStringToColor(FONTCOLOR)
        cell.accessoryView = UIImageView(image: UIImage(named: "icon_radio_un"))
        cell.selectionStyle = .None
        cell.textLabel?.text = arrProject[indexPath.row ]["ProjectName"].string
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.textLabel?.textColor = UIColor.hexStringToColor(TEXTCOLOR)
        cell?.accessoryView = UIImageView(image: UIImage(named: "icon_radio_pr"))
        self.performSelector(#selector(ChooseProjectTableViewController.chooseProjectSuccess(_:)), withObject: indexPath, afterDelay: 0.2)
    }
    
    func chooseProjectSuccess(indexPath : NSIndexPath)  {
        delegate?.chooseProjectWithJSON(arrProject[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
        
    }

}

protocol ChooseProjectTableViewControllerDelegate {
    func chooseProjectWithJSON(project : JSON)
}
