//
//  PhotonAnimatedImageView.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^AnimationFinishedBlock)(BOOL finished);
@interface PhotonAnimatedImageView : UIImageView
//图片容器数组，格式可以是NSString,UIImage,NSData
@property (nonatomic ,strong, nullable) NSArray           *animateImages;
//frameInterval等同CADisplayLink的frameInterval
@property (nonatomic ,assign) NSUInteger        framesPerSecond;
//repeatCount 等同UIImageView的repeatCount
@property (nonatomic ,assign) NSInteger         repeatCount;
//delay  动画延时执行，默认为0
@property (nonatomic ,assign) CGFloat           delay;

//开始播放
- (void)startAnimating;
//停止播放，回到初始第一帧
- (void)stopAnimating;
//暂停播放，待在当前帧
- (void)pauseAnimating;

- (void)animationFinishedBlock:(AnimationFinishedBlock)block;
@end

NS_ASSUME_NONNULL_END
