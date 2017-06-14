//
//  BunkTypeSelectView.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/8/21.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit

class BunkTypeSelectView: UIView , UITableViewDataSource , UITableViewDelegate {
    
    let bunks = ["不限舱位" , "经济舱" , "公务／头等舱"]
    var currentSelectedRow = -1
    var tableView : UITableView!
    var constraint : NSLayoutConstraint!
    weak var delegate : BunkTypeSelectViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    }
    
    func show() {
        self.hidden = false
        if tableView == nil {
            tableView = UITableView(frame: CGRectZero, style: .Plain)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.scrollEnabled = false
            tableView.bounces = false
            self.addSubview(tableView)
            
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["tableView" : tableView]))
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[tableView(132)]", options: .DirectionLeadingToTrailing, metrics: nil, views: ["tableView" : tableView]))
            constraint = NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
            self.addConstraint(constraint)
        }
        self.performSelector(#selector(BunkTypeSelectView.showAnimation), withObject: nil, afterDelay: 0.1)
    }
    
    func showAnimation() {
        constraint.constant = -132
        UIView.animateWithDuration(0.3) {
            self.layoutIfNeeded()
        }
    }
    
    func hide() {
        constraint.constant = 0
        UIView.animateWithDuration(0.3, animations: { 
            self.layoutIfNeeded()
            }) {[weak self] (finished) in
                self?.hidden = true
        }
    }
    
    func hideAnimationWithRecognizer(point : CGPoint) {
        if !tableView.frame.contains(point) {
            hide()
        }
    }
    
    // MARK : - TableView DataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel?.text = bunks[indexPath.row]
        cell?.textLabel?.font = UIFont.systemFontOfSize(15)
        cell?.textLabel?.textColor = UIColor.hexStringToColor(FONTCOLOR)
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentSelectedRow = indexPath.row
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryView = UIImageView(image: UIImage(named: "icon_selcity_seleted"))
        cell?.textLabel?.textColor = UIColor.hexStringToColor("ff6600")
        self.delegate?.bunkTypeSelectedViewWithSelectedRow(currentSelectedRow)
        self.hide()
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryView = nil
        cell?.textLabel?.textColor = UIColor.hexStringToColor(FONTCOLOR)
    }
    
//    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
//        tableView.layoutMargins = UIEdgeInsetsZero
//        tableView.separatorInset = UIEdgeInsetsZero
//    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count == 1 {
            if let touch = touches.first {
                hideAnimationWithRecognizer(touch.locationInView(self))
            }
        }
    }

}

@objc protocol BunkTypeSelectViewDelegate {
    func bunkTypeSelectedViewWithSelectedRow(row : NSInteger)
}
