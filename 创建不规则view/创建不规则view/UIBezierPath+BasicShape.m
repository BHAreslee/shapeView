//
//  UIBezierPath+BasicShape.m
//  创建不规则view
//
//  Created by LiBohan on 2017/3/24.
//  Copyright © 2017年 LiBohan. All rights reserved.
//

#import "UIBezierPath+BasicShape.h"

@implementation UIBezierPath (BasicShape)
+ (UIBezierPath *)cutCorner:(CGRect)originalFrame length:(CGFloat)length
{
    CGRect rect = originalFrame;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    [bezierPath moveToPoint:CGPointMake(0, length)];
    [bezierPath addLineToPoint:CGPointMake(length, 0)];
    [bezierPath addLineToPoint:CGPointMake(rect.size.width - length, 0)];
    [bezierPath addLineToPoint:CGPointMake(rect.size.width, length)];
    [bezierPath addLineToPoint:CGPointMake(rect.size.width, rect.size.height - length)];
    [bezierPath addLineToPoint:CGPointMake(rect.size.width - length, rect.size.height)];
    [bezierPath addLineToPoint:CGPointMake(length, rect.size.height)];
    [bezierPath addLineToPoint:CGPointMake(0, rect.size.height - length)];
    [bezierPath closePath];
    return bezierPath;
}

@end
