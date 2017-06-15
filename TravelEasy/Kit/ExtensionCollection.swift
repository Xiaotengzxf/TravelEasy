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
    public class func hexStringToColor(_ hexString: String) -> UIColor{
        var cString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if cString.characters.count < 6 {return UIColor.black}
        if cString.hasPrefix("0X") {cString = cString.substring(from: cString.characters.index(cString.startIndex, offsetBy: 2))}
        if cString.hasPrefix("#") {cString = cString.substring(from: cString.characters.index(cString.startIndex, offsetBy: 1))}
        if cString.characters.count != 6 {return UIColor.black}
        
        var range: NSRange = NSMakeRange(0, 2)
        
        let rString = (cString as NSString).substring(with: range)
        range.location = 2
        let gString = (cString as NSString).substring(with: range)
        range.location = 4
        let bString = (cString as NSString).substring(with: range)
        
        var r: UInt32 = 0x0
        var g: UInt32 = 0x0
        var b: UInt32 = 0x0
        Scanner.init(string: rString).scanHexInt32(&r)
        Scanner.init(string: gString).scanHexInt32(&g)
        Scanner.init(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(1))
    }
}

extension UIImage {
    public class func imageWithColor(_ hexString : String) -> UIImage{
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(UIColor.hexStringToColor(hexString).cgColor)
        context!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension UIViewController {
    func showHUD() -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "加载中..."
        hud.contentColor = UIColor.white
        hud.bezelView.color = UIColor.black
        return hud
    }
    
    func showHUDWindow() -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow ?? self.view, animated: true)
        hud.label.text = "加载中..."
        hud.contentColor = UIColor.white
        hud.bezelView.color = UIColor.black
        return hud
    }
}

extension String {
    func attributeMoneyText() -> NSAttributedString {
        let attributeText = NSMutableAttributedString(string: self)
        attributeText.addAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 13)], range: NSMakeRange(0, 1))
        return attributeText
    }
}
