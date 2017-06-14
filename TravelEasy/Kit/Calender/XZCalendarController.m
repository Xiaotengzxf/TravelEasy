//
//  XZCalendarController.m
//  日历
//
//  Created by xuzhen on 15/12/17.
//  Copyright © 2015年 FIF. All rights reserved.
//

#import "XZCalendarController.h"
#import "XZCalendarCell.h"

#import "XZCalendarHeaderView.h"
#import "XZCalendarLogic.h"

@interface XZCalendarController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    int daynumber;//天数
    int optiondaynumber;//选择日期数量
    UICollectionView *_calendarView;
    NSMutableArray *_dataArr;
    NSMutableArray *_monthArr;
}
@property(nonatomic ,strong) XZCalendarLogic *Logic;
@end

@implementation XZCalendarController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArr=[NSMutableArray array];
    _monthArr=[NSMutableArray array];
    
    [self createCalendarView];
    [self createData];
}

-(void)createData
{
    if ([self.start isEqualToString:@"1"]) {
        _monthArr=[self getMonthArrayOfDayNumber:365 WithSelectDate:nil withStartDate:nil andEndDate:nil andYuQiDate:nil];
    } else if ([self.start isEqualToString:@"2"]) {
        _monthArr=[self getMonthArrayOfDayNumber:365 WithSelectDate:self.selectedDate withStartDate:nil andEndDate:nil andYuQiDate:nil];
    } else {
        _monthArr=[self getMonthArrayOfDayNumber:365 WithSelectDate:self.selectedDate withStartDate:nil andEndDate:nil andYuQiDate:nil];
    }
    [_calendarView reloadData];
}
-(void)createCalendarView
{
    //布局
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    //设置item的宽高
    layout.itemSize=CGSizeMake([UIScreen mainScreen].bounds.size.width/7, [UIScreen mainScreen].bounds.size.width/7);
    //设置滑动方向
    layout.scrollDirection=UICollectionViewScrollDirectionVertical;
    //设置行间距
    layout.minimumLineSpacing=0.0f;
    //每列的最小间距
    layout.minimumInteritemSpacing = 0.0f;
    //四周边距
    layout.sectionInset=UIEdgeInsetsMake(0, 0, 0, 0);
    _calendarView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
    _calendarView.backgroundColor=[UIColor whiteColor];
    _calendarView.delegate=self;
    _calendarView.dataSource=self;
    _calendarView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:_calendarView];
    [_calendarView registerNib:[UINib nibWithNibName:@"XZCalendarCell" bundle:nil] forCellWithReuseIdentifier:@"calendar"];
    [_calendarView registerNib:[UINib nibWithNibName:@"XZCalendarHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"calendaerHeader"];
}
#pragma mark -UICollectionView
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _monthArr.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_monthArr[section] count];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XZCalendarCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"calendar" forIndexPath:indexPath];
    XZCalendarModel *model=[_monthArr[indexPath.section] objectAtIndex:indexPath.row];
    if ([self.start isEqualToString:@"1"]) {
        cell.titleStr=@"开始";
    } else if ([self.start isEqualToString:@"2"]) {
        cell.titleStr=@"结束";
    } else {
        cell.titleStr=@"逾期";
    }
    cell.model=model;
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    XZCalendarModel *model=[_monthArr[indexPath.section] objectAtIndex:indexPath.row];
    if ([self.start isEqualToString:@"3"]) {
        if (model.style==CellDayTypeFutur||model.style==CellDayTypeYuQi) {
        } else {
            return;
        }
    } else {
        if (model.style==CellDayTypeFutur||model.style==CellDayTypeStart||model.style==CellDayTypeEnd||model.style==CellDayTypeStartAndEnd) {
        } else {
            return;
        }
    }
    if ([self.start isEqualToString:@"1"]) {
        for (NSMutableArray *array in _monthArr) {
            for (XZCalendarModel *model1 in array) {
                if (model1.style==CellDayTypeStart) {
                    model1.style=CellDayTypeFutur;
                } else if (model1.style==CellDayTypeStartAndEnd) {
                    model1.style=CellDayTypeEnd;
                }
            }
        }
        if (model.style==CellDayTypeEnd||model.style==CellDayTypeStartAndEnd) {
            model.style=CellDayTypeStartAndEnd;
        } else {
            model.style=CellDayTypeStart;
        }
    } else if ([self.start isEqualToString:@"2"]) {
        for (NSMutableArray *array in _monthArr) {
            for (XZCalendarModel *model1 in array) {
                if (model1.style==CellDayTypeEnd) {
                    model1.style=CellDayTypeFutur;
                } else if (model1.style==CellDayTypeStartAndEnd) {
                    model1.style=CellDayTypeStart;
                }
            }
        }
        if (model.style==CellDayTypeStart||model.style==CellDayTypeStartAndEnd) {
            model.style=CellDayTypeStartAndEnd;
        } else {
            model.style=CellDayTypeEnd;
        }
    } else {
        for (NSMutableArray *array in _monthArr) {
            for (XZCalendarModel *model1 in array) {
                if (model1.style==CellDayTypeYuQi) {
                    model1.style=CellDayTypeFutur;
                }
            }
        }
        model.style=CellDayTypeYuQi;
    }
    [_calendarView reloadData];
    [self performSelector:@selector(selectedDateWithModel:) withObject:model afterDelay:0.3];
}

- (void)selectedDateWithModel:(XZCalendarModel *)model
{
    [self.delegate xzCalendarControllerWithModel:model];
    [self.navigationController popViewControllerAnimated:YES];
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    XZCalendarHeaderView *calendarHeaderView=[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"calendaerHeader" forIndexPath:indexPath];
    XZCalendarModel *model=[_monthArr[indexPath.section] objectAtIndex:15];
    calendarHeaderView.titleStr=[NSString stringWithFormat:@"%ld年%ld月",model.year,model.month];
    return calendarHeaderView;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.view.frame.size.width, 45);
}

#pragma mark - 逻辑代码初始化
//获取时间段内的天数数组
- (NSMutableArray *)getMonthArrayOfDayNumber:(int)day WithSelectDate:(NSString *)selectStr withStartDate:(NSString *)startStr andEndDate:(NSString *)endStr andYuQiDate:(NSString *)yuqiStr
{
    NSDate *startDate = [NSDate date];
    if (startStr) {
        startDate=[startDate dateFromString:startStr];
    } else {
        startDate=nil;
    }
    NSDate *endDate = [NSDate date];
    if (endStr) {
        endDate=[endDate dateFromString:endStr];
    } else {
        endDate=nil;
    }
    NSDate *yuqiDate = [NSDate date];
    if (yuqiStr) {
        yuqiDate=[yuqiDate dateFromString:yuqiStr];
    } else {
        yuqiDate=nil;
    }
    NSDate *selectDate  = [NSDate date];
    if (selectStr) {
        selectDate = [selectDate dateFromString:selectStr];
    }
    _Logic = [[XZCalendarLogic alloc]init];
    if ([self.start isEqualToString:@"1"]) {
        _Logic.titleStr=@"开始";
    } else if ([self.start isEqualToString:@"2"]) {
        _Logic.titleStr=@"结束";
    } else {
        _Logic.titleStr=@"逾期";
    }
    return [_Logic reloadCalendarView:nil selectDate:selectDate needDays:day andStartDate:startDate andEndDate:endDate andYuQiDate:yuqiDate];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end