//
//  FSLineViewController.m
//  FSChartViewExample
//
//  Created by vcyber on 2018/1/19.
//  Copyright © 2018年 vcyber. All rights reserved.
//

#import "FSLineViewController.h"
#import <FSChartView/FSLineChartView.h>

@interface FSLineViewController ()<FSLineChartViewDataSource, FSLineChartViewDelegate>

@property (nonatomic, strong) FSLineChartView *lineChartView;
@property (nonatomic, strong) FSLineChartView *lineChartView1;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *dataArray1;

@end

@implementation FSLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    for (int i = 0; i < 100; i++) {
        int rand = arc4random() % 101;
        [self.dataArray addObject:@(rand)];
    }
    
    for (int i = 0; i < 3; i++) {
        NSMutableArray *array = [NSMutableArray array];
        for (int j = 0; j < 100; j++) {
            int rand1 = arc4random() % 101;
            [array addObject:@(rand1)];
        }
        [self.dataArray1 addObject:array];
    }
//    如果初始化数据比较多，如果直接生成  可能会出现卡顿的现象
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        FSLineChartView *lineViewChart = [[FSLineChartView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
        self.lineChartView  = lineViewChart;
        lineViewChart.delegate = self;
        lineViewChart.dataSource = self;
        [self.view addSubview:lineViewChart];
        
        
        FSLineChartView *lineViewChart1 = [[FSLineChartView alloc] initWithFrame:CGRectMake(0, 0, 100 * 20 + 40, 200)];
        self.lineChartView1  = lineViewChart1;
        lineViewChart1.delegate = self;
        lineViewChart1.dataSource = self;
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 320, self.view.frame.size.width, 200)];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:scrollView];
        [scrollView addSubview:lineViewChart1];
        scrollView.contentSize = CGSizeMake(lineViewChart1.frame.size.width, 0);
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.lineChartView1 reloadDataAtLineIndex:2];
}

- (NSInteger)numberOfLineForChartView:(FSLineChartView *)chartView {
    if ([chartView isEqual:self.lineChartView]) {
        return 1;
    }
    return self.dataArray1.count;
}

- (NSInteger)lineChartView:(FSLineChartView *)chartView numberOfSectionsInAbscissaAxisAtLineIndex:(NSInteger)lineIndex {
    if ([chartView isEqual:self.lineChartView]) {
        return self.dataArray.count;
    }
    return [self.dataArray1[lineIndex] count];
}

- (CGFloat)lineChartView:(FSLineChartView *)chartView percentageDataAtIndexPath:(FSIndexPath *)indexPath {
    if ([chartView isEqual:self.lineChartView]) {
        return [self.dataArray[indexPath.section] floatValue] / 100;
    }
    return [self.dataArray1[indexPath.lineIndex][indexPath.section] floatValue] / 100.0;
}


- (UILabel *)lineChartView:(FSLineChartView *)chartView dataLableAtIndexPath:(FSIndexPath *)indexPath {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:8];
    label.textColor = [UIColor whiteColor];
    if ([self.lineChartView isEqual:chartView]) {
        label.text = [self.dataArray[indexPath.section] stringValue];
    }else {
        return nil;
        label.text = [self.dataArray1[indexPath.lineIndex][indexPath.section] stringValue];
    }
    return label;
}

- (NSInteger)numberOfSectionsInOrdinateAxisForLineChartView:(FSLineChartView *)chartView {
    return 11;
}


- (UILabel *)lineChartView:(FSLineChartView *)chartView ordinateAxisLableForSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:10];
    label.text = @(section * 10).stringValue;
    return label;
}

- (UIColor *)lineChartView:(FSLineChartView *)chartView lineColorAtLineIndex:(NSInteger)lineIndex {
    if ([chartView isEqual:self.lineChartView]) {
        return [UIColor colorWithRed:77.0 / 255.0 green:196.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f];
    }
    if (lineIndex == 0) {
        return [UIColor greenColor];
    }else if (lineIndex == 1) {
        return [UIColor blueColor];
    }
    return [UIColor cyanColor];
}

- (UILabel *)lineChartView:(FSLineChartView *)chartView abscissaAxisLableForSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:10];
    label.text = @(section + 1).stringValue;
    return label;
}

- (UIView *)lineChartView:(FSLineChartView *)chartView abscissaAxisLineViewForSection:(NSInteger)section {
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    return view;
}

- (CGFloat)lineChartView:(FSLineChartView *)chartView spaceForSection:(NSInteger)section {
    if ([chartView isEqual:self.lineChartView]) {
        return 15;
    }
    return 20;
}

- (FSLineJoinStyle)lineChartView:(FSLineChartView *)chartView lineJoinStyleAtIndexPath:(FSIndexPath *)indexPath {
    if ([chartView isEqual:self.lineChartView]) {
        return FSLineJoinStyleRound;
    }
    if (indexPath.lineIndex == 0) {
         return FSLineJoinStyleTriangle;
    }else if (indexPath.lineIndex == 1) {
        return FSLineJoinStyleRound;
    }
    return FSLineJoinStyleSquare;
}

- (UIColor *)lineChartView:(FSLineChartView *)chartView lineJoinColorAtIndexPath:(FSIndexPath *)indexPath {
    if ([chartView isEqual:self.lineChartView]) {
        return [UIColor cyanColor];
    }
    if (indexPath.lineIndex == 0) {
        return [UIColor greenColor];
    }else if (indexPath.lineIndex == 1) {
        return [UIColor blueColor];
    }
    return [UIColor cyanColor];
}


- (void)lineChartView:(FSLineChartView *)chartView didSelectItemAtIndexPath:(FSIndexPath *)indexPath touchPoint:(CGPoint)point {
    NSLog(@"%@-%@", indexPath, NSStringFromCGPoint(point));
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)dataArray1 {
    if (!_dataArray1) {
        _dataArray1 = [NSMutableArray array];
    }
    return _dataArray1;
}

- (void)dealloc {
    
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
