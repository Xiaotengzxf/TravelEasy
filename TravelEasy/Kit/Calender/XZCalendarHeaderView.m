//
//  XZCalendarHeaderView.m
//  日历
//
//  Created by xuzhen on 15/12/17.
//  Copyright © 2015年 FIF. All rights reserved.
//

#import "XZCalendarHeaderView.h"

@interface XZCalendarHeaderView ()
{
    __weak IBOutlet UILabel *titleLab;
}
@end

@implementation XZCalendarHeaderView
- (void)awakeFromNib {
}
-(void)setTitleStr:(NSString *)titleStr
{
    _titleStr=titleStr;
    titleLab.text=titleStr;
}
@end