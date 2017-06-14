//
//  FlightTableViewCell.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/8/28.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit

class FlightTableViewCell: UITableViewCell {

    @IBOutlet weak var bunkNameLabel: UILabel!
    @IBOutlet weak var discountInfoLabel: UILabel!
    @IBOutlet weak var bunkPriceLabel: UILabel!
    @IBOutlet weak var remainNumLabel: UILabel!
    @IBOutlet weak var bookButton: UIButton!
    var indexPath :NSIndexPath!
    var flag = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**
     退改签
     
     - parameter sender: 按钮
     */
    @IBAction func returnOrChange(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("FlightListViewController\(flag)", object: 1, userInfo: ["indexPath" : indexPath])
    }

    /**
     预定
     
     - parameter sender: 按钮
     */
    @IBAction func bookFlight(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("FlightListViewController\(flag)", object: 2, userInfo: ["indexPath" : indexPath])
        
    }
}
