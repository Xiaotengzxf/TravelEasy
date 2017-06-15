//
//  SectionView.swift
//  CityListDemo
//
//  Created by ray on 15/11/30.
//  Copyright © 2015年 ray. All rights reserved.
//

import UIKit

class SectionView: UIView {

    @IBOutlet weak var labelCityName: UILabel!
    
    class func viewFromNibNamed()->SectionView {
        return Bundle.main.loadNibNamed("SectionView", owner: self, options: nil)![0] as! SectionView
    }
   
    func addData(_ string:String){
        self.labelCityName.text = string
    }

}
