//
//  ConfirmOrderViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/9.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import PopupDialog

class ConfirmOrderViewController: UIViewController {
    
    @IBOutlet weak var passengerLabel: UILabel!
    @IBOutlet weak var travelLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    var popupDidalog : PopupDialog!
    var passengerName : String?
    var travelLine : String?
    var date : String?
    var money : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        passengerLabel.text = passengerName
        travelLabel.text = travelLine
        dateLabel.text = date
        moneyLabel.text = money
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeAlertView(sender: AnyObject) {
        popupDidalog.dismiss()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
