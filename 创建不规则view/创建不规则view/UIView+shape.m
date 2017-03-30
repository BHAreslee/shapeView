//
//  UIView+shape.m
//  创建不规则view
//
//  Created by LiBohan on 2017/3/24.
//  Copyright © 2017年 LiBohan. All rights reserved.
//

#import "UIView+shape.h"

@implementation UIView (shape)


- (void)setShape:(CGPathRef)shape
{
    if (shape == nil) {
        self.layer.mask = nil;
    }
    
    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    maskLayer.path = shape;
    self.layer.mask = maskLayer;
}



@end
