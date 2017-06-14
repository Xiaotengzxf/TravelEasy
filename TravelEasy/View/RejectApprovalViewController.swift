//
//  RejectApprovalViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/13.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import PopupDialog

class RejectApprovalViewController: UIViewController {

    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var reasonTextView: IQTextView!
    var popupDialog : PopupDialog!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeDialog(sender: AnyObject) {
        popupDialog.dismiss()
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
