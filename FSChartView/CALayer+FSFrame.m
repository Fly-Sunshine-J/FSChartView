//
//  CALayer+FSFrame.m
//  FSChartView
//
//  Created by vcyber on 2018/1/18.
//  Copyright © 2018年 vcyber. All rights reserved.
//

#import "CALayer+FSFrame.h"

@implementation CALayer (FSFrame)

- (void)setFs_x:(CGFloat)fs_x {
    CGRect frame = self.frame;
    frame.origin.x = fs_x;
    self.frame = frame;
}


- (CGFloat)fs_x {
    return self.frame.origin.x;
}


- (void)setFs_y:(CGFloat)fs_y {
    CGRect frame = self.frame;
    frame.origin.y = fs_y;
    self.frame = frame;
}

- (CGFloat)fs_y {
    return self.frame.origin.y;
}

- (void)setFs_width:(CGFloat)fs_width {
    CGRect frame = self.frame;
    frame.size.width = fs_width;
    self.frame = frame;
}

- (CGFloat)fs_width {
    return self.frame.size.width;
}

- (void)setFs_height:(CGFloat)fs_height {
    CGRect frame = self.frame;
    frame.size.height = fs_height;
    self.frame = frame;
}

- (CGFloat)fs_height {
    return self.frame.size.height;
}

- (void)setFs_size:(CGSize)fs_size {
    CGRect frame = self.frame;
    frame.size = fs_size;
    self.frame = frame;
}

- (CGSize)fs_size {
    return self.frame.size;
}

- (void)setFs_origin:(CGPoint)fs_origin {
    CGRect frame = self.frame;
    frame.origin = fs_origin;
    self.frame = frame;
}

- (CGPoint)fs_origin {
    return self.frame.origin;
}

@end
