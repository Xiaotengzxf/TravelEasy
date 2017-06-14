//
//  ExtensionCollection.swift
//  TravelEasy
//
//  Created by 张晓飞 on 16/8/8.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import UIKit
import MBProgressHUD

extension UIColor {
    public class func hexStringToColor(hexString: String) -> UIColor{
        var cString: String = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if cString.characters.count < 6 {return UIColor.blackColor()}
        if cString.hasPrefix("0X") {cString = cString.substringFromIndex(cString.startIndex.advancedBy(2))}
        if cString.hasPrefix("#") {cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))}
        if cString.characters.count != 6 {return UIColor.blackColor()}
        
        var range: NSRange = NSMakeRange(0, 2)
        
        let rString = (cString as NSString).substringWithRange(range)
        range.location = 2
        let gString = (cString as NSString).substringWithRange(range)
        range.location = 4
        let bString = (cString as NSString).substringWithRange(range)
        
        var r: UInt32 = 0x0
        var g: UInt32 = 0x0
        var b: UInt32 = 0x0
        NSScanner.init(string: rString).scanHexInt(&r)
        NSScanner.init(string: gString).scanHexInt(&g)
        NSScanner.init(string: bString).scanHexInt(&b)
        
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(1))
    }
}

extension UIImage {
    public class func imageWithColor(hexString : String) -> UIImage{
        UIGraphicsBeginImageContext(CGSizeMake(1, 1))
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context!, UIColor.hexStringToColor(hexString).CGColor)
        CGContextFillRect(context!, CGRectMake(0, 0, 1, 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension UIViewController {
    func showHUD() -> MBProgressHUD {
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.label.text = "加载中..."
        hud.contentColor = UIColor.whiteColor()
        hud.bezelView.color = UIColor.blackColor()
        return hud
    }
    
    func showHUDWindow() -> MBProgressHUD {
        let hud = MBProgressHUD.showHUDAddedTo(UIApplication.sharedApplication().keyWindow ?? self.view, animated: true)
        hud.label.text = "加载中..."
        hud.contentColor = UIColor.whiteColor()
        hud.bezelView.color = UIColor.blackColor()
        return hud
    }
}

extension String {
    func attributeMoneyText() -> NSAttributedString {
        let attributeText = NSMutableAttributedString(string: self)
        attributeText.addAttributes([NSFontAttributeName : UIFont.systemFontOfSize(13)], range: NSMakeRange(0, 1))
        return attributeText
    }
}
