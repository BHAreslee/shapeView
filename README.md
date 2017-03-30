# shapeView
不规则View
最近在开发的一个项目，要求对面部的眉毛位置进行模糊效果处理。大致分为三个步骤：1：获取眉毛区域的关键点。2：通过连接关键点获取一个封闭的区域。3：在这个封闭区域中增加高斯模糊效果。

目标效果：




每一个UIView之所以能够显示出来，其实是CALayer在起作用。两者就相当于是画布和画框的关系。UIView只负责在画布上画一幅画，但最终能否完整将一幅画展示出来，则是取决于CALayer的形状，也就是CALayer的frame。UIView主要是对显示内容的管理而 CALayer 主要侧重显示内容的绘制。

那如何获得一个不规则的View呢？或者说如何让一幅画只在不规则的区域中显示呢？UIView只能通过修改frame改变大小和位置，似乎没有方式去改变形状。这个时候我们可以调整画框即可。我们通过查看CALayer的相关属性，可以得知CALayer有个子类叫CAShapeLayer。这个CAShapeLayer中有一个属性是CGPathRef类的path。之前用过UIBezierPath，很快就想到这个path应该就是形状了。我们可以通过UIBezierPath连线得到。OK，思路有了我们来实现一下吧。

实现：

在控制器中首先添加一个属性@property (nonatomic, strong) UIImageView *imgView;

然后在viewDidLoad方法中，做一下几部：

1：创建UIBezierPath对象，并绘制左右眉毛的区域。我以简单的三角形替代眉毛的区域

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

//此时我们得到了两个path，我们用一个方法把他合为一个path。让path1包含path2。

[path1 appendPath:path2];

2.创建两个UIImageView，一个用来展示原图，一个用来做模糊效果

//self.imgView用来展示原图

self.imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"timg.jpeg"]];

[self.view addSubview:self.imgView];

self.imgView.frame = self.view.bounds;

//imgViewBlur用来模糊

UIImageView *imgViewBlur = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"timg.jpeg"]];

imgViewBlur.frame = self.view.bounds;

//模糊图片操作，方法blurryImage:withBlurLevel:会在后面列出

imgViewBlur.image = [self blurryImage:imgViewBlur.image withBlurLevel:1];

3.自定义一个bhView，继承自UIView，并添加一个属性@property (nonatomic, strong) UIImage *img，在控制器创建bhView对象时，传入img，给bhView中用drawRect方法绘制。

至于为什么要创建bhView，会在后面说明。

在bhView的.m文件中重写drawRect

- (void)drawRect:(CGRect)rect {

self.backgroundColor = [UIColor clearColor];

[self.img drawInRect:rect];

}
bhView *bh = [[bhView alloc]initWithFrame:self.view.bounds];

bh.backgroundColor = [UIColor clearColor];

bh.img = imgViewBlur.image;

//我们只能通过调用此方法，来触发drawRect方法。系统不让直接调用drawRect

[bh setNeedsDisplay];

//创建CAShapeLayer对象maskLayer

CAShapeLayer* maskLayer = [CAShapeLayer layer];

//把准备好的path1赋值给maskLayer.path的path属性

maskLayer.path = path1.CGPath;

//在将bhView的对象bh的layer设置为maskLayer

bh.layer.mask = maskLayer;

至此，我们已经得到了两张图，一张图是UIImageView展示出来的，一张图是通过bhView画出来的，模糊后并且只在特定区域显示。







接下来就要合并这两张图。

4：合并图片,通过上下文的方式将两个图片绘制在一起，生成一张新图片

CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);

//开启上下文

UIGraphicsBeginImageContext(size);

//先画完整的图片

[self.imgView.image drawInRect:self.imgView.frame];

//再画模糊的局部图片。convertViewToImage：方法实现会贴在后面

[[self convertViewToImage:bh] drawInRect:bh.frame];

//拿到生成的ZImage

UIImage *ZImage = UIGraphicsGetImageFromCurrentImageContext();

//关闭图形上下文

UIGraphicsEndImageContext();

//给展示图赋新图片

self.imgView.image = ZImage;

结束。看看最终效果




下面贴两个方法

//View转图片

-(UIImage*)convertViewToImage:(UIView*)v{

CGSize s = v.bounds.size;

// 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了

UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);

[v.layer renderInContext:UIGraphicsGetCurrentContext()];

UIImage*image = UIGraphicsGetImageFromCurrentImageContext();

UIGraphicsEndImageContext();

return image;

}

//模糊图片处理方法如下

- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur{    if (image==nil)    {        NSLog(@"error:为图片添加模糊效果时，未能获取原始图片");        return nil;    }    //模糊度,    if (blur < 0.025f) {        blur = 0.025f;    } else if (blur > 1.0f) {        blur = 1.0f;    }        //boxSize必须大于0    int boxSize = (int)(blur * 100);    boxSize -= (boxSize % 2) + 1;    NSLog(@"boxSize:%i",boxSize);    //图像处理    CGImageRef img = image.CGImage;    //需要引入#import//图像缓存,输入缓存，输出缓存

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

//CGColorSpaceRelease(colorSpace);  //多余的释放

CGImageRelease(imageRef);

return returnImage;

}


现在说明为什么药自定义bhView。我刚开始也是直接创建了两个UIImageView，一个是原图，一个模糊部分区域的图。然后在开上下文合并，发现结果得到的是一张全部模糊的图。

以下直接绘制是不行的：

UIGraphicsBeginImageContext(self.imgView.bounds.size);

[self.imgView.image drawInRect:self.view.bounds];

[imgViewBlur.image drawInRect:self.view.bounds];

UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();

UIGraphicsEndImageContext();

因为，在上下文中绘制的是imgViewBlur.imageimage对象，imgViewBlur.imageimage对象是没有形状的，虽然你只能看到两个模糊的三角形区域。但实际上整个imgViewBlur.image都被模糊了，因为layerd的关系，我们才看不到其他区域而已。

后来我想到，通过使用UIView的drawRect方法同样可以得到一张图片，再通过设置layer就能够只展现模糊的三角区域。再将bhView对象与UIImageView对象合并即可。

