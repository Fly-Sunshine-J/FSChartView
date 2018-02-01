//
//  FSPieChartView.h
//  FSChartView
//
//  Created by vcyber on 2018/1/30.
//  Copyright © 2018年 vcyber. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPieChartView;

@protocol FSPieChartViewDataSource <NSObject>
@required
- (NSInteger)numberOfSectionForChartView:(FSPieChartView *)chartView;
- (CGFloat)pieChartView:(FSPieChartView *)chartView percentageDataForSection:(NSInteger)section;

@optional
- (UILabel *)pieChartView:(FSPieChartView *)chartView dataLabelForSection:(NSInteger)section;

@end

@protocol FSPieChartViewDelegate <NSObject>
@required
- (UIColor *)pieChartView:(FSPieChartView *)chartView colorForSection:(NSInteger)section;

@optional
- (UIColor *)innerCircleBackgroundColorForChartView:(FSPieChartView *)chartView;
- (CGFloat)innerCircleRadiusForChartView:(FSPieChartView *)chartView;
- (CGFloat)startAngleForChartView:(FSPieChartView *)chartView;
- (void)pieChartView:(FSPieChartView *)chartView didSelectItemForSection:(NSInteger)section;
- (void)pieChartView:(FSPieChartView *)chartView didDeselectItemForSection:(NSInteger)section;
-(void)didDeselectAllSectionForChartView:(FSPieChartView *)chartView;

@end

@interface FSPieChartView : UIView

@property (nonatomic, weak) id<FSPieChartViewDelegate> delegate;
@property (nonatomic, weak) id<FSPieChartViewDataSource> dataSource;

- (void)reloadData;

/**
 是否需要动画，默认YES
 */
@property (nonatomic, assign) BOOL showAnimated;


/**
 动画时长，默认1s
 */
@property (nonatomic, assign) NSTimeInterval duration;


/**
 默认是NO
 */
@property (nonatomic, assign) BOOL allowMultiSelected;

@end
