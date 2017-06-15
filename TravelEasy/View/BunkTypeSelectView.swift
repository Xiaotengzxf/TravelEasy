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
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    func show() {
        self.isHidden = false
        if tableView == nil {
            tableView = UITableView(frame: CGRect.zero, style: .plain)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.isScrollEnabled = false
            tableView.bounces = false
            self.addSubview(tableView)
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : tableView]))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[tableView(132)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["tableView" : tableView]))
            constraint = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            self.addConstraint(constraint)
        }
        self.perform(#selector(BunkTypeSelectView.showAnimation), with: nil, afterDelay: 0.1)
    }
    
    func showAnimation() {
        constraint.constant = -132
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        }) 
    }
    
    func hide() {
        constraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: { 
            self.layoutIfNeeded()
            }, completion: {[weak self] (finished) in
                self?.isHidden = true
        }) 
    }
    
    func hideAnimationWithRecognizer(_ point : CGPoint) {
        if !tableView.frame.contains(point) {
            hide()
        }
    }
    
    // MARK : - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel?.text = bunks[indexPath.row]
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell?.textLabel?.textColor = UIColor.hexStringToColor(FONTCOLOR)
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSelectedRow = indexPath.row
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryView = UIImageView(image: UIImage(named: "icon_selcity_seleted"))
        cell?.textLabel?.textColor = UIColor.hexStringToColor("ff6600")
        self.delegate?.bunkTypeSelectedViewWithSelectedRow(currentSelectedRow)
        self.hide()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryView = nil
        cell?.textLabel?.textColor = UIColor.hexStringToColor(FONTCOLOR)
    }
    
//    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
//        tableView.layoutMargins = UIEdgeInsetsZero
//        tableView.separatorInset = UIEdgeInsetsZero
//    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            if let touch = touches.first {
                hideAnimationWithRecognizer(touch.location(in: self))
            }
        }
    }

}

@objc protocol BunkTypeSelectViewDelegate {
    func bunkTypeSelectedViewWithSelectedRow(_ row : NSInteger)
}
