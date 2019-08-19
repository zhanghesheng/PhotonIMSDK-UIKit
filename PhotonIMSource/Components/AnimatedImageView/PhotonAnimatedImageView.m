//
//  PhotonAnimatedImageView.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonAnimatedImageView.h"
#import "PhotonMacros.h"
@interface PhotonAnimatedImageView()
@property (nonatomic ,strong, nullable) CADisplayLink                     *displayLink;
@property (nonatomic ,assign) BOOL                              shouldAnimate;
@property (nonatomic ,copy, nullable) AnimationFinishedBlock              animationFinishedBlock;
@property (nonatomic ,assign) NSInteger                         localRepeatCount;
@property (nonatomic ,assign) NSUInteger                        currentCount;
@end

@implementation PhotonAnimatedImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc
{
    [_displayLink invalidate];
    _displayLink = nil;
    _animateImages = nil;
}

#pragma mark - Public
- (void)startAnimating
{
    if(self.delay > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(self.animateImages.count){
                if (!self.displayLink){
                    __weak typeof(self)weakSelf = self;
                    self.displayLink = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(displayDidRefresh:)];
                    if (@available(iOS 10.0, *)) {
                        self.displayLink.preferredFramesPerSecond = self.framesPerSecond;
                    } else {
                        // Fallback on earlier versions
                    }
                    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                    self.displayLink.paused = YES;
                }
                self.displayLink.paused = NO;
                self.localRepeatCount = self.repeatCount;
            }else{
                [super startAnimating];
            }
        });
    }else{
        if(self.animateImages.count){
            if (!self.displayLink){
                __weak typeof(self)weakSelf = self;
                self.displayLink = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(displayDidRefresh:)];
                if (@available(iOS 10.0, *)) {
                    self.displayLink.preferredFramesPerSecond = self.framesPerSecond;
                } else {
                    // Fallback on earlier versions
                }
                [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
                self.displayLink.paused = YES;
            }
            self.displayLink.paused = NO;
            self.localRepeatCount = self.repeatCount;
        }else{
            [super startAnimating];
        }
    }
}

- (void)pauseAnimating
{
    if (self.animateImages.count) {
        self.displayLink.paused = YES;
    }else{
        [super stopAnimating];
    }
    if(self.animationFinishedBlock){
        self.animationFinishedBlock(YES);
    }
    
    [self analyzeAnimationImage];
}

- (void)stopAnimating
{
    if (self.animateImages.count) {
        self.currentCount = 0;
        self.displayLink.paused = YES;
    }else{
        [super stopAnimating];
    }
    if(self.animationFinishedBlock){
        self.animationFinishedBlock(YES);
    }
}

- (void)animationFinishedBlock:(AnimationFinishedBlock)block
{
    _animationFinishedBlock = [block copy];
}

#pragma mark - Private
- (BOOL)shouldAnimate
{
    return (self.window && self.superview && self.animateImages.count && ([UIApplication sharedApplication].applicationState == UIApplicationStateActive));
}

- (void)displayDidRefresh:(CADisplayLink *)displayLink
{
    if(!self.shouldAnimate){
        return;
    }
    
    [self analyzeAnimationImage];
    
    [self checkCurrentLoopNumber];
}

- (void)checkCurrentLoopNumber
{
    self.currentCount ++;
    if(self.currentCount >= self.animateImages.count){
        self.currentCount = 0;
        if(self.localRepeatCount >= 1){
            if(self.localRepeatCount == 1){
                [self stopAnimating];
            }else{
                self.localRepeatCount --;
            }
        }
    }
}

- (void)analyzeAnimationImage{
    id animationImage = [self.animateImages objectAtIndex:self.currentCount];
    if ([animationImage isKindOfClass:[UIImage class]]){
        self.image = (UIImage *)animationImage;
    }
    else if ([animationImage isKindOfClass:[NSString class]]){
        NSString *imageString = (NSString *)animationImage;
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageString ofType:nil];
        if([imagePath isNotEmpty]){
            self.image = [UIImage imageWithContentsOfFile:imagePath];
        }
    }
    else if ([animationImage isKindOfClass:[NSData class]]){
        self.image = [UIImage imageWithData:(NSData *)animationImage];
    }
}

#pragma mark - lazy
//默认60bps
- (NSUInteger)framesPerSecond {
    if(!_framesPerSecond){
        _framesPerSecond = 60;
    }
    return _framesPerSecond;
}

@end
