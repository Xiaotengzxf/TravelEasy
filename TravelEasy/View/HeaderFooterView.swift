//
//  HeaderFooterView.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/8/17.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit

class HeaderFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var startAirportLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var arriveTimeLabel: UILabel!
    @IBOutlet weak var arriveAirportLabel: UILabel!
    @IBOutlet weak var flightInfoLabel: UILabel!
    @IBOutlet weak var flightMoneyLabel: UILabel!
    @IBOutlet weak var stopLocationLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    var tap : UITapGestureRecognizer!
    var isExtand : Bool = false
    weak var delegate : HeaderFooterViewDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if tap == nil {
            tap = UITapGestureRecognizer(target: self, action: #selector(HeaderFooterView.extandBunks(_:)))
            tap.numberOfTapsRequired = 1
            self.addGestureRecognizer(tap)
        }
    }
    
    func extandBunks(sender : AnyObject!)  {
        isExtand = !isExtand
        delegate?.headerFooterViewIsExtandBunk(isExtand, tag: tag)
    }

}

@objc protocol HeaderFooterViewDelegate {
    func headerFooterViewIsExtandBunk(isExtand : Bool , tag : Int)
}