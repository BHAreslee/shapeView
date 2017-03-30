//
//  ViewController.m
//  创建不规则view
//
//  Created by LiBohan on 2017/3/24.
//  Copyright © 2017年 LiBohan. All rights reserved.
//

#import "ViewController.h"
#import "UIView+shape.h"
#import "UIImage+ImageEffects.h"
#import <float.h>

#import "FXBlurView.h"
#import <objc/runtime.h>
#import "bhView.h"

@interface ViewController ()


@property (nonatomic, strong) UIView *ggview;

@property (nonatomic, strong) UIImageView *imgView;


@end

@implementation ViewController


-(UIImageView *)imgView{
    
    if (_imgView == nil) {
        
        _imgView = [[UIImageView alloc]init];
        
    }
    
    return _imgView;
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    
    path1.lineWidth = 1;
    
    path1.lineCapStyle = kCGLineCapRound;
    
    path1.lineJoinStyle = kCGLineJoinRound;
    
    //画左眉
    CGPoint p1 = CGPointMake(100, 100);
    
    CGPoint p2 = CGPointMake(300, 100);
    
    CGPoint p3 = CGPointMake(300, 300);
    
    [path1 moveToPoint:p1];
    
    [path1 addLineToPoint:p2];
    
    [path1 addLineToPoint:p3];
    
    [path1 closePath];
    
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    
    //画右眉
    CGPoint p4 = CGPointMake(0, 100);
    
    CGPoint p5 = CGPointMake(80, 90);
    
    CGPoint p6 = CGPointMake(100, 300);
    
    [path2 moveToPoint:p4];
    
    [path2 addLineToPoint:p5];
    
    [path2 addLineToPoint:p6];
    
    [path2 closePath];
    
    
//    ty.jpeg
    self.imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"timg.jpeg"]];
    
    [self.view addSubview:self.imgView];
    
    self.imgView.frame = self.view.bounds;

    
    
    UIImageView *imgViewBlur = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"timg.jpeg"]];
    
    imgViewBlur.frame = self.view.bounds;
    
//    [self.view addSubview:imgViewBlur];
    
//    [self.view addSubview:self.ggview];
    
//    self.ggview.backgroundColor = [UIColor redColor];
    
//    [self.ggview setShape:path.CGPath];
    
    
    
//    UIView *v1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 5)];
//    
//    UIView *v2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 5)];
//    
//    UIView *v3 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 5)];
//    
//    v1.backgroundColor = [UIColor blueColor];
//    
//    v2.backgroundColor = [UIColor blueColor];
//    
//    v3.backgroundColor = [UIColor blueColor];
//    
//    [self.view addSubview:v1];
//    
//    [self.view addSubview:v2];
//    
//    [self.view addSubview:v3];
//    
//    v1.center = p1;
//    
//    v2.center = p2;
//    
//    v3.center = p3;
    
    //只显示path1区域的图像
    [path1 appendPath:path2];
    
//    [imgViewBlur setShape:path1.CGPath];
    
    imgViewBlur.image = [self blurryImage:imgViewBlur.image withBlurLevel:1];
    
    
    
    
    
    
    //将临时图片和原图合为一张
    /////////////////////////开启上下文
//    UIGraphicsBeginImageContext(self.imgView.bounds.size);
//    
//    [self.imgView.image drawInRect:self.view.bounds];
//    
//    [imgViewBlur.image drawInRect:self.view.bounds];
//    
//    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
    //////////////////关闭上下文///////////////////////////
    //将对眉毛区域处理完毕的图片赋值给self.imageView.image
//    self.imgView.image = resultingImage;
    
    
    bhView *bh = [[bhView alloc]initWithFrame:self.view.bounds];
    
    bh.backgroundColor = [UIColor clearColor];
    
    bh.img = imgViewBlur.image;
    
    [bh setNeedsDisplay];
    
//    [self.view addSubview:bh];
    
    [bh setShape:path1.CGPath];
    
    
    ////
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    
    UIGraphicsBeginImageContext(size);
    
    [self.imgView.image drawInRect:self.imgView.frame];
    
    [[self convertViewToImage:bh] drawInRect:bh.frame];
    
    UIImage *ZImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    self.imgView.image = ZImage;
    
    
//    UIImage *imgaa = ZImage;
//    
//    UIImageView *haimgView = [[UIImageView alloc]initWithImage:imgaa];
//    
//    haimgView.frame = self.view.bounds;
//    
//    [self.view addSubview:haimgView];
    
    
}





- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur
{
    if (image==nil)
    {
        NSLog(@"error:为图片添加模糊效果时，未能获取原始图片");
        return nil;
    }
    //模糊度,
    if (blur < 0.025f) {
        blur = 0.025f;
    } else if (blur > 1.0f) {
        blur = 1.0f;
    }
    
    //boxSize必须大于0
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    NSLog(@"boxSize:%i",boxSize);
    //图像处理
    CGImageRef img = image.CGImage;
    //需要引入#import <Accelerate/Accelerate.h>
    
    //图像缓存,输入缓存，输出缓存
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    //像素缓存
    void *pixelBuffer;
    
    //数据源提供者，Defines an opaque type that supplies Quartz with data.
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    // provider’s data.
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    //宽，高，字节/行，data
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //像数缓存，字节行*图片高
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    // 第三个中间的缓存区,抗锯齿的效果
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    //Convolves a region of interest within an ARGB8888 source image by an implicit M x N kernel that has the effect of a box filter.
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    //    NSLog(@"字节组成部分：%zu",CGImageGetBitsPerComponent(img));
    //颜色空间DeviceRGB
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //用图片创建上下文,CGImageGetBitsPerComponent(img),7,8
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    //根据上下文，处理过的图片，重新组件
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    //CGColorSpaceRelease(colorSpace);   //多余的释放
    CGImageRelease(imageRef);
    return returnImage;
}


-(UIImage*)convertViewToImage:(UIView*)v{
    CGSize s = v.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [v.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
