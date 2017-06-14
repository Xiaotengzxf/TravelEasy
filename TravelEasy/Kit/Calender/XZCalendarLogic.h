//
//  XZCalendarLogic.h
//  日历
//
//  Created by xuzhen on 15/12/17.
//  Copyright © 2015年 FIF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XZCalendarModel.h"
#import "NSDate+WQCalendarLogic.h"

@interface XZCalendarLogic : NSObject
- (NSMutableArray *)reloadCalendarView:(NSDate *)date  selectDate:(NSDate *)selectDate needDays:(int)days_number andStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate andYuQiDate:(NSDate *)yuqiDate;
@property(nonatomic,strong)NSString *titleStr;
@end
