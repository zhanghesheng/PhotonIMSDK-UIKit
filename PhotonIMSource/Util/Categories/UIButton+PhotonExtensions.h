//
//  UIButton+Extensions.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PhotonButtonImagePosition) {
    PhotonButtonImagePositionLeft = 0,              //图片在左，文字在右，默认
    PhotonButtonImagePositionRight = 1,             //图片在右，文字在左
    PhotonButtonImagePositionTop = 2,               //图片在上，文字在下
    PhotonButtonImagePositionBottom = 3,            //图片在下，文字在上
};
@interface UIButton(PhotonExtensions)
/**
 *  设置Button的背景色
 */
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

/**
 *  快捷设置图片
 */
- (void)setImage:(UIImage *)image imageHighlight:(UIImage *)imageHL;


/**
 *  image和title图文混排
 *
 *  @param  position    图片的位置，默认left
 *  @param  spacing     图片和标题的间隔
 *
 *  @return     返回button最小的size
 *
 *  注意，需要先设置好image、title、font。网络图片需要下载完成后再调用此方法，或设置同大小的placeholder
 */
- (CGSize)setButtonImagePosition:(PhotonButtonImagePosition)position spacing:(CGFloat)spacing;
@end

NS_ASSUME_NONNULL_END
