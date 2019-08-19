//
//  UIImage+Extensions.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface UIImage (PhotonExtensions)
+ (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)imageWithColor:(UIColor *)color;
// 灰色图像
- (UIImage *)grayImage;

+ (UIImage *)imageWithColor:(UIColor *)color
                  finalSize:(CGSize)size;
////带圆角纯色图片
+ (UIImage *)imageWithColor:(UIColor *)color
                  finalSize:(CGSize)size
               cornerRadius:(CGFloat)cornerRadius;
//
+ (UIImage *)imageWithColor:(UIColor *)color
                  finalSize:(CGSize)size
               cornerRadius:(CGFloat)cornerRadius
          byRoundingCorners:(UIRectCorner)corners;
//
+ (UIImage *)imageWithColor:(UIColor *)color
                  finalSize:(CGSize)size
               cornerRadius:(CGFloat)cornerRadius
                  lineWidth:(CGFloat)lineWidth
                  lineColor:(UIColor *)lineColor;
//
+ (UIImage *)imageWithColor:(UIColor *)color
                  finalSize:(CGSize)size
               cornerRadius:(CGFloat)cornerRadius
                  lineWidth:(CGFloat)lineWidth
                  lineColor:(UIColor *)lineColor
            roundingCorners:(UIRectCorner)cornerEnable;

+ (UIImage *)imageConstrainInMB:(float)size withImage:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
