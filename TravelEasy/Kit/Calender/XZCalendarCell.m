//
//  XZCalendarCell.m
//  日历
//
//  Created by xuzhen on 15/12/17.
//  Copyright © 2015年 FIF. All rights reserved.
//

#import "XZCalendarCell.h"
#import "XZCalendarModel.h"

@interface XZCalendarCell ()
@property (weak, nonatomic) IBOutlet UILabel *numberLab;
@property (weak, nonatomic) IBOutlet UIImageView *backImgView;

@end

@implementation XZCalendarCell
- (void)awakeFromNib {
}
-(void)setModel:(XZCalendarModel *)model
{
    _model=model;
    _backImgView.image=[UIImage imageNamed:@""];
    _numberLab.text=[NSString stringWithFormat:@"%ld",model.day];
    switch (model.style) {
        case CellDayTypeEmpty:
            _numberLab.hidden=YES;
            _numberLab.textColor=[UIColor grayColor];
            break;
        case CellDayTypeFutur:
            _numberLab.hidden=NO;
            _numberLab.textColor=[UIColor blackColor];
            break;
        case CellDayTypePast:
            _numberLab.hidden=NO;
            _numberLab.textColor=[UIColor grayColor];
            break;
        case CellDayTypeStart:
            _numberLab.hidden=NO;
            _numberLab.textColor=[UIColor whiteColor];
            _backImgView.image=[UIImage imageNamed:@"icon_date_selected"];
            if ([self.titleStr isEqualToString:@"逾期"]) {
                _backImgView.image=[UIImage imageNamed:@"ybxzdy"];
                _numberLab.textColor=[UIColor grayColor];
            }
            break;
        case CellDayTypeEnd:
            _numberLab.hidden=NO;
            _numberLab.textColor=[UIColor blackColor];
            _backImgView.image=[UIImage imageNamed:@"icon_date_selected"];
            if ([self.titleStr isEqualToString:@"逾期"]) {
                _backImgView.image=[UIImage imageNamed:@"ybxzdy"];
                _numberLab.textColor=[UIColor grayColor];
            }
            break;
        case CellDayTypeYuQi:
            _numberLab.hidden=NO;
            _numberLab.textColor=[UIColor blackColor];
            _backImgView.image=[UIImage imageNamed:@"icon_date_selected"];
            break;
        case CellDayTypeStartAndEnd:
            _numberLab.hidden=NO;
            _numberLab.textColor=[UIColor blackColor];
            _backImgView.image=[UIImage imageNamed:@"icon_date_selected"];
            if ([self.titleStr isEqualToString:@"逾期"]) {
                _backImgView.image=[UIImage imageNamed:@"ybxzdy"];
                _numberLab.textColor=[UIColor grayColor];
            }
            break;
        default:
            break;
    }
}
@end