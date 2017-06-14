//
//  MobileCallViewController.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/9/12.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit

class MobileCallViewController: UIViewController {

    @IBOutlet weak var mobileLabel: UILabel!
    var mobile : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mobileLabel.text = mobile
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
