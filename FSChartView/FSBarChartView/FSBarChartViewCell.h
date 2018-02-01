//
//  FSBarChartViewCell.h
//  FSChartView
//
//  Created by vcyber on 2018/1/23.
//  Copyright © 2018年 vcyber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSBarChartViewCell : UICollectionViewCell

@property (nonatomic, assign, getter=isPortrait) BOOL portrait;

@property (nonatomic, strong) UILabel *topTextLabel;
@property (nonatomic, strong) UIColor *progressColor;

@property (nonatomic, assign) CGFloat progress;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
