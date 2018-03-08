//
//  FSStoryBoardController.m
//  FSChartViewExample
//
//  Created by vcyber on 2018/1/31.
//  Copyright © 2018年 vcyber. All rights reserved.
//

#import "FSStoryBoardController.h"
#import <FSChartView/FSChartView.h>

@interface FSStoryBoardController ()<FSBarChartViewDelegate, FSBarChartViewDataSource,
                                     FSLineChartViewDelegate, FSLineChartViewDataSource,
                                     FSPieChartViewDelegate, FSPieChartViewDataSource>

@property (weak, nonatomic) IBOutlet FSBarChartView *barChartView;
//@property (strong, nonatomic) FSBarChartView *barChartView;
@property (weak, nonatomic) IBOutlet FSLineChartView *lineChartView;
@property (weak, nonatomic) IBOutlet FSPieChartView *pieChartView;

@property (nonatomic, strong) NSMutableArray *barChartArray;
@property (nonatomic, strong) NSMutableArray *lineChartArray;
@property (nonatomic, strong) NSMutableArray *pieChartArray;
@property (nonatomic, strong) NSMutableArray *titleArray;

@end

@implementation FSStoryBoardController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _barChartArray= [NSMutableArray array];
    _lineChartArray = [NSMutableArray array];
    _pieChartArray = [NSMutableArray array];
    _titleArray = [NSMutableArray array];
    
    for (int i = 0; i < 100; i++) {
        int rand = arc4random() % 101;
        [self.barChartArray addObject:@(rand)];
        [self.lineChartArray addObject:@(rand)];
    }
    
    [self.titleArray addObjectsFromArray:@[@"阿里", @"腾讯", @"百度"]];
    for (int i = 0; i < 3; i++) {
        int rand = arc4random() % 101;
        [self.pieChartArray addObject:@(rand)];
    }
    [self.barChartView registerClass:[FSBarChartViewCell class] forCellWithReuseIdentifier:@"CELL"];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.barChartView reloadData];
    [self.lineChartView reloadData];
    [self.pieChartView reloadData];
}

// MARK: Bar Chart View

- (NSInteger)numberOfSectionsInAbscissaAxisForBarChartView:(FSBarChartView *)chartView {
    
    return 11;
}

- (NSInteger)numberOfSectionsInOrdinateAxisForBarChartView:(FSBarChartView *)chartView{
    return self.barChartArray.count;
}

- (__kindof FSBarChartViewCell *)barChartView:(FSBarChartView *)chartView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FSBarChartViewCell *cell = [chartView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    cell.portrait = NO;
    cell.topTextLabel.text = [self.barChartArray[indexPath.section] stringValue];
    cell.progress = [self.barChartArray[indexPath.section] intValue] / 100.0;
    return cell;
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
    label.text = @(section + 1).stringValue;
    return label;
}

- (UILabel *)barChartView:(FSBarChartView *)chartView abscissaAxisLableForSection:(NSInteger)section {
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:10];
    label.text = @(section * 10).stringValue;
    return label;
}

- (UIView *)barChartView:(FSBarChartView *)chartView ordinateAxisLineViewForSection:(NSInteger)section {
    //    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    return view;
}

// MARK: Line Chart View

- (NSInteger)lineChartView:(FSLineChartView *)chartView numberOfSectionsInAbscissaAxisAtLineIndex:(NSInteger)lineIndex {
    return self.lineChartArray.count;
}

- (CGFloat)lineChartView:(FSLineChartView *)chartView percentageDataAtIndexPath:(FSIndexPath *)indexPath {
    return [self.lineChartArray[indexPath.section] floatValue] / 100;
}


- (UILabel *)lineChartView:(FSLineChartView *)chartView dataLableAtIndexPath:(FSIndexPath *)indexPath {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:8];
    label.textColor = [UIColor whiteColor];
    label.text = [self.lineChartArray[indexPath.section] stringValue];
    return label;
}

- (NSInteger)numberOfSectionsInOrdinateAxisForLineChartView:(FSLineChartView *)chartView {
    return 6;
}


- (UILabel *)lineChartView:(FSLineChartView *)chartView ordinateAxisLableForSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:10];
    label.text = @(section * 20).stringValue;
    return label;
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

- (FSLineJoinStyle)lineChartView:(FSLineChartView *)chartView lineJoinStyleAtIndexPath:(FSIndexPath *)indexPath {
    return FSLineJoinStyleRound;;
}

- (UIColor *)lineChartView:(FSLineChartView *)chartView lineJoinColorAtIndexPath:(FSIndexPath *)indexPath {
    return [UIColor cyanColor];
}


- (void)lineChartView:(FSLineChartView *)chartView didSelectItemAtIndexPath:(FSIndexPath *)indexPath touchPoint:(CGPoint)point {
    NSLog(@"%@-%@", indexPath, NSStringFromCGPoint(point));
}

// MARK: Pie Chart View
- (NSInteger)numberOfSectionForChartView:(FSPieChartView *)chartView {
    return self.pieChartArray.count;
}

- (CGFloat)pieChartView:(FSPieChartView *)chartView percentageDataForSection:(NSInteger)section {
    return [self.pieChartArray[section] floatValue] / [[self.pieChartArray valueForKeyPath:@"@sum.floatValue"] floatValue];
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



- (UILabel *)pieChartView:(FSPieChartView *)chartView dataLabelForSection:(NSInteger)section {
    UILabel *label = [UILabel new];
    label.font =[UIFont systemFontOfSize:10];
    label.textColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"%.2f%%\n%@", [self.pieChartArray[section] floatValue] / [[self.pieChartArray valueForKeyPath:@"@sum.floatValue"] floatValue] * 100, self.titleArray[section]];
    return label;
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
