//
//  AirlineListViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/4.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit

class AirlineListViewController: UIViewController , UITableViewDataSource , UITableViewDelegate {
    
    @IBOutlet weak var tableViewHeightLConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var tableViewBottomLConstraint: NSLayoutConstraint!
    var arrAirline : [String]!
    var arrSelectedRow : Set<Int> = []
    var flag = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView?.bounds = CGRect(x: 0, y: 0, width: SCREENWIDTH, height: 40)
        cancelButton.layer.borderColor = UIColor.hexStringToColor(BUTTON2BGCOLORHIGHLIGHT).cgColor
        cancelButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), for: .highlighted)
        cancelButton.setTitleColor(UIColor.white, for: .highlighted)
        okButton.setBackgroundImage(UIImage.imageWithColor(BUTTONBGCOLORHIGHLIGHT), for: .highlighted)
        if arrSelectedRow.count == 0 {
            arrSelectedRow.insert(0)
        }
        if arrAirline != nil && arrAirline.count > 0 {
            tableViewHeightLConstraint.constant = CGFloat(arrAirline.count * 40)
            tableViewBottomLConstraint.constant = -(tableViewHeightLConstraint.constant + 40)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableViewBottomLConstraint.constant = 0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: UIViewAnimationOptions(), animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }) { (finished) in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            if let touch = touches.first {
                if !tableView.frame.contains(touch.location(in: self.view)) {
                    self.dismiss(animated: true, completion: { 
                        
                    })
                }
            }
        }
    }
    
    // MARK: -UITableView Datasource and Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAirline.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: FONT2)
        cell.textLabel?.textColor = UIColor.hexStringToColor(arrSelectedRow.contains(indexPath.row) ? TEXTCOLOR :FONTCOLOR)
        cell.accessoryView = UIImageView(image: UIImage(named: arrSelectedRow.contains(indexPath.row) ? "icon_checkbox_un" : "icon_checkbox_pr"))
        cell.textLabel?.text = arrAirline[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            arrSelectedRow.removeAll()
            arrSelectedRow.insert(indexPath.row)
        }else{
            if arrSelectedRow.contains(indexPath.row) {
                arrSelectedRow.remove(indexPath.row)
            }else{
                arrSelectedRow.insert(indexPath.row)
                arrSelectedRow.remove(0)
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func cancelSelectingAirline(_ sender: AnyObject) {
        self.dismiss(animated: true) { 
            
        }
    }
    
    @IBAction func finishedAndBackWithSelectedAirline(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "FlightListViewController\(flag)"), object: 3, userInfo: ["rows" : Array(arrSelectedRow)])
        self.dismiss(animated: true) {
            
        }
    }
    

}
