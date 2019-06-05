//
//  FSAxisView.h
//  FSChartView
//
//  Created by 刘瑾 on 2019/6/4.
//  Copyright © 2019 vcyber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FSAxisType) {
    FSAxisTypeNone,
    FSAxisTypeArrow, // 空心箭头
    FSAxisTypeSolidArrow, // 实心箭头
    FSAxisTypeOpenArrow // 开口箭头
};

@interface FSAxisView : UIView

/**
 初始化设置坐标坐标轴

 @param axisType 坐标轴的类型
 @param frame 坐标轴的大小
 @return 坐标轴对象
 */
-(instancetype)initWithAxisType:(FSAxisType)axisType
                          frame:(CGRect)frame
                      axisColor:(UIColor *)axisColor;

/**
 设置坐标轴的类型
 */
@property (nonatomic, assign) FSAxisType axisType;

/**
 设置坐标轴的颜色
 */
@property (nonatomic, strong) UIColor *axisColor;

@end

NS_ASSUME_NONNULL_END
