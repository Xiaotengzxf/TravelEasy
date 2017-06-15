//
//  PassengerView.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/6.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit

class PassengerView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var approvalTipLabel: UILabel!
    @IBOutlet weak var departmentTipLabel: UILabel!
    

    @IBAction func deletePassenger(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "WriteOrderViewController"), object: 3 , userInfo: ["tag" : tag])
    }

    @IBAction func detailPasseger(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "WriteOrderViewController"), object: 2 , userInfo: ["tag" : tag])
    }
}
