//
//  FSBarChartView.h
//  FSChartView
//
//  Created by vcyber on 2018/1/23.
//  Copyright © 2018年 vcyber. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FSBarChartViewOrientation) {
    FSBarChartViewOrientationVertical   =   0,
    FSBarChartViewOrientationHorizontal
};

@class FSBarChartView;
@class FSBarChartViewCell;

@protocol FSBarChartViewDataSource<NSObject>
@required
 

/**
 横轴上需要分成多少分，纵向图表代表数据有多少组，横向图表代表固定数据轴需要分成多少分

 @param chartView chartView
 @return 返回多少分
 */
- (NSInteger)numberOfSectionsInAbscissaAxisForBarChartView:(FSBarChartView *)chartView;

/**
 纵轴上需要分成多少分  横向图表代表数据有多少组，纵向图表代表固定数据轴需要分成多少分

 @param chartView chartView
 @return 返回多少分
 */
- (NSInteger)numberOfSectionsInOrdinateAxisForBarChartView:(FSBarChartView *)chartView;

/**
 由于是使用UICollectionView实现，所以参照UICollectionView的代理方法，返回FSBarChartViewCell或其子类

 @param chartView chartView
 @param indexPath indexPath
 @return FSBarChartViewCell或其子类
 */
- (__kindof FSBarChartViewCell *)barChartView:(FSBarChartView *)chartView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 当方向是纵向的时候，横轴中每个部分又需要分成多少个item  横向图表不会调用

 @param chartView chartView
 @param section section
 @return section对应的多少个item
 */
- (NSInteger)barChartView:(FSBarChartView *)chartView numberOfItemAbscissaAxisInSection:(NSInteger)section;

/**
 当方向是横向的时候，纵轴中每个部分又需要分成多少个item   纵向图表不会调用
 
 @param chartView chartView
 @param section section
 @return section对应的多少个item
 */
- (NSInteger)barChartView:(FSBarChartView *)chartView numberOfItemOrdinateAxisInSection:(NSInteger)section;


/**
 图表的分块的横轴Label，可以设置Label的一些属性
 
 @param chartView chartView
 @param section 分块
 @return UILabel
 */
- (UILabel *)barChartView:(FSBarChartView *)chartView abscissaAxisLableForSection:(NSInteger)section;

/**
 图表的分块的纵轴Label，可以设置Label的一些属性
 
 @param chartView chartView
 @param section 分块
 @return UILabel
 */
- (UILabel *)barChartView:(FSBarChartView *)chartView ordinateAxisLableForSection:(NSInteger)section;

@end

@protocol FSBarChartViewDelegate<NSObject>
@optional

/**
 CollectionView的ContentInsert，需要参与计算，默认是（20， 20， 20， 20）

 @param chartView chartView
 @return UIEdgeInsets结构体
 */
- (UIEdgeInsets)contentInsetForBarChartView:(FSBarChartView *)chartView;

/**
 如果是纵向图标，对应的是indexPath对应的item的宽度，如果是横向，对应的是indexPath对应的item的高度, 默认10

 @param chartView chartView
 @param indexPath indexPath
 @return 宽度或高度值
 */
- (CGFloat)barChartView:(FSBarChartView *)chartView lineWidthForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 每一个分块的间距，默认15

 @param chartView chartView
 @param section 对应的分块
 @return 分块的间距
 */
- (CGFloat)barChartView:(FSBarChartView *)chartView spaceForSection:(NSInteger)section;


/**
 纵向图表的横向分割线条View，可以设置线条的颜色和样式，这里的样式需要自己实现

 @param chartView chartView
 @param section 对应的section
 @return UIView
 */
- (UIView *)barChartView:(FSBarChartView *)chartView abscissaAxisLineViewForSection:(NSInteger)section;

/**
 横向图表的纵向分割线，可以设置线条的颜色和样式，这里的样式需要自己实现

 @param chartView chartView
 @param section 对应的section
 @return UIView
 */
- (UIView *)barChartView:(FSBarChartView *)chartView ordinateAxisLineViewForSection:(NSInteger)section;

/*********以下是根据UICollectionViewDelegate方法仿写，可根据自己的需要实现或者增加方法***************/

/**
 是否可以选择

 @param chartView chartView
 @param indexPath 对应的indexPath
 @return YES可以选择，NO不可以选择
 */
- (BOOL)barChartView:(FSBarChartView *)chartView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 是否可以被反选

 @param chartView chartView
 @param indexPath 对应的indexPath
 @return YES可以反选，NO不可以返选
 */
- (BOOL)barChartView:(FSBarChartView *)chartView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 点击Item的方法

 @param chartView chartView
 @param indexPath 对应的indexPath
 */
- (void)barChartView:(FSBarChartView *)chartView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 反选Item的方法

 @param chartView chartView
 @param indexPath 对应的indexPath
 */
- (void)barChartView:(FSBarChartView *)chartView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;

@end



/**
 使用UICollectionView进行的柱状图封装，所以有很多类似UICollectionView的delegate和dataSource，以及公开方法，所有的计算都是在layoutSubviews这个方法进行的
 */
IB_DESIGNABLE
@interface FSBarChartView : UIView

- (instancetype)initWithFrame:(CGRect)frame orientation:(FSBarChartViewOrientation)orientation;

@property (nonatomic, assign, readonly) FSBarChartViewOrientation orientation;

/**
 横轴只读属性，可以设置高度和颜色
 */
@property (nonatomic, strong, readonly) UIView *abscissaAxis;

/**
 纵轴只读属性，可以设置宽度和颜色
 */
@property (nonatomic, strong, readonly) UIView *ordinateAxis;

@property (nonatomic, weak) IBOutlet id<FSBarChartViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<FSBarChartViewDelegate> delegate;

/****UICollectionView相关的公开方法，可根据自己的需要自己新增公开方法，本来打算公开一个只读属性UICollectionView的***********/

/**
 UICollectionView注册Cell的方法
 */
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;

/**
 UICollectionView的获取复用的Cell的方法
 */
- (__kindof FSBarChartViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

/**
 UICollectionView根据indexPath获取Cell的方法
 */
- (FSBarChartViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 UICollectionView的选择方法和反选方法
 */
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition;
- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

/****UICollectionView相关的公开方法，可根据自己的需要自己新增公开方法，本来打算公开一个只读属性UICollectionView的***********/


/**
 纵向图表更新纵轴，横向图表更新横轴
 */
- (void)reloadNonDataAxis;

/**
 更新全部数据
 */
- (void)reloadData;


/**
 更新指定indexPath的数据

 @param indexPaths indexPath的数组，里面不要有代表同一个cell的indexPath，可能会出现崩溃，这个好像是UICollectionView的bug
 */
- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

@end
