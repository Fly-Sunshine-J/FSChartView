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

/**
 饼状图的分块数量

 @param chartView chartView
 @return 分块数量
 */
- (NSInteger)numberOfSectionForChartView:(FSPieChartView *)chartView;

/**
 分块对应的百分比

 @param chartView chartView
 @param section 对应的分块
 @return 百分比
 */
- (CGFloat)pieChartView:(FSPieChartView *)chartView percentageDataForSection:(NSInteger)section;


/**
 分块对应的颜色填充色
 
 @param chartView chartView
 @param section 对应的分块
 @return 分块的颜色填充色
 */
- (UIColor *)pieChartView:(FSPieChartView *)chartView colorForSection:(NSInteger)section;

@optional

/**
 分块对应需要显示的Label

 @param chartView chartView
 @param section 对应的分块
 @return UILabel
 */
- (UILabel *)pieChartView:(FSPieChartView *)chartView dataLabelForSection:(NSInteger)section;

@end

@protocol FSPieChartViewDelegate <NSObject>

@optional

/**
 内圆的填充色，默认和背景色一样

 @param chartView chartView
 @return 内圆的填充色
 */
- (UIColor *)innerCircleBackgroundColorForChartView:(FSPieChartView *)chartView;

/**
 内圆的半径，默认是宽高中最小的1/6

 @param chartView chartView
 @return 内圆的半径
 */
- (CGFloat)innerCircleRadiusForChartView:(FSPieChartView *)chartView;

/**
 饼状图的起始角度，默认是-M_PI_2

 @param chartView chartView
 @return 饼状图的起始角度
 */
- (CGFloat)startAngleForChartView:(FSPieChartView *)chartView;

/**
 饼状图的选中方法

 @param chartView chartView
 @param section 对应的分块
 */
- (void)pieChartView:(FSPieChartView *)chartView didSelectItemForSection:(NSInteger)section;

/**
  饼状图的反选某一个分块

 @param chartView chartView
 @param section 对应的分块
 */
- (void)pieChartView:(FSPieChartView *)chartView didDeselectItemForSection:(NSInteger)section;

/**
 饼状图的反选所有分块，点击内圆的范围进行反选所有

 @param chartView chartView
 */
-(void)didDeselectAllSectionForChartView:(FSPieChartView *)chartView;

@end

IB_DESIGNABLE
@interface FSPieChartView : UIView

@property (nonatomic, weak) IBOutlet id<FSPieChartViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet id<FSPieChartViewDataSource> dataSource;

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
