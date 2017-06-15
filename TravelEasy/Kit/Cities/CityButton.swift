//
//  CityButton.swift
//  CityListDemo
//
//  Created by ray on 15/11/30.
//  Copyright © 2015年 ray. All rights reserved.
//

import UIKit

class CityButton: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        //添加圆角
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
        //添加变宽
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.hexStringToColor("e0e1e2").cgColor
        
    }

}
