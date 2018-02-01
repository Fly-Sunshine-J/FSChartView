//
//  FSBarChartViewCell.m
//  FSChartView
//
//  Created by vcyber on 2018/1/23.
//  Copyright © 2018年 vcyber. All rights reserved.
//

#import "FSBarChartViewCell.h"
#import "CALayer+FSFrame.h"
#import "UIView+FSFrame.h"

@interface FSBarChartViewCell()
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@end

@implementation FSBarChartViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:62 / 255.0 green:109 / 255.0 blue:176 / 255.0 alpha:0.5];
        _progressColor = [UIColor colorWithRed:62 / 255.0 green:109 / 255.0 blue:176 / 255.0 alpha:1];
        _portrait = YES;
        _progress = 0.0;
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = self.bounds;
        [self.layer addSublayer:_progressLayer];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    if (progress < 0.0) {
        NSAssert(NO, @"progress小于0.0，请检查最大值和数据");
        progress = 0;
    }
    if (progress > 1.0) {
        NSAssert(NO, @"progress大于1.0，请检查最大值和数据");
        progress = 1.0;
    }
    _progress = progress;
    
    _progressLayer.strokeColor = self.progressColor.CGColor;
    _progressLayer.lineWidth = self.portrait ? self.frame.size.width : self.frame.size.height;
    UIBezierPath *progressPath = [UIBezierPath bezierPath];
    CGPoint movePoint = self.isPortrait ? CGPointMake(self.progressLayer.fs_width / 2, self.progressLayer.fs_height) : CGPointMake(0, self.progressLayer.fs_height / 2);
    [progressPath moveToPoint:movePoint];
    CGPoint endPoint = self.isPortrait ? CGPointMake(self.progressLayer.fs_width / 2, self.progressLayer.fs_height * (1 - progress)) : CGPointMake(self.progressLayer.fs_width * progress, self.progressLayer.fs_height / 2);
    [progressPath addLineToPoint:endPoint];
    self.progressLayer.path = progressPath.CGPath;
    
    if (animated) {
        CABasicAnimation *progressAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        progressAnimation.duration = 0.5;
        progressAnimation.fromValue = @0.0;
        progressAnimation.toValue = @1.0;
        [self.progressLayer addAnimation:progressAnimation forKey:@"progressAnimation"];
    }
    
    CGSize textSize = [self.topTextLabel.text sizeWithAttributes:@{NSFontAttributeName:self.topTextLabel.font}];
    self.topTextLabel.fs_size = textSize;
    CGPoint center = self.isPortrait ? CGPointMake(self.progressLayer.fs_width / 2, self.progressLayer.fs_height - textSize.height / 2) : CGPointMake(textSize.width / 2, self.progressLayer.fs_height / 2);
    self.topTextLabel.center = center;
    
    CGFloat centerX = 0.0, centerY = 0.0;
    if (self.isPortrait) {
        centerX = self.topTextLabel.center.x;
        if (endPoint.y <= textSize.height) {
            centerY = textSize.height / 2;
        }else {
            centerY = endPoint.y - textSize.height / 2;
        }
    }else {
        centerY = self.topTextLabel.center.y;
        if (self.progressLayer.fs_width - endPoint.x <= textSize.width) {
            centerX = self.progressLayer.fs_width - textSize.width / 2;
        }else {
            centerX = endPoint.x + textSize.width / 2;
        }
    }
    
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            self.topTextLabel.center = CGPointMake(centerX, centerY);
        }];
    }else {
        self.topTextLabel.center = CGPointMake(centerX, centerY);
    }
}

- (void)setProgress:(CGFloat)progress {
    [self setProgress:progress animated:YES];
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    _progressLayer.strokeColor = progressColor.CGColor;
}



- (UILabel *)topTextLabel {
    if (!_topTextLabel) {
        _topTextLabel = [[UILabel alloc] init];
        _topTextLabel.font = [UIFont systemFontOfSize:8];
        _topTextLabel.textColor = [UIColor whiteColor];
        _topTextLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_topTextLabel];
    }
    return _topTextLabel;
}


@end
