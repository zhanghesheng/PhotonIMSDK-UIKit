//
//  PontonTalkButton.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PontonTalkButton.h"
#import <Masonry/Masonry.h>
#import "PhotonMacros.h"
@interface PontonTalkButton ()
@property (nonatomic, copy) void (^touchBegin)(void);
@property (nonatomic, copy) void (^touchMove)(BOOL cancel);
@property (nonatomic, copy) void (^touchCancel)(void);
@property (nonatomic, copy) void (^touchEnd)(void);
@end

@implementation PontonTalkButton

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setNormalTitle:@"按住 说话"];
        [self setHighlightTitle:@"松开 发送"];
        [self setCancelTitle:@"松开 取消"];
        [self setHighlightColor:[UIColor colorWithHex:0xD2D2D2]];
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:5.0f];
        [self.layer setBorderWidth:BORDER_WIDTH_1PX];
        [self.layer setBorderColor:[UIColor colorWithHex:0xD2D2D2].CGColor];
        
        [self addSubview:self.titleLabel];
        [self p_addMasonry];
    }
    return self;
}

#pragma mark - # Public Methods
- (void)setTouchBeginAction:(void (^)(void))touchBegin
      willTouchCancelAction:(void (^)(BOOL cancel))willTouchCancel
             touchEndAction:(void (^)(void))touchEnd
          touchCancelAction:(void (^)(void))touchCancel
{
    self.touchBegin = [touchBegin copy];
    self.touchMove = [willTouchCancel copy];
    self.touchCancel= [touchCancel copy];
    self.touchEnd = [touchEnd copy];
}

#pragma mark - # Event Response
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setBackgroundColor:self.highlightColor];
    [self.titleLabel setText:self.highlightTitle];
    if (self.touchBegin) {
        self.touchBegin();
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.touchMove) {
        CGPoint curPoint = [[touches anyObject] locationInView:self];
        BOOL moveIn = curPoint.x >= 0 && curPoint.x <= self.width && curPoint.y >= 0 && curPoint.y <= self.height;
        [self.titleLabel setText:(moveIn ? self.highlightTitle : self.cancelTitle)];
        self.touchMove(!moveIn);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setText:self.normalTitle];
    CGPoint curPoint = [[touches anyObject] locationInView:self];
    BOOL moveIn = curPoint.x >= 0 && curPoint.x <= self.width && curPoint.y >= 0 && curPoint.y <= self.height;
    if (moveIn && self.touchEnd) {
        self.touchEnd();
    }
    else if (!moveIn && self.touchCancel) {
        self.touchCancel();
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setText:self.normalTitle];
    if (self.touchCancel) {
        self.touchCancel();
    }
}

#pragma mark - # Private Methods
- (void)p_addMasonry
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

#pragma mark - # Getter
- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_titleLabel setTextColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setText:self.normalTitle];
    }
    return _titleLabel;
}

@end
