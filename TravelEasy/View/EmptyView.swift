//
//  EmptyView.swift
//  TravelEasy
//
//  Created by 张晓飞 on 2016/10/21.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit


class EmptyView: UIView {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var hintLabel: UILabel!
    
    enum EmptyType : Int {
        case noData = 0
        case noFuction = 1
        case noFlightData = 2
    }
    
    func setPropertyValue(_ emptyType : EmptyType)  {
        switch emptyType {
        case .noData:
            iconImageView.image = UIImage(named: "icon_noinfo")
            hintLabel.text = "暂无订单"
        case .noFuction:
            iconImageView.image = UIImage(named: "icon_unopen")
            hintLabel.text = "未开通审批功能"
        case .noFlightData:
            iconImageView.image = UIImage(named: "icon_noinfo")
            hintLabel.text = "没有查询到相关的内容"
        }
    }

}
