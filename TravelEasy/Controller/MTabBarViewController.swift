//
//  MTabBarViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 2016/10/13.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit

class MTabBarViewController: UITabBarController {
    
    var approvalRequired = false
    var overrunOption = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MTabBarViewController.handleNotification(_:)), name: "MTabBarViewController", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let info = NSUserDefaults.standardUserDefaults().objectForKey("info") as? [String : AnyObject] {
            approvalRequired = info["ApprovalRequired"] as! Bool
            overrunOption = info["OverrunOption"] as! String
        }
        
        let approvalCount = NSUserDefaults.standardUserDefaults().integerForKey("approvalCount")
        let authorizeCount = NSUserDefaults.standardUserDefaults().integerForKey("authorizeCount")
        if let items = tabBar.items {
            if items.count > 1 {
                var count = 0
                if approvalRequired {
                    count += approvalCount
                }
                if overrunOption == "WarningAndAuthorize" {
                    count += authorizeCount
                }
                items[1].badgeValue = count > 0 ? "\(count)" : nil
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func handleNotification(sender : NSNotification)  {
        if let tag = sender.object as? Int {
            if tag <= 4 {
                selectedIndex = tag - 1
                if tag == 3 {
                    NSNotificationCenter.defaultCenter().postNotificationName("OrderListTableViewController", object: 3)
                }
            }else if tag == 12 {
                if let info = NSUserDefaults.standardUserDefaults().objectForKey("info") as? [String : AnyObject] {
                    approvalRequired = info["ApprovalRequired"] as! Bool
                    overrunOption = info["OverrunOption"] as! String
                }
                let approvalCount = NSUserDefaults.standardUserDefaults().integerForKey("approvalCount")
                let authorizeCount = NSUserDefaults.standardUserDefaults().integerForKey("authorizeCount")
                if let items = tabBar.items {
                    if items.count > 1 {
                        var count = 0
                        if approvalRequired {
                            count += approvalCount
                        }
                        if overrunOption == "WarningAndAuthorize" {
                            count += authorizeCount
                        }
                        items[1].badgeValue = count > 0 ? "\(count)" : nil
                        if count > 0 {
                            selectedIndex = 1
                        }
                    }
                }
                if approvalCount > 0 || authorizeCount > 0 {
                    NSNotificationCenter.defaultCenter().postNotificationName("ApprovalListViewController", object: 4)
                }
            }else if tag == 13 {
                if let info = NSUserDefaults.standardUserDefaults().objectForKey("info") as? [String : AnyObject] {
                    approvalRequired = info["ApprovalRequired"] as! Bool
                    overrunOption = info["OverrunOption"] as! String
                }
                let approvalCount = NSUserDefaults.standardUserDefaults().integerForKey("approvalCount")
                let authorizeCount = NSUserDefaults.standardUserDefaults().integerForKey("authorizeCount")
                if let items = tabBar.items {
                    if items.count > 1 {
                        var count = 0
                        if approvalRequired {
                            count += approvalCount
                        }
                        if overrunOption == "WarningAndAuthorize" {
                            count += authorizeCount
                        }
                        items[1].badgeValue = count > 0 ? "\(count)" : nil
                    }
                }
            }
        }
    }
    

    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
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
