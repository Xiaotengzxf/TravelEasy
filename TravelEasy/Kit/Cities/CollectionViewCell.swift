//
//  CollectionViewCell.swift
//  CityListDemo
//
//  Created by ray on 15/12/2.
//  Copyright © 2015年 ray. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cityLabel: UILabel!
    
    func addData(city : [String : AnyObject]){
        
        cityLabel.text = city["Name"] as? String
        
    }
   
}
