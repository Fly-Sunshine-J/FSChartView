//
//  FSBarChartView.m
//  FSChartView
//
//  Created by vcyber on 2018/1/23.
//  Copyright © 2018年 vcyber. All rights reserved.
//

#import "FSBarChartView.h"
#import "FSBarChartViewCell.h"
#import "UIView+FSFrame.h"

@interface FSDataLabelCell: UICollectionViewCell

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation FSDataLabelCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_textLabel];
    }
    return self;
}

@end


@interface FSBarChartView()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource> {
    UIEdgeInsets _insets;
    NSInteger _section;
    CGFloat _sectionWidth;
}

@property (nonatomic, strong, readwrite) UICollectionView *collectionView;

@property (nonatomic, strong, readwrite) UIView *abscissaAxis;
@property (nonatomic, strong, readwrite) UIView *ordinateAxis;

@property (nonatomic, strong) NSMutableArray<UIView *> *lineViews;
@property (nonatomic, strong) NSMutableArray<UILabel *> *noDataLabels;

@property (nonatomic, strong) UICollectionView *dataLabelCollectionView;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *sectionWidthCache;

@end

@implementation FSBarChartView

- (instancetype)initWithFrame:(CGRect)frame orientation:(FSBarChartViewOrientation)orientation
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:254 / 255.0 green:197 / 255.0 blue:52 / 255.0 alpha:1];
        self.layer.masksToBounds = YES;
        _orientation = orientation;
    }
    return self;
}

//MARK: -Overried

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:254 / 255.0 green:197 / 255.0 blue:52 / 255.0 alpha:1];
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame orientation:FSBarChartViewOrientationVertical];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor colorWithRed:254 / 255.0 green:197 / 255.0 blue:52 / 255.0 alpha:1];
    self.layer.masksToBounds = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _insets = [self fs_getContentInset];
    self.collectionView.frame = self.bounds;
    if (self.orientation == FSBarChartViewOrientationVertical) {
        self.dataLabelCollectionView.frame = CGRectMake(0, self.fs_height - _insets.bottom + self.abscissaAxis.fs_height, self.collectionView.fs_width, _insets.bottom - self.abscissaAxis.fs_height);
    }else {
        self.dataLabelCollectionView.frame = CGRectMake(0, 0, _insets.left - self.ordinateAxis.fs_width, self.collectionView.fs_height);
    }
    [self reloadData];
}

//MARK: Public Method

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerNib:nil forCellWithReuseIdentifier:identifier];
}

- (FSBarChartViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

- (void)reloadNonDataAxis {
    [self fs_setupNoDataAxis];
}

- (void)reloadData {
    [self fs_setupFrame];
    [self fs_setupNoDataAxis];
    [self fs_setupDataAxis];
    [self.collectionView reloadData];
}


- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    _section = indexPaths.firstObject.section;
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadItemsAtIndexPaths:indexPaths];
    }];
    NSMutableSet <NSNumber *> *sections = [NSMutableSet set];
    for (NSIndexPath *indexPath in indexPaths) {
        [sections addObject:@(indexPath.section)];
    }
    NSMutableArray<NSIndexPath *> *newIndexPaths = [NSMutableArray array];
    [sections enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:obj.integerValue];
        [newIndexPaths addObject:indexPath];
    }];
    [self.dataLabelCollectionView reloadItemsAtIndexPaths:newIndexPaths];
}

- (FSBarChartViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return (FSBarChartViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition {
    [self.collectionView selectItemAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
}
- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:animated];
}

//MARK: Private Method

- (void)fs_setupFrame {
    self.collectionView.contentInset = _insets;
    if (self.orientation == FSBarChartViewOrientationVertical) {
        if (self.collectionView.contentSize.width > self.fs_width) {
            self.abscissaAxis.frame = CGRectMake(0, self.fs_height - _insets.bottom - _insets.top, self.collectionView.contentSize.width + _insets.right, 1);
        }else {
            self.abscissaAxis.frame = CGRectMake(0, self.fs_height - _insets.bottom - _insets.top, self.fs_width, 1);
        }
        self.ordinateAxis.frame = CGRectMake(0, -_insets.top, 1, self.fs_height - _insets.bottom);
    }else {
        if (self.collectionView.contentSize.height > self.fs_height) {
            self.ordinateAxis.frame = CGRectMake(0, 0, 1, self.collectionView.contentSize.height + _insets.bottom);
        }else {
            self.ordinateAxis.frame = CGRectMake(0, 0, 1, self.fs_height - _insets.top);
        }
        self.abscissaAxis.frame = CGRectMake(0, 0, self.fs_width - _insets.left, 1);
    }
}

- (void)fs_setupNoDataAxis {
    for (UIView *lineView in self.lineViews) {
        [lineView removeFromSuperview];
    }
    for (UILabel *label in self.noDataLabels) {
        [label removeFromSuperview];
    }
    [self.lineViews removeAllObjects];
    [self.noDataLabels removeAllObjects];
    
    if (self.orientation == FSBarChartViewOrientationVertical) {
        NSInteger noDataSection = [self fs_getOrdinateAxisSectionCount];
        CGFloat lineStep = noDataSection > 1 ? (self.fs_height - _insets.bottom - _insets.top - self.abscissaAxis.fs_height) / (noDataSection - 1) : self.ordinateAxis.fs_height;
        for (int ySection = 0; ySection < noDataSection; ySection++) {
            UILabel *ySectionLabel = [self fs_getOrdinateAxisLabelForSection:ySection];
            UIView *yLineView = [self fs_getAbscissaAxisLineViewForSection:ySection];

            
            if (yLineView) {
                if (yLineView.fs_height < 1.0) {
                    yLineView.fs_height = 1.0;
                }
                yLineView.fs_width = self.abscissaAxis.fs_width;
                yLineView.fs_centerX = self.abscissaAxis.fs_centerX;
                yLineView.fs_centerY = self.ordinateAxis.fs_height + self.ordinateAxis.fs_y - lineStep * ySection;
                yLineView.layer.zPosition = -1.0;
                [self.collectionView addSubview:yLineView];
                [self.lineViews addObject:yLineView];
                if (ySection == 0) {
                    yLineView.backgroundColor = [UIColor clearColor];
                }
            }
            
            if (ySectionLabel) {
                if (!ySectionLabel.text || ySectionLabel.text.length == 0) {
                    continue;
                }
                if (CGSizeEqualToSize(CGSizeZero, ySectionLabel.frame.size)) {
                    CGSize textSize = [ySectionLabel.text sizeWithAttributes:@{NSFontAttributeName:ySectionLabel.font}];
                    ySectionLabel.fs_width = textSize.width;
                    ySectionLabel.fs_height = textSize.height;
                }
                ySectionLabel.fs_x = -ySectionLabel.fs_width - 2;
                ySectionLabel.fs_centerY = self.ordinateAxis.fs_height + self.ordinateAxis.fs_y - lineStep * ySection;
                [self.collectionView addSubview:ySectionLabel];
                [self.noDataLabels addObject:ySectionLabel];
            }
        }
    }else {
        NSInteger noDataSection = [self fs_getAbscissaAxisSectionCount];
        CGFloat lineStep = noDataSection > 1 ? (self.fs_width - _insets.left - _insets.right - self.ordinateAxis.fs_width) / (noDataSection - 1) : self.abscissaAxis.fs_width;
        for (int xSection = 0; xSection < noDataSection; xSection++) {
            UILabel *xSectionLabel = [self fs_getAbscissaAxisLabelForSection:xSection];
            UIView *xLineView = [self fs_getOrdinateAxisLineViewForSection:xSection];
            if (xLineView) {
                if (xLineView.fs_width < 1.0) {
                    xLineView.fs_width = 1.0;
                }
                xLineView.fs_height = self.ordinateAxis.fs_height;
                xLineView.fs_centerY = self.ordinateAxis.fs_centerY;
                xLineView.fs_centerX = self.ordinateAxis.fs_x + self.ordinateAxis.fs_width + lineStep * xSection;
                xLineView.layer.zPosition = -0.1;
                [self.collectionView addSubview:xLineView];
                [self.lineViews addObject:xLineView];
                if (xSection == 0) {
                    xLineView.backgroundColor = [UIColor clearColor];
                }
            }
            
            if (xSectionLabel) {
                if (!xSectionLabel.text || xSectionLabel.text.length == 0) {
                    continue;
                }
                if (CGSizeEqualToSize(CGSizeZero, xSectionLabel.frame.size)) {
                    CGSize textSize = [xSectionLabel.text sizeWithAttributes:@{NSFontAttributeName:xSectionLabel.font}];
                    xSectionLabel.fs_width = textSize.width;
                    xSectionLabel.fs_height = textSize.height;
                }
                xSectionLabel.fs_y = -xSectionLabel.fs_height - 2;
                xSectionLabel.fs_centerX = self.ordinateAxis.fs_x + self.ordinateAxis.fs_width + lineStep * xSection;
                [self.collectionView addSubview:xSectionLabel];
                [self.noDataLabels addObject:xSectionLabel];
            }
        }
    }
}


- (void)fs_setupDataAxis {
    if (self.orientation == FSBarChartViewOrientationVertical) {
        self.dataLabelCollectionView.contentInset = UIEdgeInsetsMake(0, _insets.left, 0, _insets.right);
    }else {
        self.dataLabelCollectionView.contentInset = UIEdgeInsetsMake(_insets.top, 0, _insets.bottom, 0);
    }
}

// MARK: -lazy Load

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        if (self.orientation == FSBarChartViewOrientationVertical) {
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.minimumLineSpacing = 0;
            layout.minimumInteritemSpacing = 0;
        }else {
            layout.minimumLineSpacing = 0;
            layout.minimumInteritemSpacing = 0;
        }
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = NO;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (UIView *)abscissaAxis {
    if (!_abscissaAxis) {
        _abscissaAxis = [[UIView alloc] init];
        _abscissaAxis.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self.collectionView addSubview:_abscissaAxis];
    }
    return _abscissaAxis;
}


- (UIView *)ordinateAxis {
    if (!_ordinateAxis) {
        _ordinateAxis = [[UIView alloc] init];
        _ordinateAxis.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self.collectionView addSubview:_ordinateAxis];
    }
    return _ordinateAxis;
}

- (NSMutableArray<UIView *> *)lineViews {
    if (!_lineViews) {
        _lineViews = [NSMutableArray array];
    }
    return _lineViews;
}

- (NSMutableArray<UILabel *> *)noDataLabels {
    if (!_noDataLabels) {
        _noDataLabels = [NSMutableArray array];
    }
    return _noDataLabels;
}

- (UICollectionView *)dataLabelCollectionView {
    if (!_dataLabelCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGRect frame = CGRectZero;
        if (self.orientation == FSBarChartViewOrientationVertical) {
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            frame = CGRectMake(0, self.fs_height - _insets.bottom + self.abscissaAxis.fs_height, self.collectionView.fs_width, _insets.bottom - self.abscissaAxis.fs_height);
        }else {
            frame = CGRectMake(0, 0, _insets.left - self.ordinateAxis.fs_width, self.collectionView.fs_height);
        }
        _dataLabelCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        _dataLabelCollectionView.backgroundColor = [UIColor clearColor];
        _dataLabelCollectionView.delegate = self;
        _dataLabelCollectionView.dataSource = self;
        _dataLabelCollectionView.showsVerticalScrollIndicator = NO;
        _dataLabelCollectionView.showsHorizontalScrollIndicator = NO;
        _dataLabelCollectionView.bounces = NO;
        if (@available(iOS 11.0, *)) {
            _dataLabelCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        [_dataLabelCollectionView registerClass:[FSDataLabelCell class] forCellWithReuseIdentifier:@"FSDataLabelCell"];
        [self addSubview:_dataLabelCollectionView];
    }
    return _dataLabelCollectionView;
}

- (NSMutableDictionary<NSNumber *,NSNumber *> *)sectionWidthCache {
    if (!_sectionWidthCache) {
        _sectionWidthCache = [NSMutableDictionary dictionary];
    }
    return _sectionWidthCache;
}

// MARK: -Call DataSource

- (NSInteger)fs_getAbscissaAxisSectionCount {
    return [self.dataSource numberOfSectionsInAbscissaAxisForBarChartView:self];
}

- (NSInteger)fs_getOrdinateAxisSectionCount {
    return [self.dataSource numberOfSectionsInOrdinateAxisForBarChartView:self];
}

- (__kindof FSBarChartViewCell *)fs_getCellAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource barChartView:self cellForItemAtIndexPath:indexPath];
}

- (NSInteger)fs_getAbscissaAxisItemCountOfSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(barChartView:numberOfItemAbscissaAxisInSection:)]) {
        return [self.dataSource barChartView:self numberOfItemAbscissaAxisInSection:section];
    }
    return 1;
}

- (NSInteger)fs_getOrdinateAxisItemCountOfSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(barChartView:numberOfItemOrdinateAxisInSection:)]) {
        return [self.dataSource barChartView:self numberOfItemOrdinateAxisInSection:section];
    }
    return 1;
}

// MARK: -Call Delegate
- (UIEdgeInsets)fs_getContentInset {
    if ([self.delegate respondsToSelector:@selector(contentInsetForBarChartView:)]) {
        return [self.delegate contentInsetForBarChartView:self];
    }
    return UIEdgeInsetsMake(20, 20, 20, 20);
}

- (CGFloat)fs_getSpaceForSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(barChartView:spaceForSection:)]) {
        return [self.delegate barChartView:self spaceForSection:section];
    }
    return 15;
}

- (CGFloat)fs_getItemLineWidthForIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(barChartView:lineWidthForItemAtIndexPath:)]) {
        return [self.delegate barChartView:self lineWidthForItemAtIndexPath:indexPath];
    }
    return 10;
}

- (UILabel *)fs_getOrdinateAxisLabelForSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(barChartView:ordinateAxisLableForSection:)]) {
        return [self.dataSource barChartView:self ordinateAxisLableForSection:section];
    }
    return nil;
}

- (UIView *)fs_getOrdinateAxisLineViewForSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(barChartView:ordinateAxisLineViewForSection:)]) {
        return [self.delegate barChartView:self ordinateAxisLineViewForSection:section];
    }
    return nil;
}

- (UILabel *)fs_getAbscissaAxisLabelForSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(barChartView:abscissaAxisLableForSection:)]) {
        return [self.dataSource barChartView:self abscissaAxisLableForSection:section];
    }
    return nil;
}

- (UIView *)fs_getAbscissaAxisLineViewForSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(barChartView:abscissaAxisLineViewForSection:)]) {
        return [self.delegate barChartView:self abscissaAxisLineViewForSection:section];
    }
    return nil;
}

// MARK: -UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.orientation == FSBarChartViewOrientationVertical) {
        return [self fs_getAbscissaAxisSectionCount];
    }
    return [self fs_getOrdinateAxisSectionCount];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.orientation == FSBarChartViewOrientationVertical) {
        if ([collectionView isEqual:self.collectionView]) {
            return [self fs_getAbscissaAxisItemCountOfSection:section];
        }else {
            return 1;
        }
    }else {
        if ([collectionView isEqual:self.collectionView]) {
            return [self fs_getOrdinateAxisItemCountOfSection:section];
        }else {
            return 1;
        }
    }
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.collectionView]) {
        return [self fs_getCellAtIndexPath:indexPath];
    }else {
        FSDataLabelCell *cell = (FSDataLabelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FSDataLabelCell" forIndexPath:indexPath];
        UILabel *label = nil;
        if (self.orientation == FSBarChartViewOrientationVertical) {
            label = [self fs_getAbscissaAxisLabelForSection:indexPath.section];
        }else {
            label = [self fs_getOrdinateAxisLabelForSection:indexPath.section];
        }
        if (!label || !label.text || label.text.length == 0 || label.hidden) {
            return (UICollectionViewCell *)cell;
        }
        cell.textLabel.text = label.text;
        cell.textLabel.font = label.font;
        cell.textLabel.textColor = label.textColor;
        cell.textLabel.shadowColor = label.shadowColor;
        cell.textLabel.shadowOffset = label.shadowOffset;
        cell.textLabel.lineBreakMode = label.lineBreakMode;
        cell.textLabel.attributedText = label.attributedText;
        cell.textLabel.numberOfLines = label.numberOfLines;
        cell.textLabel.hidden = label.hidden;
        cell.textLabel.highlighted = label.highlighted;
        cell.textLabel.highlightedTextColor = label.highlightedTextColor;
        cell.textLabel.userInteractionEnabled = label.userInteractionEnabled;
        
        CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
        if (self.orientation == FSBarChartViewOrientationVertical) {
            cell.textLabel.frame = CGRectMake((cell.fs_width - size.width) / 2, 2, size.width, size.height);
        }else {
            cell.textLabel.frame = CGRectMake(cell.fs_width - size.width - 2, (cell.fs_height - size.height) / 2, size.width, size.height);
        }
        
        return (UICollectionViewCell *)cell;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.orientation == FSBarChartViewOrientationVertical) {
        if (section == 0) {
            return UIEdgeInsetsMake(0, self.ordinateAxis.fs_width + [self fs_getSpaceForSection:section], 0, 0);
        }
        return UIEdgeInsetsMake(0, [self fs_getSpaceForSection:section], 0, 0);
    }else {
        if (section == 0) {
            return UIEdgeInsetsMake(self.abscissaAxis.fs_height + [self fs_getSpaceForSection:section], 0, 0, 0);
        }
            return UIEdgeInsetsMake([self fs_getSpaceForSection:section], 0, 0, 0);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.orientation == FSBarChartViewOrientationVertical) {
        if ([collectionView isEqual:self.collectionView]) {
            CGFloat width = [self fs_getItemLineWidthForIndexPath:indexPath];
            if (_section != indexPath.section) {
                [self.sectionWidthCache setObject:@(_sectionWidth) forKey:@(_section)];
                _sectionWidth = 0.0;
                _section = indexPath.section;
            }
            _sectionWidth += width;
            if (_section == [self fs_getAbscissaAxisSectionCount] - 1 && indexPath.item == [self fs_getAbscissaAxisItemCountOfSection:_section] - 1) {
                [self.sectionWidthCache setObject:@(_sectionWidth) forKey:@(_section)];
                _sectionWidth = 0.0;
                _section = 0;
                [self.dataLabelCollectionView reloadData];
            }
            return CGSizeMake(width, self.fs_height - _insets.bottom - _insets.top - self.abscissaAxis.fs_height);
        }else {
            return CGSizeMake([self.sectionWidthCache[@(indexPath.section)] floatValue], collectionView.fs_height);
        }
    }else {
        if ([collectionView isEqual:self.collectionView]) {
            CGFloat height = [self fs_getItemLineWidthForIndexPath:indexPath];
            if (_section != indexPath.section) {
                [self.sectionWidthCache setObject:@(_sectionWidth) forKey:@(_section)];
                _sectionWidth = 0.0;
                _section = indexPath.section;
            }
            _sectionWidth += height;
            if (_section == [self fs_getOrdinateAxisSectionCount] - 1 && indexPath.item == [self fs_getOrdinateAxisItemCountOfSection:_section] - 1) {
                [self.sectionWidthCache setObject:@(_sectionWidth) forKey:@(_section)];
                _sectionWidth = 0;
                _section = 0;
                [self.dataLabelCollectionView reloadData];
            }
            return CGSizeMake(self.fs_width - _insets.left - _insets.right - self.ordinateAxis.fs_width, height);
        }else {
            return CGSizeMake(collectionView.fs_width, self.sectionWidthCache[@(indexPath.section)].floatValue);
        }
    }
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(barChartView:shouldSelectItemAtIndexPath:)]) {
        return [self.delegate barChartView:self shouldSelectItemAtIndexPath:indexPath];
    }
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(barChartView:shouldDeselectItemAtIndexPath:)]) {
        return [self.delegate barChartView:self shouldDeselectItemAtIndexPath:indexPath];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(barChartView:didSelectItemAtIndexPath:)]) {
        [self.delegate barChartView:self didSelectItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(barChartView:didDeselectItemAtIndexPath:)]) {
        [self.delegate barChartView:self didDeselectItemAtIndexPath:indexPath];
    }
}

//MARK: UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGPoint offset = scrollView.contentOffset;
    if (self.orientation == FSBarChartViewOrientationVertical) {
        if (self.abscissaAxis.fs_width != scrollView.contentSize.width + _insets.right) {
            self.abscissaAxis.fs_width = scrollView.contentSize.width + _insets.right;
            for (UIView *lineView in self.lineViews) {
                lineView.fs_width = self.abscissaAxis.fs_width;
            }
        }
        if ([scrollView isEqual:self.collectionView]) {
            offset.y = 0;
            [self.dataLabelCollectionView setContentOffset:offset];
        }else {
            offset.y = -_insets.top;
            [self.collectionView setContentOffset:offset];
        }
    }else {
        if (self.ordinateAxis.fs_height != scrollView.contentSize.height + _insets.bottom) {
            self.ordinateAxis.fs_height = scrollView.contentSize.height + _insets.bottom;
            for (UIView *lineView in self.lineViews) {
                lineView.fs_height = self.ordinateAxis.fs_height;
            }
        }
        if ([scrollView isEqual:self.collectionView]) {
            offset.x = 0;
            [self.dataLabelCollectionView setContentOffset:offset];
        }else {
            offset.x = -_insets.left;
            [self.collectionView setContentOffset:offset];
        }
    }
}


- (void)dealloc {
    
}

@end

