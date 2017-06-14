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
        tableView.tableHeaderView?.bounds = CGRectMake(0, 0, SCREENWIDTH, 40)
        cancelButton.layer.borderColor = UIColor.hexStringToColor(BUTTON2BGCOLORHIGHLIGHT).CGColor
        cancelButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), forState: .Highlighted)
        cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        okButton.setBackgroundImage(UIImage.imageWithColor(BUTTONBGCOLORHIGHLIGHT), forState: .Highlighted)
        if arrSelectedRow.count == 0 {
            arrSelectedRow.insert(0)
        }
        if arrAirline != nil && arrAirline.count > 0 {
            tableViewHeightLConstraint.constant = CGFloat(arrAirline.count * 40)
            tableViewBottomLConstraint.constant = -(tableViewHeightLConstraint.constant + 40)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableViewBottomLConstraint.constant = 0
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .CurveEaseInOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }) { (finished) in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count == 1 {
            if let touch = touches.first {
                if !tableView.frame.contains(touch.locationInView(self.view)) {
                    self.dismissViewControllerAnimated(true, completion: { 
                        
                    })
                }
            }
        }
    }
    
    // MARK: -UITableView Datasource and Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAirline.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.font = UIFont.systemFontOfSize(FONT2)
        cell.textLabel?.textColor = UIColor.hexStringToColor(arrSelectedRow.contains(indexPath.row) ? TEXTCOLOR :FONTCOLOR)
        cell.accessoryView = UIImageView(image: UIImage(named: arrSelectedRow.contains(indexPath.row) ? "icon_checkbox_un" : "icon_checkbox_pr"))
        cell.textLabel?.text = arrAirline[indexPath.row]
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
    
    @IBAction func cancelSelectingAirline(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { 
            
        }
    }
    
    @IBAction func finishedAndBackWithSelectedAirline(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("FlightListViewController\(flag)", object: 3, userInfo: ["rows" : Array(arrSelectedRow)])
        self.dismissViewControllerAnimated(true) {
            
        }
    }
    

}
