//
//  FSVerticalBarViewController.m
//  FSChartViewExample
//
//  Created by vcyber on 2018/1/19.
//  Copyright © 2018年 vcyber. All rights reserved.
//

#import "FSVerticalBarViewController.h"
#import <FSChartView/FSChartView.h>

@interface FSVerticalBarViewController ()<FSBarChartViewDelegate, FSBarChartViewDataSource> {
    NSIndexPath *_selectedIndexPath;
}

@property (nonatomic, strong) FSBarChartView *chartView;
@property (nonatomic, strong) FSBarChartView *chartView1;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *dataArray1;


@end

@implementation FSVerticalBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    for (int i = 0; i < 10; i++) {
        int rand = arc4random() % 101;
        NSMutableArray *array = [NSMutableArray array];
        for (int j = 0; j < 3; j++) {
            int rand1 = arc4random() % 101;
            [array addObject:@(rand1)];
        }
        [self.dataArray1 addObject:array];
        [self.dataArray addObject:@(rand)];
    }
    
    FSBarChartView *chartView = [[FSBarChartView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
    self.chartView = chartView;
    [self.chartView registerClass:[FSBarChartViewCell class] forCellWithReuseIdentifier:@"CELL"];
    chartView.delegate = self;
    chartView.dataSource = self;
    [self.view addSubview:chartView];
    self.chartView.abscissaAxis.backgroundColor = [UIColor greenColor];
    
    
    FSBarChartView *chartView1 = [[FSBarChartView alloc] initWithFrame:CGRectMake(0, 320, self.view.frame.size.width, 200)];
    self.chartView1 = chartView1;
    [self.chartView1 registerClass:[FSBarChartViewCell class] forCellWithReuseIdentifier:@"CELL1"];
    chartView1.delegate = self;
    chartView1.dataSource = self;
    [self.view addSubview:chartView1];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self.chartView1 reloadData];
    [self.chartView1 reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0], [NSIndexPath indexPathForItem:0 inSection:4], [NSIndexPath indexPathForItem:0 inSection:2], [NSIndexPath indexPathForItem:0 inSection:1]]];
}

- (NSInteger)barChartView:(FSBarChartView *)chartView numberOfItemAbscissaAxisInSection:(NSInteger)section {
    if ([chartView isEqual:self.chartView]) {
        return 1;
    }
    return [self.dataArray1[section] count];
}

- (NSInteger)numberOfSectionsInAbscissaAxisForBarChartView:(FSBarChartView *)chartView {
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInOrdinateAxisForBarChartView:(FSBarChartView *)chartView{
    return 11;
}

- (__kindof FSBarChartViewCell *)barChartView:(FSBarChartView *)chartView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([chartView isEqual:self.chartView]) {
        FSBarChartViewCell *cell = [chartView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
        cell.topTextLabel.text = [self.dataArray[indexPath.section] stringValue];
        cell.progress = [self.dataArray[indexPath.section] intValue] / 100.0;
        return cell;
    }else {
        FSBarChartViewCell *cell = [chartView dequeueReusableCellWithReuseIdentifier:@"CELL1" forIndexPath:indexPath];
        if (indexPath.row % 3 == 0) {
            cell.progressColor = [UIColor redColor];
        }else if (indexPath.row % 3 == 1) {
            cell.progressColor = [UIColor greenColor];
        }else {
            cell.progressColor = [UIColor blueColor];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.portrait = YES;
        cell.topTextLabel.text = [self.dataArray1[indexPath.section][indexPath.row] stringValue];
        cell.progress = [self.dataArray1[indexPath.section][indexPath.row] intValue] / 100.0;
        return cell;
    }
}


- (CGFloat)barChartView:(FSBarChartView *)chartView lineWidthForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 20;
}

- (CGFloat)barChartView:(FSBarChartView *)chartView spaceForSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 20;
}


- (UILabel *)barChartView:(FSBarChartView *)chartView ordinateAxisLableForSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:10];
    label.text = @(section * 10).stringValue;
    return label;
}

- (UILabel *)barChartView:(FSBarChartView *)chartView abscissaAxisLableForSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:10];
    label.text = @(section + 1).stringValue;
    return label;
}

- (UIView *)barChartView:(FSBarChartView *)chartView abscissaAxisLineViewForSection:(NSInteger)section {
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor redColor];
    return view;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
}

@end
