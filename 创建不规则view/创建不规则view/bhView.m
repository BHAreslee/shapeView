//
//  bhView.m
//  创建不规则view
//
//  Created by LiBohan on 2017/3/25.
//  Copyright © 2017年 LiBohan. All rights reserved.
//

#import "bhView.h"

@implementation bhView



- (void)drawRect:(CGRect)rect {
    
    self.backgroundColor = [UIColor clearColor];
    
    [self.img drawInRect:rect];
    
}


@end
