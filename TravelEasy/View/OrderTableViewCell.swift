//
//  OrderTableViewCell.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/14.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var airlineNameLabel: UILabel!
    @IBOutlet weak var flightNoLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var passengerLabel: UILabel!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var refundButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var netCheckInButton: UIButton!
    @IBOutlet weak var payToCancelLConstraint: NSLayoutConstraint!
    @IBOutlet weak var refundToPayLConstraint: NSLayoutConstraint!
    @IBOutlet weak var changeToRefundLConstraint: NSLayoutConstraint!
    @IBOutlet weak var netCheckInToChangeLConsraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsViewHeightLConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var payButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var refundButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var changeButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var netCheckInButtonWidthConstraint: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cancelButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).CGColor
        cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        cancelButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), forState: .Disabled)
        cancelButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), forState: .Highlighted)
        payButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).CGColor
        payButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        payButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), forState: .Disabled)
        payButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), forState: .Highlighted)
        refundButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).CGColor
        refundButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        refundButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), forState: .Disabled)
        refundButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), forState: .Highlighted)
        changeButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).CGColor
        changeButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        changeButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), forState: .Disabled)
        changeButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), forState: .Highlighted)
        netCheckInButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).CGColor
        netCheckInButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        netCheckInButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), forState: .Disabled)
        netCheckInButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), forState: .Highlighted)
    }
    
    @IBAction func handleOrderEvent(sender: AnyObject) {
        let button = sender as! UIButton
        NSNotificationCenter.defaultCenter().postNotificationName("OrderListTableViewController", object: 2 , userInfo: ["tag" : button.tag + 10 * tag])
    }

    @IBAction func showFlightDetail(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("OrderListTableViewController", object: 1 , userInfo: ["tag" : tag])
    }
}
