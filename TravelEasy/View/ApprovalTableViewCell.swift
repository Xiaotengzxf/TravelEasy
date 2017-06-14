//
//  ApprovalTableViewCell.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/8.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit

class ApprovalTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var oneLabel: UILabel!
    @IBOutlet weak var oneContentLabel: UILabel!
    @IBOutlet weak var twoLabel: UILabel!
    @IBOutlet weak var twoContentLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
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
        okButton.setBackgroundImage(UIImage.imageWithColor(BUTTONBGCOLORHIGHLIGHT), forState: .Highlighted)
    }

    @IBAction func showApprovalDetail(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("ApprovalListViewController", object: 2, userInfo: ["tag" : tag])
    }
    
    @IBAction func cancelApproval(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("ApprovalListViewController", object: 1, userInfo: ["tag" : tag ,"eventTag" : 0])
    }
    @IBAction func allowApproval(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("ApprovalListViewController", object: 1, userInfo: ["tag" : tag ,"eventTag" : 1])
    }
}
