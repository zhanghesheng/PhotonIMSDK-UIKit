//
//  UIImage+Extensions.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "UIImage+PhotonExtensions.h"

@implementation UIImage (PhotonExtensions)
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark -
- (UIImage *)grayImage {
    int width = self.size.width;
    int height = self.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,      // bits per component
                                                  0,
                                                  colorSpace,
                                                  kCGBitmapByteOrderDefault);
    
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) {
        return nil;
    }
    
    CGContextDrawImage(context,
                       CGRectMake(0, 0, width, height), self.CGImage);
    CGImageRef image = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    CGContextRelease(context);
    
    return grayImage;
}

//纯色图片
+ (UIImage *)imageWithColor:(UIColor *)color finalSize:(CGSize)size {
    return [UIImage imageWithColor:color finalSize:size cornerRadius:0];
}

+ (UIImage *)imageWithColor:(UIColor *)color
                  finalSize:(CGSize)size
               cornerRadius:(CGFloat)cornerRadius {
    return [UIImage imageWithColor:color
                         finalSize:size
                      cornerRadius:cornerRadius
                         lineWidth:0
                         lineColor:[UIColor blackColor]];
}

+ (UIImage *)imageWithColor:(UIColor *)color
                  finalSize:(CGSize)size
               cornerRadius:(CGFloat)cornerRadius
          byRoundingCorners:(UIRectCorner)corners {
    return [UIImage imageWithColor:color
                         finalSize:size
                      cornerRadius:cornerRadius
                         lineWidth:0
                         lineColor:[UIColor blackColor]
                   roundingCorners:corners];
}

+ (UIImage *)imageWithColor:(UIColor *)color
                  finalSize:(CGSize)size
               cornerRadius:(CGFloat)cornerRadius
                  lineWidth:(CGFloat)lineWidth
                  lineColor:(UIColor *)lineColor {
    return [UIImage imageWithColor:color
                         finalSize:size
                      cornerRadius:cornerRadius
                         lineWidth:lineWidth
                         lineColor:lineColor
                   roundingCorners:UIRectCornerAllCorners];
}

+ (UIImage *)imageWithColor:(UIColor *)color
                  finalSize:(CGSize)size
               cornerRadius:(CGFloat)cornerRadius
                  lineWidth:(CGFloat)lineWidth
                  lineColor:(UIColor *)lineColor
            roundingCorners:(UIRectCorner)cornerEnable {
    
    if (!color) {
        color = [UIColor clearColor];
    }
    
    if (!lineColor) {
        lineColor = [UIColor clearColor];
    }
    
    if (size.width <= 0 || size.height <= 0) {
        return nil;
    }
    
    UIImage *image = nil;
    
    CGFloat colorRed,colorGreen,colorBlue,colorAlpha;
    [color getRed:&colorRed green:&colorGreen blue:&colorBlue alpha:&colorAlpha];
    
    CGFloat lineColorRed,lineColorGreen,lineColorBlue,lineColorAlpha;
    [lineColor getRed:&lineColorRed green:&lineColorGreen blue:&lineColorBlue alpha:&lineColorAlpha];
    
    if (cornerRadius < 0) {
        cornerRadius = 0;
    }
    CGRect originRect = CGRectMake(0, 0, size.width, size.height);
    CGRect contentRect = CGRectInset(originRect, lineWidth/2, lineWidth/2);
    
    if (cornerRadius >= (contentRect.size.height / 2)) {
        image =  [self imageCircleRadiusWithColor:color finalSize:size cornerRadius:cornerRadius lineWidth:lineWidth lineColor:lineColor roundingCorners:cornerEnable];
    } else {
        image = [self imageUnCircleRadiusWithColor:color finalSize:size cornerRadius:cornerRadius lineWidth:lineWidth lineColor:lineColor roundingCorners:cornerEnable];
    }
    
    return image;
}

+ (UIImage *)imageUnCircleRadiusWithColor:(UIColor *)color
                                finalSize:(CGSize)size
                             cornerRadius:(CGFloat)cornerRadius
                                lineWidth:(CGFloat)lineWidth
                                lineColor:(UIColor *)lineColor
                          roundingCorners:(UIRectCorner)cornerEnable {
    CGRect originRect = CGRectMake(0, 0, size.width, size.height);
    CGRect contentRect = CGRectInset(originRect, lineWidth/2, lineWidth/2);
    UIGraphicsBeginImageContextWithOptions(originRect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (cornerRadius > (contentRect.size.height / 2)) {
        cornerRadius = contentRect.size.height / 2;
    }
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:contentRect byRoundingCorners:cornerEnable cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    path.lineWidth = lineWidth;
    //    [color setFill];
    //    [lineColor setStroke];
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextSetStrokeColorWithColor(ctx, lineColor.CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextAddPath(ctx, path.CGPath);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    if (!CGContextIsPathEmpty(ctx)) {
        CGContextClip(ctx);
    }
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)imageCircleRadiusWithColor:(UIColor *)color
                              finalSize:(CGSize)size
                           cornerRadius:(CGFloat)cornerRadius
                              lineWidth:(CGFloat)lineWidth
                              lineColor:(UIColor *)lineColor
                        roundingCorners:(UIRectCorner)cornerEnable {
    UIImage *img = nil;
    CGRect drawRect = CGRectMake(0, 0, size.width, size.height);
    CGFloat more = lineWidth/2.f;
    //如果border宽为0 设置宽度为2 颜色和背景色相同
    //圆角不圆的问题
    if (lineWidth == 0) {
        
    } else {
        if (more < 1) {
            more = 1;
        }
    }
    CGRect rect_inner = CGRectMake(more, more, size.width - more*2, size.height - more*2);
    if (cornerRadius > rect_inner.size.height/2) {
        cornerRadius = rect_inner.size.height/2;
    }
    if (cornerRadius > rect_inner.size.width/2) {
        cornerRadius = rect_inner.size.width/2;
    }
    //
    CGFloat topLeftCorner = 0;
    CGFloat topRightCorner = 0;
    CGFloat bottomLeftCorner = 0;
    CGFloat bottomRightCorner = 0;
    if (cornerEnable & UIRectCornerTopLeft) {
        topLeftCorner = cornerRadius;
    }
    if (cornerEnable & UIRectCornerTopRight) {
        topRightCorner = cornerRadius;
    }
    if (cornerEnable & UIRectCornerBottomLeft) {
        bottomLeftCorner = cornerRadius;
    }
    if (cornerEnable & UIRectCornerBottomRight) {
        bottomRightCorner = cornerRadius;
    }
    //
    CGPoint point1 = CGPointMake(rect_inner.origin.x, CGRectGetMaxY(rect_inner) - bottomLeftCorner);
    CGPoint point2 = CGPointMake(rect_inner.origin.x + topLeftCorner, rect_inner.origin.y);
    CGPoint point3 = CGPointMake(CGRectGetMaxX(rect_inner), rect_inner.origin.y + topRightCorner);
    CGPoint point4 = CGPointMake(CGRectGetMaxX(rect_inner) - bottomRightCorner, CGRectGetMaxY(rect_inner));
    
    UIGraphicsBeginImageContextWithOptions(drawRect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    //
    CGContextSetLineWidth(context, lineWidth);
    CGContextMoveToPoint(context, point1.x, point1.y);
    
    if (topLeftCorner == 0) {
        CGContextAddLineToPoint(context, point2.x - lineWidth/2, point2.y);
    } else {
        CGContextAddArcToPoint(context, rect_inner.origin.x, rect_inner.origin.y, point2.x, point2.y, topLeftCorner);
    }
    if (topRightCorner == 0) {
        CGContextAddLineToPoint(context, point3.x + lineWidth/2, point3.y);
    } else {
        CGContextAddArcToPoint(context, CGRectGetMaxX(rect_inner), rect_inner.origin.y, point3.x, point3.y, topRightCorner);
    }
    if (bottomRightCorner == 0) {
        CGContextAddLineToPoint(context, point4.x + lineWidth/2, point4.y);
    } else {
        CGContextAddArcToPoint(context, CGRectGetMaxX(rect_inner), CGRectGetMaxY(rect_inner), point4.x, point4.y, bottomRightCorner);
    }
    if (bottomLeftCorner == 0) {
        CGContextAddLineToPoint(context, point1.x - lineWidth/2, point1.y);
    } else {
        CGContextAddArcToPoint(context, rect_inner.origin.x, CGRectGetMaxY(rect_inner), point1.x, point1.y, bottomLeftCorner);
    }
    //
    CGContextDrawPath(context, kCGPathFillStroke);
    if (!CGContextIsPathEmpty(context)) {
        CGContextClip(context);
    }
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

//uiimage 缩放到Constrain 大小  多线程不安全
+ (UIImage *)imageConstrainInMB:(float)size withImage:(UIImage *)image
{
    //防止死循环，最多递归20次，但是用static 在多线程会有问题
    //现在没有多线程的应用场景，先简单处理
    static NSUInteger count = 0;
    NSData *data = UIImageJPEGRepresentation(image, 1.);
    if ([data length] / (1024. * 1024) > size && count < 20) {
        count++;
        UIImage *scaleImg = [self scaleImageWithSize:image scaleSize:CGSizeMake(0.8 * image.size.width, 0.8 * image.size.height)];
        return [self imageConstrainInMB:size withImage:scaleImg];
    } else {
        count = 0;
        return image;
    }
}

+ (UIImage *)scaleImageWithSize:(UIImage *)superImage scaleSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    [superImage drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}


@end
