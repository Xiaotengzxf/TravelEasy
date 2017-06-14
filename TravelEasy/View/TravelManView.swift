//
//  TravelManView.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/8.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit

class TravelManView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
   
    @IBAction func deleteTravelMan(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("NewApprovalViewController", object: 2, userInfo: ["tag" : tag])
    }

}
