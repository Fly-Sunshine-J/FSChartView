//
//  FSLineChartView.m
//  FSChartView
//
//  Created by vcyber on 2018/1/25.
//  Copyright © 2018年 vcyber. All rights reserved.
//

#import "FSLineChartView.h"
#import "UIView+FSFrame.h"

@interface FSIndexPath()
@property (nonatomic, assign, readwrite) NSInteger lineIndex;
@property (nonatomic, assign, readwrite) NSInteger section;
@end

@implementation FSIndexPath
+ (instancetype)indexPathWithLineIndex:(NSInteger)lineIndex section:(NSInteger)section {
    FSIndexPath *indexPath = [[FSIndexPath alloc] init];
    indexPath.lineIndex = lineIndex;
    indexPath.section = section;
    return indexPath;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"FSIndexPath - (%@ - %@)", @(self.lineIndex), @(self.section)];
}

@end


@interface FSLineChartView()<UIScrollViewDelegate> {
    UIEdgeInsets _insets;
    CGFloat _maxSectionCount;
    NSInteger _lineCount;
}

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong, readwrite) UIView *abscissaAxis;
@property (nonatomic, strong, readwrite) UIView *ordinateAxis;

@property (nonatomic, strong) NSMutableArray<UIView *> *lineViews;
@property (nonatomic, strong) NSMutableArray<CATextLayer *> *ordinateLayers;
@property (nonatomic, strong) NSMutableArray<CATextLayer *> *abscissaLayers;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *spaces;
@property (nonatomic, assign) CGFloat totalWidth;

@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *lineLayers;
@property (nonatomic, strong) NSMutableArray<NSArray<CAShapeLayer *> *> *pointerLayers;
@property (nonatomic, strong) NSMutableArray<NSArray<CATextLayer *> *> *textLayers;

@property (nonatomic, strong) NSMutableArray<NSArray<NSDictionary<NSValue *, FSIndexPath *> *> *> *pointCache;

@end

@implementation FSLineChartView

// MARK: Overried

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self fs_init];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self fs_init];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _contentView.frame = self.bounds;
    [self reloadData];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
    [self fs_didSelectedPoint:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self fs_didSelectedPoint:touches withEvent:event];
}


// MARK: Public Method
- (void)reloadData {
    [self fs_getSpaces];
    [self fs_setupFrame];
    [self fs_setupNoDataAxis];
    [self fs_getAbscissaAxisLabels];
    [self fs_setupLines];
}

- (void)reloadDataAtLineIndex:(NSInteger)lineIndex {
    [self fs_setupLineAtIndex:lineIndex];
}

- (void)reloadDataAbscissaAxis {
    [self fs_getAbscissaAxisLabels];
}

- (void)reloadDataOrdinateAxis {
    [self fs_setupNoDataAxis];
}

// MARK: Private Method

- (void)fs_init {
    self.backgroundColor = [UIColor colorWithRed:254 / 255.0 green:197 / 255.0 blue:52 / 255.0 alpha:1];
    self.layer.masksToBounds = YES;
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    _contentView.layer.contentsScale = [UIScreen mainScreen].scale;
    _contentView.layer.allowsEdgeAntialiasing = YES;
    [self addSubview:_contentView];
    _animatedDuration = 1.0;
}

- (void)fs_setupFrame {
    self.abscissaAxis.frame = CGRectMake(_insets.left, self.fs_height - _insets.bottom, self.fs_width - _insets.left, 1);
    self.ordinateAxis.frame = CGRectMake(_insets.left, 0, 1, self.fs_height - _insets.bottom);

}

- (void)fs_setupNoDataAxis {
    for (UIView *lineView in self.lineViews) {
        [lineView removeFromSuperview];
    }
    for (CATextLayer *layer in self.ordinateLayers) {
        [layer removeFromSuperlayer];
    }
    [self.lineViews removeAllObjects];
    [self.ordinateLayers removeAllObjects];
    
    NSInteger noDataSection = [self fs_getOrdinateAxisSectionCount];
    CGFloat lineStep = noDataSection > 1 ? (self.fs_height - _insets.bottom - _insets.top - self.abscissaAxis.fs_height) / (noDataSection - 1) : self.ordinateAxis.fs_height;
    for (int ySection = 0; ySection < noDataSection; ySection++) {
        UILabel *ySectionLabel = [self fs_getOrdinateAxisLabelForSection:ySection];
        UIView *yLineView = [self fs_getAbscissaAxisLineViewForSection:ySection];
        
        if (yLineView) {
            if (yLineView.fs_height < 1.0) {
                yLineView.fs_height = 1.0;
            }
            yLineView.fs_width = self.abscissaAxis.fs_width - _insets.right;
            yLineView.fs_x = self.ordinateAxis.fs_width + self.ordinateAxis.fs_x;
            yLineView.fs_centerY = self.ordinateAxis.fs_height - self.ordinateAxis.fs_y - lineStep * ySection;
            yLineView.layer.zPosition = -1.0;
            [self.contentView addSubview:yLineView];
            [self.lineViews addObject:yLineView];
            if (ySection == 0) {
                yLineView.backgroundColor = [UIColor clearColor];
                self.abscissaAxis.fs_height = yLineView.fs_height;
                self.ordinateAxis.fs_width = yLineView.fs_height;
            }
        }
        
        if (ySectionLabel) {
            if (!ySectionLabel || ![ySectionLabel isKindOfClass:[UILabel class]] || ySectionLabel.hidden || !ySectionLabel.text || ySectionLabel.text.length == 0) {
                continue;
            }
            CATextLayer *textLayer = [CATextLayer layer];
            textLayer.foregroundColor = ySectionLabel.textColor.CGColor;
            textLayer.alignmentMode = kCAAlignmentCenter;
            textLayer.backgroundColor = ySectionLabel.backgroundColor.CGColor;
            textLayer.font = (__bridge CFTypeRef _Nullable)(ySectionLabel.font);
            textLayer.fontSize = ySectionLabel.font.pointSize;
            textLayer.string = ySectionLabel.text;
            textLayer.contentsScale = [UIScreen mainScreen].scale;
            
            CGSize textSize = ySectionLabel.frame.size;
            if (CGSizeEqualToSize(textSize, CGSizeZero)) {
                textSize = [ySectionLabel.text sizeWithAttributes:@{NSFontAttributeName:ySectionLabel.font}];
            }
            textLayer.frame = CGRectMake(_insets.left - textSize.width - 2, self.ordinateAxis.fs_height  - self.ordinateAxis.fs_y - lineStep * ySection - textSize.height / 2, textSize.width, textSize.height);
            [self.contentView.layer addSublayer:textLayer];
            [self.ordinateLayers addObject:textLayer];
        }
    }
}

- (void)fs_getAbscissaAxisLabels {
    for (CATextLayer *layer in self.abscissaLayers) {
        [layer removeFromSuperlayer];
    }
    [self.abscissaLayers removeAllObjects];
    for (int section = 0; section < _maxSectionCount; section++) {
        CGFloat width = self.spaces[section].floatValue;
        if (width > self.fs_width - _insets.right) {
            break;
        }
        UILabel *textLabel = [self fs_getAbscissaAxisLabelForSection:section];
        if (!textLabel || ![textLabel isKindOfClass:[UILabel class]] || textLabel.hidden || !textLabel.text || textLabel.text.length == 0) {
            return;
        }
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.foregroundColor = textLabel.textColor.CGColor;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.backgroundColor = textLabel.backgroundColor.CGColor;
        textLayer.font = (__bridge CFTypeRef _Nullable)(textLabel.font);
        textLayer.fontSize = textLabel.font.pointSize;
        textLayer.string = textLabel.text;
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        
        CGSize textSize = textLabel.frame.size;
        if (CGSizeEqualToSize(textSize, CGSizeZero)) {
            textSize = [textLabel.text sizeWithAttributes:@{NSFontAttributeName:textLabel.font}];
        }
        CGFloat centerX = [self.spaces[section] floatValue];
        textLayer.frame = CGRectMake(centerX - textSize.width / 2, self.abscissaAxis.fs_y + self.abscissaAxis.fs_height + 2, textSize.width, textSize.height);
        [self.contentView.layer addSublayer:textLayer];
        [self.abscissaLayers addObject:textLayer];
    }
}

- (void)fs_getSpaces {
    _insets = [self fs_getContentInset];
    NSInteger sectionCount = 0;
    NSInteger lineNumber = [self fs_getNumberOfLine];
    _lineCount = lineNumber;
    for (int number = 0; number < lineNumber; number++) {
        NSInteger section = [self fs_getSectionsAtLineIndex:number];
        sectionCount = sectionCount < section ? section : sectionCount;
    }
    CGFloat totalWidth = 0.0;
    [self.spaces removeAllObjects];
    for (int section = 0; section < sectionCount; section++) {
        CGFloat space = [self fs_getSpaceForSection:section];
        if (section == 0) {
            space += _insets.left;
        }
        totalWidth += space;
        [self.spaces addObject:@(totalWidth)];
    }
    _totalWidth = totalWidth + _insets.right;
    _maxSectionCount = sectionCount;
}

- (void)fs_setupLines {
    for (int lineIndex = 0; lineIndex < _lineCount; lineIndex++) {
        [self fs_setupLineAtIndex:lineIndex];
    }
}

- (void)fs_setupLineAtIndex:(NSInteger)lineIndex {
    
    if (lineIndex < self.lineLayers.count) {
        [self.lineLayers[lineIndex] removeAllAnimations];
        [self.lineLayers[lineIndex] removeFromSuperlayer];
        [self.lineLayers removeObjectAtIndex:lineIndex];
        
        for (CAShapeLayer *layer in self.pointerLayers[lineIndex]) {
            [layer removeFromSuperlayer];
        }
        [self.pointerLayers removeObjectAtIndex:lineIndex];
        for (CATextLayer *layer in self.textLayers[lineIndex]) {
            [layer removeFromSuperlayer];
        }
        [self.textLayers removeObjectAtIndex:lineIndex];
        [self.pointCache removeObjectAtIndex:lineIndex];
    }
    
    CGFloat height = self.fs_height - _insets.top - _insets.bottom - self.abscissaAxis.fs_height;
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    [self.contentView.layer addSublayer:lineLayer];
    [self.lineLayers insertObject:lineLayer atIndex:lineIndex];
    lineLayer.frame = self.bounds;
    lineLayer.strokeColor = [self fs_getLineColorAtLineIndex:lineIndex].CGColor;
    lineLayer.fillColor = nil;
    lineLayer.lineCap = kCALineCapRound;
    lineLayer.lineJoin = kCALineJoinRound;
    lineLayer.lineWidth = [self fs_getLineWidthAtLineIndex:lineIndex];
    lineLayer.contentsScale = [UIScreen mainScreen].scale;
    
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    NSMutableArray<CAShapeLayer *> *pointArray = [NSMutableArray array];
    NSMutableArray<CATextLayer *> *textLayers = [NSMutableArray array];
    NSMutableArray<NSDictionary <NSValue *, FSIndexPath *> *> *pointCache = [NSMutableArray array];
    NSInteger sectionCount = [self fs_getSectionsAtLineIndex:lineIndex];
    
    for (int section = 0; section < sectionCount; section++) {
        FSIndexPath *indexPath = [FSIndexPath indexPathWithLineIndex:lineIndex section:section];
        CGFloat percentage = [self fs_getPercentageDataAtIndexPath:indexPath];
        CGFloat width = self.spaces[section].floatValue;
        if (width > self.fs_width - _insets.right) {
            break;
        }
        CGPoint point = CGPointMake(width, self.fs_height - _insets.bottom - height * percentage - self.abscissaAxis.fs_height);
        
        NSDictionary <NSValue *, FSIndexPath *> *pointDict = @{[NSValue valueWithCGPoint:point]:indexPath};
        [pointCache addObject:pointDict];
        
        CAShapeLayer *pointShape = [CAShapeLayer layer];
        pointShape.frame = CGRectMake(0, 0, 6.0, 6.0);
        pointShape.position = point;
        UIColor *strockColor = [self fs_getLineJoinColorAtIndexPath:indexPath];
        pointShape.strokeColor = strockColor.CGColor;
        pointShape.fillColor = self.backgroundColor.CGColor;
        pointShape.lineWidth = 1.5;
        [self.contentView.layer addSublayer:pointShape];
        [pointArray addObject:pointShape];
        
        FSLineJoinStyle style = [self fs_getLineJoinStyleAtIndexPath:indexPath];
        if (style == FSLineJoinStyleRound) {
            UIBezierPath *roundPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(3, 3) radius:3 startAngle:0 endAngle:2 * M_PI  clockwise:YES];
            pointShape.path = roundPath.CGPath;
        }else if (style == FSLineJoinStyleTriangle) {
            UIBezierPath *trianglePath = [UIBezierPath bezierPath];
            [trianglePath moveToPoint:CGPointMake(3, 0)];
            [trianglePath addLineToPoint:CGPointMake(0, 6)];
            [trianglePath addLineToPoint:CGPointMake(6, 6)];
            [trianglePath closePath];
            pointShape.path = trianglePath.CGPath;
        }else if (style == FSLineJoinStyleSquare) {
            UIBezierPath *rectanglePath = [UIBezierPath bezierPathWithRect:pointShape.bounds];
            pointShape.path = rectanglePath.CGPath;
        }
        
        CATextLayer *textLayer = [self fs_createDataTextLayerAtIndexPath:indexPath WithPoint:point];
        if (textLayer) {
            [textLayers addObject:textLayer];
        }
        
        if (section == 0) {
            [linePath moveToPoint:point];
        }else {
            [linePath addLineToPoint:point];
        }
        
    }
    lineLayer.path = linePath.CGPath;
    [self.pointerLayers insertObject:pointArray.copy atIndex:lineIndex];
    [self.textLayers insertObject:textLayers.copy atIndex:lineIndex];
    [self.pointCache insertObject:pointCache atIndex:lineIndex];
    
    
    CABasicAnimation *progressAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    progressAnimation.duration = _animatedDuration;
    progressAnimation.fromValue = @0.0;
    progressAnimation.toValue = @1.0;
    [lineLayer addAnimation:progressAnimation forKey:@"progressAnimation"];
}

- (CATextLayer *)fs_createDataTextLayerAtIndexPath:(FSIndexPath *)indexPath WithPoint:(CGPoint)point {
    UILabel *textLabel = [self fs_getDataLabelOfIndexPath:indexPath];
    if (!textLabel || ![textLabel isKindOfClass:[UILabel class]] || textLabel.hidden || !textLabel.text || textLabel.text.length == 0) {
        return nil;
    }
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.foregroundColor = textLabel.textColor.CGColor;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.backgroundColor = textLabel.backgroundColor.CGColor;
    textLayer.font = (__bridge CFTypeRef _Nullable)(textLabel.font);
    textLayer.fontSize = textLabel.font.pointSize;
    textLayer.string = textLabel.text;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    
    CGSize textSize = textLabel.frame.size;
    if (CGSizeEqualToSize(textSize, CGSizeZero)) {
        textSize = [textLabel.text sizeWithAttributes:@{NSFontAttributeName:textLabel.font}];
    }
    textLayer.frame = CGRectMake(point.x - textSize.width / 2, point.y - 3 - textSize.height, textSize.width, textSize.height);
    textLayer.zPosition = 0.1;
    [self.contentView.layer addSublayer:textLayer];
    return textLayer;
}

- (void)fs_didSelectedPoint:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    CGFloat range = 20.0;
    
    for (NSArray<NSDictionary<NSValue *,FSIndexPath *> *> *points in self.pointCache) {
        for (NSDictionary<NSValue *,FSIndexPath *> *dict in points) {
            NSValue *pointKey = [dict allKeys].firstObject;
            CGPoint point = pointKey.CGPointValue;
            CGRect rect = CGRectMake(point.x - range / 2, point.y - range / 2, range, range);
            if (CGRectContainsPoint(rect, touchPoint)) {
                [self fs_didSelectedItemAtIndexPath:dict[pointKey] touchPoint:point];
                return;
            }
        }
    }
}

// MARK: Lazy Load

- (UIView *)abscissaAxis {
    if (!_abscissaAxis) {
        _abscissaAxis = [[UIView alloc] init];
        _abscissaAxis.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self.contentView addSubview:_abscissaAxis];
    }
    return _abscissaAxis;
}


- (UIView *)ordinateAxis {
    if (!_ordinateAxis) {
        _ordinateAxis = [[UIView alloc] init];
        _ordinateAxis.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self.contentView addSubview:_ordinateAxis];
    }
    return _ordinateAxis;
}

- (NSMutableArray<UIView *> *)lineViews {
    if (!_lineViews) {
        _lineViews = [NSMutableArray array];
    }
    return _lineViews;
}

- (NSMutableArray<CATextLayer *> *)ordinateLayers {
    if (!_ordinateLayers) {
        _ordinateLayers = [NSMutableArray array];
    }
    return _ordinateLayers;
}

- (NSMutableArray<CATextLayer *> *)abscissaLayers {
    if (!_abscissaLayers) {
        _abscissaLayers = [NSMutableArray array];
    }
    return _abscissaLayers;
}

- (NSMutableArray<NSNumber *> *)spaces {
    if (!_spaces) {
        _spaces = [NSMutableArray array];
    }
    return _spaces;
}


- (NSMutableArray<CAShapeLayer *> *)lineLayers {
    if (!_lineLayers) {
        _lineLayers = [NSMutableArray array];
    }
    return _lineLayers;
}

- (NSMutableArray<NSArray<CAShapeLayer *> *> *)pointerLayers {
    if (!_pointerLayers) {
        _pointerLayers = [NSMutableArray array];
    }
    return _pointerLayers;
}

- (NSMutableArray<NSArray<CATextLayer *> *> *)textLayers {
    if (!_textLayers) {
        _textLayers = [NSMutableArray array];
    }
    return _textLayers;
}

- (NSMutableArray<NSArray<NSDictionary<NSValue *,FSIndexPath *> *> *> *)pointCache {
    if (!_pointCache) {
        _pointCache = [NSMutableArray array];
    }
    return _pointCache;
}

// MARK: Call DataSource

- (NSInteger)fs_getSectionsAtLineIndex:(NSInteger)lineIndex {
    return [self.dataSource lineChartView:self numberOfSectionsInAbscissaAxisAtLineIndex:lineIndex];
}

- (NSInteger)fs_getOrdinateAxisSectionCount {
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInOrdinateAxisForLineChartView:)]) {
        return [self.dataSource numberOfSectionsInOrdinateAxisForLineChartView:self];
    }
    return 0;
}

- (CGFloat)fs_getPercentageDataAtIndexPath:(FSIndexPath *)indexPath {
    CGFloat percentage = [self.dataSource lineChartView:self percentageDataAtIndexPath:indexPath];
    if (percentage < 0.0) {
        percentage = 0.0;
    }
    if (percentage > 1.0) {
        percentage = 1.0;
    }
    return percentage;
}

- (NSInteger)fs_getNumberOfLine {
    if ([self.dataSource respondsToSelector:@selector(numberOfLineForChartView:)]) {
        return [self.dataSource numberOfLineForChartView:self];
    }
    return 1;
}

- (UILabel *)fs_getDataLabelOfIndexPath:(FSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(lineChartView:dataLableAtIndexPath:)]) {
        return [self.dataSource lineChartView:self dataLableAtIndexPath:indexPath];
    }
    return nil;
}



// MARK: -Call Delegate
- (UIEdgeInsets)fs_getContentInset {
    if ([self.delegate respondsToSelector:@selector(contentInsetForLineChartView:)]) {
        return [self.delegate contentInsetForLineChartView:self];
    }
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

- (CGFloat)fs_getSpaceForSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(lineChartView:spaceForSection:)]) {
        return [self.delegate lineChartView:self spaceForSection:section];
    }
    return 15;
}


- (UILabel *)fs_getOrdinateAxisLabelForSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(lineChartView:ordinateAxisLableForSection:)]) {
        return [self.dataSource lineChartView:self ordinateAxisLableForSection:section];
    }
    return nil;
}

- (UIView *)fs_getAbscissaAxisLineViewForSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(lineChartView:abscissaAxisLineViewForSection:)]) {
        return [self.delegate lineChartView:self abscissaAxisLineViewForSection:section];
    }
    return nil;
}

- (UILabel *)fs_getAbscissaAxisLabelForSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(lineChartView:abscissaAxisLableForSection:)]) {
        return [self.dataSource lineChartView:self abscissaAxisLableForSection:section];
    }
    return nil;
}

- (UIColor *)fs_getLineColorAtLineIndex:(NSInteger)lineIndex {
    if ([self.delegate respondsToSelector:@selector(lineChartView:lineColorAtLineIndex:)]) {
        return [self.delegate lineChartView:self lineColorAtLineIndex:lineIndex];
    }
    return [UIColor colorWithRed:77.0 / 255.0 green:196.0 / 255.0 blue:122.0 / 255.0 alpha:1.0f];
}

- (CGFloat)fs_getLineWidthAtLineIndex:(NSInteger)lineIndex {
    if ([self.delegate respondsToSelector:@selector(lineChartView:lineWidthAtLineIndex:)]) {
        return [self.delegate lineChartView:self lineWidthAtLineIndex:lineIndex];
    }
    return 2.0;
}


- (FSLineJoinStyle)fs_getLineJoinStyleAtIndexPath:(FSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(lineChartView:lineJoinStyleAtIndexPath:)]) {
        return [self.delegate lineChartView:self lineJoinStyleAtIndexPath:indexPath];
    }
    return -1;
}

- (UIColor *)fs_getLineJoinColorAtIndexPath:(FSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(lineChartView:lineJoinColorAtIndexPath:)]) {
        return [self.delegate lineChartView:self lineJoinColorAtIndexPath:indexPath];
    }
    return [UIColor cyanColor];
}


- (void)fs_didSelectedItemAtIndexPath:(FSIndexPath *)indexPath touchPoint:(CGPoint)point {
    if ([self.delegate respondsToSelector:@selector(lineChartView:didSelectItemAtIndexPath:touchPoint:)]) {
        [self.delegate lineChartView:self didSelectItemAtIndexPath:indexPath touchPoint:point];
    }
}

@end
