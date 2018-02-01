//
//  FSPieChartView.m
//  FSChartView
//
//  Created by vcyber on 2018/1/30.
//  Copyright © 2018年 vcyber. All rights reserved.
//

#import "FSPieChartView.h"
#import "UIView+FSFrame.h"

@interface FSPieChartView()<CAAnimationDelegate> {
    CGFloat _minValue;
    CGFloat _outerCircleRadius;
    CGFloat _innerCircleRadius;
    NSInteger _sectionCount;
}

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *percentages;
@property (nonatomic, strong) NSMutableArray<UIColor *> *percentageColors;
@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString *, NSNumber *> *> *sectionPercentages;
@property (nonatomic, strong) NSMutableArray<UILabel *> *textLabels;
@property (nonatomic, strong) CALayer *pieLayer;
@property (nonatomic, strong) NSMutableArray<UIBezierPath *> *sectionPaths;
@property (nonatomic, strong) UIBezierPath *innerPath;
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, CAShapeLayer *> *selectedShape;

@end

@implementation FSPieChartView
//MARK: -Overried
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self fs_setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self fs_setup];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    _minValue = self.fs_width < self.fs_height ? self.fs_width : self.fs_height;
    _innerCircleRadius = _minValue / 6;
    _outerCircleRadius = _minValue / 2;
    _contentView.frame = self.bounds;
    _pieLayer.frame = self.bounds;
    [self reloadData];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.contentView];
    CGPoint center = CGPointMake(self.fs_width / 2, self.fs_height / 2);
    
    if (CGPathContainsPoint(self.innerPath.CGPath, NULL, touchPoint, NO)) {
        [self.selectedShape enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, CAShapeLayer * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj removeFromSuperlayer];
        }];
        [self.selectedShape removeAllObjects];
        [self fs_callDidDeselectAllSection];
        return;
    }
    
    for (NSInteger section = 0; section < _sectionCount; section++) {
        CGPathRef path = self.sectionPaths[section].CGPath;
        if (CGPathContainsPoint(path, NULL, touchPoint, YES)) {
            [self fs_callDidSelectWithSection:section];
            if (self.selectedShape[@(section)]) {
                [self.selectedShape[@(section)] removeFromSuperlayer];
                [self.selectedShape removeObjectForKey:@(section)];
                [self fs_callDidSelectWithSection:section];
                return;
            }
            if (!self.allowMultiSelected) {
                [self.selectedShape enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, CAShapeLayer * _Nonnull obj, BOOL * _Nonnull stop) {
                    [obj removeFromSuperlayer];
                }];
                [self.selectedShape removeAllObjects];
            }
            CAShapeLayer *outSideLayer = [CAShapeLayer layer];
            outSideLayer.lineWidth = 10;
            CGFloat r, g, b, a;
            [self.percentageColors[section] getRed:&r green:&g blue:&b alpha:&a];
            UIColor *newColor = [UIColor colorWithRed:r green:g blue:b alpha:a / 2];
            outSideLayer.strokeColor = newColor.CGColor;
            outSideLayer.fillColor = [UIColor clearColor].CGColor;
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:_outerCircleRadius + 5 startAngle:self.sectionPercentages[section][@"start"].floatValue endAngle:self.sectionPercentages[section][@"end"].floatValue clockwise:YES];
            outSideLayer.path = path.CGPath;
            [self.contentView.layer addSublayer:outSideLayer];
            [self.selectedShape setObject:outSideLayer forKey:@(section)];
            [self fs_callDidSelectWithSection:section];
            return;
        }
    }
}

//MARK: - Public Method
- (void)reloadData {
    self.contentView.layer.sublayers = nil;
    for (UILabel *textLabel in self.textLabels) {
        [textLabel removeFromSuperview];
    }
    
    [self.contentView.layer addSublayer:_pieLayer];
    _percentages = [NSMutableArray array];
    _percentageColors = [NSMutableArray array];
    _textLabels = [NSMutableArray array];
    _sectionPercentages = [NSMutableArray array];
    _sectionPaths = [NSMutableArray array];
    _selectedShape = [NSMutableDictionary dictionary];
    [self fs_getPercent];
    [self fs_setupMask];
    [self fs_setupDataCircle];
    [self fs_setupInnerCircle];
    [self fs_addAnimation];
}

//MARK: - Private Method
- (void)fs_setup {
    self.backgroundColor = [UIColor whiteColor];
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_contentView];
    _pieLayer = [CALayer layer];
    _showAnimated = YES;
    _duration = 1.0;
}

- (void)fs_setupInnerCircle {
    _innerCircleRadius = [self fs_getInnerCircleRadius];
    if (_innerCircleRadius <= 0.0) {
        return;
    }
    UIColor *color = [self fs_getInnerCircleBackgroundColor];
    CAShapeLayer *innerCircle = [CAShapeLayer layer];
    innerCircle.lineWidth = 0.1;
    innerCircle.strokeColor = [UIColor clearColor].CGColor;
    innerCircle.fillColor = [color CGColor];
    CGPoint center = CGPointMake(self.fs_width / 2, self.fs_height / 2);
    UIBezierPath *innerPath = [UIBezierPath bezierPathWithArcCenter:center radius:_innerCircleRadius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    _innerPath = innerPath;
    innerCircle.path = innerPath.CGPath;
    [self.pieLayer addSublayer:innerCircle];
}

- (void)fs_getPercent {
    NSInteger sections = [self fs_getSectionCount];
    _sectionCount = sections;
    for (NSInteger section = 0; section < sections; section++) {
        CGFloat percentage = [self fs_getPercentageDataForSection:section];
        [self.percentages addObject:@(percentage)];
    }
}

- (void)fs_setupDataCircle {
    CGFloat totalPercentage = 0.0;
    CGFloat startAngle = [self fs_getStartAngle];
    for (NSInteger section = 0; section < _sectionCount; section++) {
        CGFloat lineWidth = 0.1;
        CAShapeLayer *pieLayer = [CAShapeLayer layer];
        CGPoint center = CGPointMake(self.fs_width / 2, self.fs_height / 2);
        CGFloat currentPercentage = self.percentages[section].floatValue;
        CGFloat start = startAngle + totalPercentage * M_PI * 2;
        CGFloat end = start + currentPercentage * M_PI * 2;
        totalPercentage += currentPercentage;
        UIBezierPath *piePath = [UIBezierPath bezierPathWithArcCenter:center radius:_outerCircleRadius startAngle:start endAngle:end clockwise:YES];
        [piePath addLineToPoint:center];
        [piePath closePath];
        UIColor *fillColor = [self fs_getSectionColor:section];
        if (!fillColor) {
            fillColor = [UIColor clearColor];
        }
        [self.percentageColors addObject:fillColor];
        pieLayer.fillColor = fillColor.CGColor;
        pieLayer.strokeColor = [UIColor clearColor].CGColor;
        pieLayer.lineWidth = lineWidth;
        pieLayer.path = piePath.CGPath;
        [self.pieLayer addSublayer:pieLayer];
        NSDictionary *sectionDict = @{@"start":@(start), @"end":@(end)};
        [self.sectionPercentages addObject:sectionDict];
        [self.sectionPaths addObject:piePath];
        
        //计算textLabel
        CGFloat radius = _innerCircleRadius + (_outerCircleRadius - _innerCircleRadius) / 2;
        CGFloat rad = (startAngle + M_PI_2) + (totalPercentage - currentPercentage / 2) * M_PI * 2;
        CGFloat x = self.fs_width / 2 + radius * sin(rad);
        CGFloat y = self.fs_height / 2 -  radius * cos(rad);
        CGPoint textLabelCenter = CGPointMake(x, y);

        UILabel *textLabel = [self fs_getDataLabelForSection:section];
        if (!textLabel) {
            continue;
        }
        CGSize size = textLabel.fs_size;
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            size = [textLabel.text sizeWithAttributes:@{NSFontAttributeName:textLabel.font}];
            textLabel.fs_size = size;
        }
        textLabel.numberOfLines = 0;
        textLabel.center = textLabelCenter;
        textLabel.alpha = 0;
        textLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:textLabel];
        if (textLabel) {
            [self.textLabels addObject:textLabel];
        }
    }
}

- (void)fs_setupMask {
    CGFloat startAngle = [self fs_getStartAngle];
    CGFloat radius = _outerCircleRadius / 2;
    CGFloat lineWidth = _outerCircleRadius;
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.lineWidth = lineWidth;
    mask.fillColor = [UIColor clearColor].CGColor;
    mask.strokeColor = [UIColor blackColor].CGColor;
    mask.strokeStart = 0.0;
    mask.strokeEnd = 1.0;
    CGPoint center = CGPointMake(self.fs_width / 2, self.fs_height / 2);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:M_PI * 2 + startAngle clockwise:YES];
    mask.path = maskPath.CGPath;
    self.pieLayer.mask = mask;
}

- (void)fs_addAnimation {
    if (self.showAnimated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration  = _duration;
        animation.fromValue = @0;
        animation.toValue   = @1;
        animation.delegate  = self;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.removedOnCompletion = YES;
        [self.pieLayer.mask addAnimation:animation forKey:@"circleAnimation"];
    }else {
        [self.textLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [UIView animateWithDuration:0.2 animations:^{
                obj.alpha = 1.0;
            }];
        }];
    }
}


//MARK: -Call DataSource
- (NSInteger)fs_getSectionCount {
    return [self.dataSource numberOfSectionForChartView:self];
}

- (CGFloat)fs_getPercentageDataForSection:(NSInteger)section {
    return [self.dataSource pieChartView:self percentageDataForSection:section];
}

- (UILabel *)fs_getDataLabelForSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(pieChartView:dataLabelForSection:)]) {
        return [self.dataSource pieChartView:self dataLabelForSection:section];
    }
    return nil;
}

//MARK: -Call Delegate
- (UIColor *)fs_getSectionColor:(NSInteger)section {
    return [self.delegate pieChartView:self colorForSection:section];
}

- (CGFloat)fs_getInnerCircleRadius {
    if ([self.delegate respondsToSelector:@selector(innerCircleRadiusForChartView:)]) {
        CGFloat radius = [self.delegate innerCircleRadiusForChartView:self];
        if (radius < 0.0 || radius >= _minValue) {
            return _innerCircleRadius;
        }
        return radius;
    }
    return _innerCircleRadius;
}

- (UIColor *)fs_getInnerCircleBackgroundColor {
    if ([self.delegate respondsToSelector:@selector(innerCircleBackgroundColorForChartView:)]) {
        UIColor *color = [self.delegate innerCircleBackgroundColorForChartView:self];
        if (!color) {
            color = self.backgroundColor;
        }
        return color;
    }
    return self.backgroundColor;
}

- (CGFloat)fs_getStartAngle {
    if ([self.delegate respondsToSelector:@selector(startAngleForChartView:)]) {
        return [self.delegate startAngleForChartView:self];
    }
    return -M_PI_2;
}

- (void)fs_callDidSelectWithSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(pieChartView:didSelectItemForSection:)]) {
        [self.delegate pieChartView:self didSelectItemForSection:section];
    }
}

- (void)fs_callDidDeselectWithSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(pieChartView:didDeselectItemForSection:)]) {
        [self.delegate pieChartView:self didDeselectItemForSection:section];
    }
}

- (void)fs_callDidDeselectAllSection {
    if ([self.delegate respondsToSelector:@selector(didDeselectAllSectionForChartView:)]) {
        [self.delegate didDeselectAllSectionForChartView:self];
    }
}

//MARK: - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.textLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [UIView animateWithDuration:0.2 animations:^{
            obj.alpha = 1.0;
        }];
    }];
}

@end
