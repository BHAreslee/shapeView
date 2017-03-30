//
//  UIBezierPath+BasicShape.h
//  创建不规则view
//
//  Created by LiBohan on 2017/3/24.
//  Copyright © 2017年 LiBohan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (BasicShape)
+ (UIBezierPath *)cutCorner:(CGRect)originalFrame length:(CGFloat)length;
@end
