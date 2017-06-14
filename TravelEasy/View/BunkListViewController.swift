//
//  BunkListViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/5.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit

class BunkListViewController: UIViewController , UITableViewDataSource , UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomLConstraint: NSLayoutConstraint!
    var bunks : [String] = []
    var selectedRow = 0
    var flag = 0
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewHeightConstraint.constant = CGFloat(bunks.count) * 40
        tableViewBottomLConstraint.constant = -CGFloat(bunks.count) * 40
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
    
    
    // MARK: - UITableView Source and Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bunks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.font = UIFont.systemFontOfSize(FONT2)
        cell.textLabel?.textColor = UIColor.hexStringToColor(selectedRow == indexPath.row ? TEXTCOLOR :FONTCOLOR)
        cell.accessoryView = UIImageView(image: UIImage(named: selectedRow == indexPath.row ? "icon_radio_pr" : "icon_radio_un"))
        cell.textLabel?.text = bunks[indexPath.row]
        cell.selectionStyle = .None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedRow = indexPath.row
        tableView.reloadData()
        selectedBunk()
    }
    
    func selectedBunk() {
        if flag == 3 {
            NSNotificationCenter.defaultCenter().postNotificationName("EditEmployeeViewController", object: 1, userInfo: ["row" : selectedRow])
        }else{
            NSNotificationCenter.defaultCenter().postNotificationName("FlightListViewController\(flag)", object: 4, userInfo: ["row" : selectedRow])
        }
        tableViewBottomLConstraint.constant = -CGFloat(bunks.count) * 40
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .CurveEaseInOut, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }) {[weak self] (finished) in
            self?.dismissViewControllerAnimated(true) {
                
            }
        }
        
    }
    

}
