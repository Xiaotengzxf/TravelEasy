//
//  XZCalendarLogic.m
//  日历
//
//  Created by xuzhen on 15/12/17.
//  Copyright © 2015年 FIF. All rights reserved.
//

#import "XZCalendarLogic.h"

@interface XZCalendarLogic ()
{
    NSDate *today;//今天的日期
    NSDate *before;//之后的日期
    NSDate *_startDate;
    NSDate *_endDate;
    NSDate *_yuqiDate;
    XZCalendarModel *selectcalendarDay;
}
@end

@implementation XZCalendarLogic
//计算当前日期之前几天或者是之后的几天（负数是之前几天，正数是之后的几天）
- (NSMutableArray *)reloadCalendarView:(NSDate *)date  selectDate:(NSDate *)selectDate needDays:(int)days_number andStartDate:(NSDate *)startDate andEndDate:(NSDate *)endDate andYuQiDate:(NSDate *)yuqiDate
{
    //如果为空就从当天的日期开始
    if(date == nil){
        date = [NSDate date];
    }
    _startDate=startDate;
    _endDate=endDate;
    _yuqiDate=yuqiDate;
    today = date;//起始日期
    before = [date dayInTheFollowingDay:days_number];//计算它days天以后的时间
    NSDateComponents *todayDC= [today YMDComponents];
    NSDateComponents *beforeDC= [before YMDComponents];
    NSInteger todayYear = todayDC.year;
    NSInteger todayMonth = todayDC.month;
    NSInteger beforeYear = beforeDC.year;
    NSInteger beforeMonth = beforeDC.month;
    NSInteger months = (beforeYear-todayYear) * 12 + (beforeMonth - todayMonth);//选中与补选中相差的月份
    NSMutableArray *calendarMonth = [[NSMutableArray alloc]init];//每个月的dayModel数组
    for (int i = 0; i <= months; i++) {
        NSDate *month = [today dayInTheFollowingMonth:i];
        NSMutableArray *calendarDays = [[NSMutableArray alloc]init];
        [self calculateDaysInPreviousMonthWithDate:month andArray:calendarDays];//计算上月份的天数
        [self calculateDaysInCurrentMonthWithDate:month andArray:calendarDays];//计算当月的天数
        [self calculateDaysInFollowingMonthWithDate:month andArray:calendarDays];//计算下月份的天数
        [calendarMonth insertObject:calendarDays atIndex:i];
    }
    return calendarMonth;
}
#pragma mark - 日历上+当前+下月份的天数
//计算上月份的天数
- (NSMutableArray *)calculateDaysInPreviousMonthWithDate:(NSDate *)date andArray:(NSMutableArray *)array
{
    NSUInteger weeklyOrdinality = [[date firstDayOfCurrentMonth] weeklyOrdinality];//计算这个的第一天是礼拜几,并转为int型
    NSDate *dayInThePreviousMonth = [date dayInThePreviousMonth];//上一个月的NSDate对象
    NSUInteger daysCount = [dayInThePreviousMonth numberOfDaysInCurrentMonth];//计算上个月有多少天
    NSUInteger partialDaysCount = weeklyOrdinality - 1;//获取上月在这个月的日历上显示的天数
    NSDateComponents *components = [dayInThePreviousMonth YMDComponents];//获取年月日对象
    for (int i = (int)daysCount - (int)partialDaysCount + 1; i < daysCount + 1; ++i) {
        XZCalendarModel *calendarDay = [XZCalendarModel calendarDayWithYear:components.year month:components.month day:i];
        calendarDay.style = CellDayTypeEmpty;//显示灰色
        [array addObject:calendarDay];
    }
    return NULL;
}
//计算下月份的天数
- (void)calculateDaysInFollowingMonthWithDate:(NSDate *)date andArray:(NSMutableArray *)array
{
    NSUInteger weeklyOrdinality = [[date lastDayOfCurrentMonth] weeklyOrdinality];
    if (weeklyOrdinality == 7) return ;
    NSUInteger partialDaysCount = 7 - weeklyOrdinality;
    NSDateComponents *components = [[date dayInTheFollowingMonth] YMDComponents];
    for (int i = 1; i < partialDaysCount + 1; ++i) {
        XZCalendarModel *calendarDay = [XZCalendarModel calendarDayWithYear:components.year month:components.month day:i];
        calendarDay.style = CellDayTypeEmpty;//显示灰色
        [array addObject:calendarDay];
    }
}
//计算当月的天数
- (void)calculateDaysInCurrentMonthWithDate:(NSDate *)date andArray:(NSMutableArray *)array
{
    NSUInteger daysCount = [date numberOfDaysInCurrentMonth];//计算这个月有多少天
    NSDateComponents *components = [date YMDComponents];//今天日期的年月日
    for (int i = 1; i < daysCount + 1; ++i) {
        XZCalendarModel *calendarDay = [XZCalendarModel calendarDayWithYear:components.year month:components.month day:i];
        calendarDay.style = CellDayTypeFutur;//显示灰色
        [self changStyle:calendarDay];
        [array addObject:calendarDay];
    }
}
- (void)changStyle:(XZCalendarModel *)calendarDay
{
    NSDate *nowDate=[NSDate date];
    NSDateComponents *calendarNow = [nowDate YMDComponents];//今天
    NSDateComponents *calendarStart = [_startDate YMDComponents];//
    NSDateComponents *calendarEnd = [_endDate YMDComponents];//
    NSDateComponents *calendarYuQi = [_yuqiDate YMDComponents];//
    if ([self.titleStr isEqualToString:@"开始"]) {
        if (!_endDate) {
            if (calendarDay.year<calendarNow.year||(calendarDay.year==calendarNow.year&&(calendarDay.month<calendarNow.month||(calendarDay.month==calendarNow.month&&calendarDay.day<calendarNow.day)))) {
                calendarDay.style=CellDayTypePast;
            } else {
                calendarDay.style=CellDayTypeFutur;
            }
        } else {
            if ((calendarDay.year<calendarEnd.year||(calendarDay.year==calendarEnd.year&&(calendarDay.month<calendarEnd.month||(calendarDay.month==calendarEnd.month&&calendarDay.day<calendarEnd.day))))&&(calendarDay.year>calendarNow.year||(calendarDay.year==calendarNow.year&&(calendarDay.month>calendarNow.month||(calendarDay.month==calendarNow.month&&calendarDay.day>calendarNow.day))))) {
                calendarDay.style=CellDayTypeFutur;
            } else {
                calendarDay.style=CellDayTypePast;
            }
        }
    } else if ([self.titleStr isEqualToString:@"结束"]) {
        if (!_startDate) {
            if (calendarDay.year<calendarNow.year||(calendarDay.year==calendarNow.year&&(calendarDay.month<calendarNow.month||(calendarDay.month==calendarNow.month&&calendarDay.day<calendarNow.day)))) {
                calendarDay.style=CellDayTypePast;
            } else {
                calendarDay.style=CellDayTypeFutur;
            }
        } else {
            if (calendarDay.year<calendarStart.year||(calendarDay.year==calendarStart.year&&(calendarDay.month<calendarStart.month||(calendarDay.month==calendarStart.month&&calendarDay.day<calendarStart.day)))) {
                calendarDay.style=CellDayTypePast;
            } else {
                calendarDay.style=CellDayTypeFutur;
            }
        }
    } else if ([self.titleStr isEqualToString:@"逾期"]) {
        if (calendarDay.year<calendarEnd.year||(calendarDay.year==calendarEnd.year&&(calendarDay.month<calendarEnd.month||(calendarDay.month==calendarEnd.month&&calendarDay.day<=calendarEnd.day)))) {
            calendarDay.style=CellDayTypePast;
        } else {
            calendarDay.style=CellDayTypeFutur;
        }
    }
    if (calendarStart.year==calendarEnd.year&&calendarStart.month==calendarEnd.month&&calendarStart.day==calendarEnd.day) {
        if (calendarDay.year==calendarStart.year&&calendarDay.month==calendarStart.month&&calendarDay.day==calendarStart.day) {
            calendarDay.style=CellDayTypeStartAndEnd;
        }
    } else {
        if (calendarDay.year==calendarStart.year&&calendarDay.month==calendarStart.month&&calendarDay.day==calendarStart.day) {
            calendarDay.style=CellDayTypeStart;
        }
        if (calendarDay.year==calendarEnd.year&&calendarDay.month==calendarEnd.month&&calendarDay.day==calendarEnd.day) {
            calendarDay.style=CellDayTypeEnd;
        }
    }
    if (calendarDay.year==calendarYuQi.year&&calendarDay.month==calendarYuQi.month&&calendarDay.day==calendarYuQi.day) {
        calendarDay.style=CellDayTypeYuQi;
    }
}
@end