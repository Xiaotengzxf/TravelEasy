//
//  XZCalendarController.h
//  日历
//
//  Created by xuzhen on 15/12/17.
//  Copyright © 2015年 FIF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XZCalendarModel.h"

@protocol XZCalendarControllerDelegate;

@interface XZCalendarController : UIViewController
@property(nonatomic,strong)NSString *start;
@property(nonatomic,strong)NSString *selectedDate;
@property(nonatomic,strong)NSString *startDate;
@property(nonatomic,strong)NSString *endDate;
@property (nonatomic , weak) id<XZCalendarControllerDelegate> delegate;
@end

@protocol XZCalendarControllerDelegate <NSObject>

- (void)xzCalendarControllerWithModel:(XZCalendarModel *)model;

@end
