//
//  FSLineChartView.h
//  FSChartView
//
//  Created by vcyber on 2018/1/25.
//  Copyright © 2018年 vcyber. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FSLineJoinStyle) {
    FSLineJoinStyleRound = 0,  //连接点是圆形
    FSLineJoinStyleTriangle,    //连接点是三角形
    FSLineJoinStyleSquare,   //连接点是正方形
};

/**
 用来标记一个折线图中一个数据点的位置，在那一条线上和那个组的位置
 */
@interface FSIndexPath:NSObject
+ (instancetype)indexPathWithLineIndex:(NSInteger)lineIndex section:(NSInteger)section;
@property (nonatomic, assign, readonly) NSInteger lineIndex;
@property (nonatomic, assign, readonly) NSInteger section;
@end

@class FSLineChartView;

@protocol FSLineChartViewDataSource<NSObject>
@required

/**
 每一条折线图的横轴分组数量，如果每条折线返回的数量不相等，取最大的那一条折线图分组数参与计算

 @param chartView chartView
 @param lineIndex 折线下标
 @return 折线对应的分组数量
 */
- (NSInteger)lineChartView:(FSLineChartView *)chartView numberOfSectionsInAbscissaAxisAtLineIndex:(NSInteger)lineIndex;

/**
 数据点所在百分比，返回的是一个大于等于0，小于等于1的百分比，如果小于0会按0处理，如果大于1会按照1处理

 @param chartView chartView
 @param indexPath 数据点的位置
 @return 数据点的百分比
 */
- (CGFloat)lineChartView:(FSLineChartView *)chartView percentageDataAtIndexPath:(FSIndexPath *)indexPath;


@optional

/**
 返回折线的数量，也就是有几条折线

 @param chartView chartView
 @return 折线的数量
 */
- (NSInteger)numberOfLineForChartView:(FSLineChartView *)chartView;

/**
 折线图的纵轴数据分组

 @param chartView chartView
 @return 纵轴分组数量
 */
- (NSInteger)numberOfSectionsInOrdinateAxisForLineChartView:(FSLineChartView *)chartView;

/**
 数据点需要显示文字的Label，并不是真正使用Label，需要使用Label的字体，背景色，字体颜色，text，还有frame中的size属性，如果没有指定size属性，自动适配

 @param chartView chartView
 @param indexPath 数据点位置
 @return UILabel
 */
- (UILabel *)lineChartView:(FSLineChartView *)chartView dataLableAtIndexPath:(FSIndexPath *)indexPath;


/**
 横轴数据的Label，并不是真正使用，需要使用Label的字体，背景色，字体颜色，text，还有frame中的size属性，如果没有指定size属性，自动适配
 
 @param chartView chartView
 @param section 对应的section
 @return UILabel
 */
- (UILabel *)lineChartView:(FSLineChartView *)chartView abscissaAxisLableForSection:(NSInteger)section;

/**
 纵轴需要显示的Label，并不是真正使用，需要使用Label的字体，背景色，字体颜色，text，还有frame中的size属性，如果没有指定size属性，自动适配
 
 @param chartView chartView
 @param section 对应纵轴的section
 @return UILabel
 */
- (UILabel *)lineChartView:(FSLineChartView *)chartView ordinateAxisLableForSection:(NSInteger)section;

@end

@protocol FSLineChartViewDelegate<NSObject>
@optional

/**
 返回折线图的内边距参与计算，默认（20， 20， 20， 20）

 @param chartView chartView
 @return 内边距
 */
- (UIEdgeInsets)contentInsetForLineChartView:(FSLineChartView *)chartView;

/**
 横轴每个分组之间的间距，默认15

 @param chartView chartView
 @param section 分组
 @return 间距
 */
- (CGFloat)lineChartView:(FSLineChartView *)chartView spaceForSection:(NSInteger)section;

/**
 与横轴平行的线条UIView,可以设置高度和颜色以及样式，样式自己实现

 @param chartView chartView
 @param section 对应的section
 @return UIView
 */
- (UIView *)lineChartView:(FSLineChartView *)chartView abscissaAxisLineViewForSection:(NSInteger)section;

/**
 折线的颜色, 默认是[UIColor colorWithRed:77.0 / 255.0 green:196.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f]

 @param chartView chartView
 @param lineIndex 折线的下标
 @return 颜色
 */
- (UIColor *)lineChartView:(FSLineChartView *)chartView lineColorAtLineIndex:(NSInteger)lineIndex;


/**
 折线的宽度，默认2.0

 @param chartView chartView
 @param lineIndex 折线的下标
 @return 折线的宽度
 */
- (CGFloat)lineChartView:(FSLineChartView *)chartView lineWidthAtLineIndex:(NSInteger)lineIndex;

/**
 折线连接点的样式，默认没有任何样式

 @param chartView chartView
 @param indexPath 数据点位置
 @return 数据点的连接样式
 */
- (FSLineJoinStyle)lineChartView:(FSLineChartView *)chartView lineJoinStyleAtIndexPath:(FSIndexPath *)indexPath;

/**
 折线连接点的颜色，默认是[UIColor cyanColor]

 @param chartView chartView
 @param indexPath 数据点
 @return 颜色
 */
- (UIColor *)lineChartView:(FSLineChartView *)chartView lineJoinColorAtIndexPath:(FSIndexPath *)indexPath;


/**
 点击数据点的方法

 @param chartView chartView
 @param indexPath 数据点
 */
- (void)lineChartView:(FSLineChartView *)chartView didSelectItemAtIndexPath:(FSIndexPath *)indexPath touchPoint:(CGPoint)point;

@end


/**
 折线的显示是根据frame的宽度显示，如果frame的宽度小于数据所需要的宽度，剩余数据不显示，所有的计算全部在layoutSubviews:方法内进行的
 */
IB_DESIGNABLE
@interface FSLineChartView : UIView

@property (nonatomic, weak) IBOutlet id<FSLineChartViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet id<FSLineChartViewDataSource> dataSource;


@property (nonatomic, strong, readonly) UIView *abscissaAxis;
@property (nonatomic, strong, readonly) UIView *ordinateAxis;


/**
 动画时长，默认1s
 */
@property (nonatomic, assign) CGFloat animatedDuration;

/**
 刷新所有数据
 */
- (void)reloadData;


/**
 刷新某一条折线

 @param lineIndex 折线对应的下标
 */
- (void)reloadDataAtLineIndex:(NSInteger)lineIndex;

/**
 刷新横轴
 */
- (void)reloadDataAbscissaAxis;

/**
 刷新纵轴
 */
- (void)reloadDataOrdinateAxis;

@end
