//
//  FSAxisView.m
//  FSChartView
//
//  Created by 刘瑾 on 2019/6/4.
//  Copyright © 2019 vcyber. All rights reserved.
//

#import "FSAxisView.h"

@interface FSAxisView ()

@property (nonatomic, strong) CAShapeLayer *axisLayer;

@end

@implementation FSAxisView

-(instancetype)initWithAxisType:(FSAxisType)axisType
                          frame:(CGRect)frame
                      axisColor:(nonnull UIColor *)axisColor{
    if (self = [super initWithFrame:frame]) {
        self.axisType = axisType;
        self.axisColor = axisColor;
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    switch (self.axisType) {
        case FSAxisTypeSolidArrow:
            [self drawSolidArrow:rect];
            break;
        case FSAxisTypeArrow:
            [self drawArrow:rect];
            break;
        case FSAxisTypeOpenArrow:
            [self drawOpenArrow:rect];
            break;
        case FSAxisTypeNone:
            [self drawNoneType:rect];
            break;
        default:
            break;
    }
}

-(void)drawNoneType:(CGRect)rect{
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (rect.size.height>rect.size.width) {
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(0, rect.size.height)];
    }else{
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(rect.size.width, 0)];
    }
    
    CAShapeLayer *arrowLayer = [CAShapeLayer layer];
    arrowLayer.strokeColor = self.axisColor.CGColor;
    arrowLayer.path = path.CGPath;
    arrowLayer.lineWidth = 1;
    self.axisLayer = arrowLayer;
    [self.layer addSublayer:arrowLayer];
    
}

-(void)drawOpenArrow:(CGRect)rect{
    CAShapeLayer *arrowLayer = nil;
    if (rect.size.height>rect.size.width) {
        arrowLayer = [self getOpenVerticalArrowLayer:rect];
    }else{
        arrowLayer = [self getOpenHorizontalArrowLayer:rect];
    }
    
    arrowLayer.strokeColor = self.axisColor.CGColor;
    arrowLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:arrowLayer];
    [self.layer addSublayer:[self getLineLayer:rect]];
}

/**
 绘制箭头

 @param rect <#rect description#>
 */
-(void)drawArrow:(CGRect)rect{
    CAShapeLayer *arrowLayer = nil;
    if (rect.size.height>rect.size.width) {
        arrowLayer = [self getVerticalArrowLayer:rect];
    }else{
        arrowLayer = [self getHorizontalArrowLayer:rect];
    }
    
    arrowLayer.strokeColor = self.axisColor.CGColor;
    arrowLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:arrowLayer];
    self.axisLayer = arrowLayer;
    [self.layer addSublayer:[self getLineLayer:rect]];
}

/**
 绘制实心箭头

 @param rect <#rect description#>
 */
-(void)drawSolidArrow:(CGRect)rect{
    
    CAShapeLayer *arrowLayer = nil;
    
    if (rect.size.height>rect.size.width) {
        arrowLayer = [self getVerticalArrowLayer:rect];
    }else{
        arrowLayer = [self getHorizontalArrowLayer:rect];
    }
    
    arrowLayer.strokeColor = self.axisColor.CGColor;
    arrowLayer.fillColor = self.axisColor.CGColor;
    [self.layer addSublayer:arrowLayer];
    self.axisLayer = arrowLayer;
    [self.layer addSublayer:[self getLineLayer:rect]];
}

/**
 设置直线图层

 @param rect <#rect description#>
 @return <#return value description#>
 */
-(CALayer *)getLineLayer:(CGRect)rect{
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    if (rect.size.height>rect.size.width) {
        [linePath moveToPoint:CGPointMake(rect.size.width/2.0, rect.size.width)];
        [linePath addLineToPoint:CGPointMake(rect.size.width/2.0, rect.size.height+rect.size.width/2.0)];
    }else{
        [linePath moveToPoint:CGPointMake(rect.size.height/2.0, rect.size.height/2.0)];
        [linePath addLineToPoint:CGPointMake(rect.size.width-rect.size.height, rect.size.height/2.0)];
    }
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = 1;
    lineLayer.strokeColor = self.axisColor.CGColor;
    lineLayer.path = linePath.CGPath;
    return lineLayer;
}

-(CAShapeLayer *)getOpenVerticalArrowLayer:(CGRect)rect{
    CAShapeLayer *arrowLayer = [CAShapeLayer layer];
    arrowLayer.lineWidth = 1;
    arrowLayer.path = [self drawOpenVerticalArrowPath:rect].CGPath;
    return arrowLayer;
}

-(UIBezierPath *)drawOpenVerticalArrowPath:(CGRect)rect{
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    CGFloat length = rect.size.width;
    [arrowPath moveToPoint:CGPointMake(0, length)];
    [arrowPath addLineToPoint:CGPointMake(length/2.0, 0)];
    [arrowPath addLineToPoint:CGPointMake(length, length)];
    [arrowPath moveToPoint:CGPointMake(length/2.0, 0)];
    [arrowPath addLineToPoint:CGPointMake(length/2.0, length)];
    return arrowPath;
}

-(CAShapeLayer *)getOpenHorizontalArrowLayer:(CGRect)rect{
    CAShapeLayer *arrowLayer = [CAShapeLayer layer];
    arrowLayer.lineWidth = 1;
    arrowLayer.path = [self drawOpenHorizontalArrowPath:rect].CGPath;
    return arrowLayer;
}

-(UIBezierPath *)drawOpenHorizontalArrowPath:(CGRect)rect{
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    CGFloat length = rect.size.height;
    CGFloat width = rect.size.width;
    [arrowPath moveToPoint:CGPointMake(width-length, 0)];
    [arrowPath addLineToPoint:CGPointMake(width, length/2.0)];
    [arrowPath addLineToPoint:CGPointMake(width-length, length)];
    [arrowPath moveToPoint:CGPointMake(width-length, length/2.0)];
    [arrowPath addLineToPoint:CGPointMake(width, length/2.0)];
    [arrowPath closePath];
    return arrowPath;
}

/**
 设置垂直方向箭头图层

 @param rect <#rect description#>
 @return <#return value description#>
 */
-(CAShapeLayer *)getVerticalArrowLayer:(CGRect)rect{
    CAShapeLayer *arrowLayer = [CAShapeLayer layer];
    arrowLayer.lineWidth = 1;
    arrowLayer.path = [self drawVerticalArrowPath:rect].CGPath;
    return arrowLayer;
}

/**
 设置垂直方向的箭头

 @param rect <#rect description#>
 @return <#return value description#>
 */
-(UIBezierPath *)drawVerticalArrowPath:(CGRect)rect{
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    CGFloat length = rect.size.width;
    [arrowPath moveToPoint:CGPointMake(0, length)];
    [arrowPath addLineToPoint:CGPointMake(length/2.0, 0)];
    [arrowPath addLineToPoint:CGPointMake(length, length)];
    [arrowPath closePath];
    return arrowPath;
}

/**
 设置水平方向箭头图层

 @param rect <#rect description#>
 @return <#return value description#>
 */
-(CAShapeLayer *)getHorizontalArrowLayer:(CGRect)rect{
    CAShapeLayer *arrowLayer = [CAShapeLayer layer];
    arrowLayer.lineWidth = 1;
    arrowLayer.path = [self drawHorizontalArrowPath:rect].CGPath;
    return arrowLayer;
}

/**
 设置水平方向的箭头

 @param rect <#rect description#>
 @return <#return value description#>
 */
-(UIBezierPath *)drawHorizontalArrowPath:(CGRect)rect{
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    CGFloat length = rect.size.height;
    CGFloat width = rect.size.width;
    [arrowPath moveToPoint:CGPointMake(width-length, 0)];
    [arrowPath addLineToPoint:CGPointMake(width, length/2.0)];
    [arrowPath addLineToPoint:CGPointMake(width-length, length)];
    [arrowPath closePath];
    return arrowPath;
}

#pragma mark - Property

-(void)setAxisColor:(UIColor *)axisColor{
    _axisColor = axisColor;
    if (!self.axisLayer) return;
    self.axisLayer.strokeColor = axisColor.CGColor;
    if (self.axisType == FSAxisTypeSolidArrow) {
        self.axisLayer.fillColor = axisColor.CGColor;
    }
}

-(void)setFrame:(CGRect)frame{
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    if (height>width&&width<10) {
        if (self.axisType!=FSAxisTypeNone) {
            frame.size.width = 10;
        }else{
            frame.size.width = 1;
        }
        
    }
    if (width>height&&height<10) {
        if (self.axisType!=FSAxisTypeNone) {
            frame.size.height = 10;
        }else{
            frame.size.height = 1;
        }
    }
    [super setFrame:frame];
}


@end
