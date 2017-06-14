//
//  EmptyManager.swift
//  TravelEasy
//
//  Created by 张晓飞 on 2016/10/21.
//  Copyright © 2016年 张晓飞. All rights reserved.
//

import Foundation

class EmptyManager {
    
    static let getInstance = EmptyManager()
    
    func insertEmptyView(with view : UIView ,  top : CGFloat , emptyType : EmptyView.EmptyType , bottom : CGFloat = 0) -> EmptyView {
        let emptyView = NSBundle.mainBundle().loadNibNamed("EmptyView", owner: nil, options: nil)?.first as! EmptyView
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyView)
        emptyView.setPropertyValue(emptyType)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[emptyView]|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["emptyView" : emptyView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(padding)-[emptyView]-(bottom)-|", options: .DirectionLeadingToTrailing, metrics: ["padding" : top , "bottom" : bottom], views: ["emptyView" : emptyView]))
        return emptyView
    }
    
}
