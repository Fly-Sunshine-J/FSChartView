//
//  CALayer+FSFrame.h
//  FSChartView
//
//  Created by vcyber on 2018/1/18.
//  Copyright © 2018年 vcyber. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (FSFrame)

@property (nonatomic, assign) CGFloat fs_x;
@property (nonatomic, assign) CGFloat fs_y;
@property (nonatomic, assign) CGFloat fs_width;
@property (nonatomic, assign) CGFloat fs_height;
@property (nonatomic, assign) CGSize fs_size;
@property (nonatomic, assign) CGPoint fs_origin;

@end
