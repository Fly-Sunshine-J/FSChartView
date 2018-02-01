//
//  UIView+FSFrame.m
//  FSPageControllerExample
//
//  Created by vcyber on 2018/1/3.
//  Copyright © 2018年 vcyber. All rights reserved.
//

#import "UIView+FSFrame.h"

@implementation UIView (FSFrame)

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

- (void)setFs_centerX:(CGFloat)fs_centerX {
    CGPoint center = self.center;
    center.x = fs_centerX;
    self.center = center;
}

- (CGFloat)fs_centerX {
    return self.center.x;
}

- (void)setFs_centerY:(CGFloat)fs_centerY {
    CGPoint center = self.center;
    center.y = fs_centerY;
    self.center = center;
}

- (CGFloat)fs_centerY {
    return self.center.y;
}

@end
