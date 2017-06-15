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
        okButton.setBackgroundImage(UIImage.imageWithColor(BUTTONBGCOLORHIGHLIGHT), for: .highlighted)
    }

    @IBAction func showApprovalDetail(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ApprovalListViewController"), object: 2, userInfo: ["tag" : tag])
    }
    
    @IBAction func cancelApproval(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ApprovalListViewController"), object: 1, userInfo: ["tag" : tag ,"eventTag" : 0])
    }
    @IBAction func allowApproval(_ sender: AnyObject) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ApprovalListViewController"), object: 1, userInfo: ["tag" : tag ,"eventTag" : 1])
    }
}
