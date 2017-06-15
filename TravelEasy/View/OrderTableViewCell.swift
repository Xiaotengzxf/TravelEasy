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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cancelButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).cgColor
        cancelButton.setTitleColor(UIColor.white, for: .highlighted)
        cancelButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), for: .disabled)
        cancelButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), for: .highlighted)
        payButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).cgColor
        payButton.setTitleColor(UIColor.white, for: .highlighted)
        payButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), for: .disabled)
        payButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), for: .highlighted)
        refundButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).cgColor
        refundButton.setTitleColor(UIColor.white, for: .highlighted)
        refundButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), for: .disabled)
        refundButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), for: .highlighted)
        changeButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).cgColor
        changeButton.setTitleColor(UIColor.white, for: .highlighted)
        changeButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), for: .disabled)
        changeButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), for: .highlighted)
        netCheckInButton.layer.borderColor = UIColor.hexStringToColor(BUTTONBGCOLORNORMAL).cgColor
        netCheckInButton.setTitleColor(UIColor.white, for: .highlighted)
        netCheckInButton.setTitleColor(UIColor.hexStringToColor(LINECOLOR), for: .disabled)
        netCheckInButton.setBackgroundImage(UIImage.imageWithColor(BUTTON2BGCOLORHIGHLIGHT), for: .highlighted)
    }
    
    @IBAction func handleOrderEvent(_ sender: AnyObject) {
        let button = sender as! UIButton
        NotificationCenter.default.post(name: Notification.Name(rawValue: "OrderListTableViewController"), object: 2 , userInfo: ["tag" : button.tag + 10 * tag])
    }

    @IBAction func showFlightDetail(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "OrderListTableViewController"), object: 1 , userInfo: ["tag" : tag])
    }
}
