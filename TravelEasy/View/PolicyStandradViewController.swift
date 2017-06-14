//
//  PolicyStandradViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/7.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import PopupDialog

class PolicyStandradViewController: UIViewController {

    @IBOutlet weak var contentLabel: UILabel!
    weak var popupDidalog : PopupDialog?
    var content : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributeString = NSMutableAttributedString(string: content!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attributeString.addAttributes([NSParagraphStyleAttributeName : paragraphStyle], range: NSMakeRange(0, attributeString.length))
        contentLabel.attributedText = attributeString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeView(sender: AnyObject) {
        popupDidalog?.dismiss()
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
