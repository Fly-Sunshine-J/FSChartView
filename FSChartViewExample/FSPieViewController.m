//
//  FSPieViewController.m
//  FSChartViewExample
//
//  Created by vcyber on 2018/1/19.
//  Copyright © 2018年 vcyber. All rights reserved.
//

#import "FSPieViewController.h"
#import <FSChartView/FSChartView.h>

@interface FSPieViewController ()<FSPieChartViewDelegate, FSPieChartViewDataSource>

@property (nonatomic, strong) FSPieChartView *chartView;
@property (nonatomic, strong) FSPieChartView *chartView1;
@property (nonatomic, strong) FSPieChartView *chartView2;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *titleArray;

@end

@implementation FSPieViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.titleArray addObjectsFromArray:@[@"阿里", @"腾讯", @"百度"]];
    for (int i = 0; i < 3; i++) {
        int rand = arc4random() % 101;
        [self.dataArray addObject:@(rand)];
    }
    
    CGFloat height = (self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20 * 4 - [UIApplication sharedApplication].statusBarFrame.size.height) / 3;
    
    FSPieChartView *pieChartView = [[FSPieChartView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height + 20, self.view.frame.size.width, height)];
    pieChartView.delegate = self;
    pieChartView.dataSource = self;
    [self.view addSubview:pieChartView];
    self.chartView = pieChartView;
    
    FSPieChartView *pieChartView1 = [[FSPieChartView alloc] initWithFrame:CGRectMake(0, pieChartView.frame.size.height + pieChartView.frame.origin.y + 20, self.view.frame.size.width, height)];
    pieChartView1.delegate = self;
    pieChartView1.dataSource = self;
    pieChartView1.allowMultiSelected = YES;
    [self.view addSubview:pieChartView1];
    self.chartView1 = pieChartView1;
    
    FSPieChartView *pieChartView2 = [[FSPieChartView alloc] initWithFrame:CGRectMake(0, pieChartView1.frame.size.height + pieChartView1.frame.origin.y + 20, self.view.frame.size.width, height)];
    pieChartView2.delegate = self;
    pieChartView2.dataSource = self;
    pieChartView2.duration = 2.0;
    [self.view addSubview:pieChartView2];
    self.chartView2 = pieChartView2;
}

- (NSInteger)numberOfSectionForChartView:(FSPieChartView *)chartView {
    return self.dataArray.count;
}

- (CGFloat)pieChartView:(FSPieChartView *)chartView percentageDataForSection:(NSInteger)section {
    return [self.dataArray[section] floatValue] / [[self.dataArray valueForKeyPath:@"@sum.floatValue"] floatValue];
}

- (UIColor *)pieChartView:(FSPieChartView *)chartView colorForSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [UIColor colorWithRed:77.0 / 255.0 green:216.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f];
        case 1:
            return [UIColor colorWithRed:77.0 / 255.0 green:196.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f];
        case 2:
            return [UIColor colorWithRed:77.0 / 255.0 green:176.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f];
        default:
            return [UIColor redColor];
    }
}

- (UIColor *)innerCircleBackgroundColorForChartView:(FSPieChartView *)chartView {
    if ([chartView isEqual:self.chartView]) {
        return [UIColor redColor];
    }else if ([chartView isEqual:self.chartView1]) {
        return nil;
    }
    return [UIColor clearColor];
}

- (UILabel *)pieChartView:(FSPieChartView *)chartView dataLabelForSection:(NSInteger)section {
    UILabel *label = [UILabel new];
    label.font =[UIFont systemFontOfSize:10];
    label.textColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"%.2f%%\n%@", [self.dataArray[section] floatValue] / [[self.dataArray valueForKeyPath:@"@sum.floatValue"] floatValue] * 100, self.titleArray[section]];
    return label;
}

- (CGFloat)startAngleForChartView:(FSPieChartView *)chartView {
    if ([chartView isEqual:self.chartView]) {
        return -M_PI_2;
    }else if ([chartView isEqual:self.chartView1]) {
        return 0;
    }
    return M_PI * 2 / 3;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)titleArray {
    if (!_titleArray) {
        _titleArray = [NSMutableArray array];
    }
    return _titleArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
