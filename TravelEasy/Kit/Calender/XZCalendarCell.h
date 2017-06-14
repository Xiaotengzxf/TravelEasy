//
//  XZCalendarCell.h
//  日历
//
//  Created by xuzhen on 15/12/17.
//  Copyright © 2015年 FIF. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XZCalendarModel;

@interface XZCalendarCell : UICollectionViewCell
@property(nonatomic,strong)XZCalendarModel *model;
@property(nonatomic,strong)NSString *titleStr;
@end
