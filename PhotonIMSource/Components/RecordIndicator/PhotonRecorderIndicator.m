//
//  PhotonRecorderIndicator.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/8.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonRecorderIndicator.h"
#import "PhotonMacros.h"

#define     STR_RECORDING       @"松开发送，上滑取消"
#define     STR_CANCEL          @"手指松开，取消发送"
#define     STR_REC_SHORT       @"时间太短"

@interface PhotonRecorderIndicator ()

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *titleBackgroundView;

@property (nonatomic, strong) UIImageView *recImageView;

@property (nonatomic, strong) UIImageView *centerImageView;

@property (nonatomic, strong) UIImageView *volumeImageView;

@end

@implementation PhotonRecorderIndicator

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backgroundView];
        [self addSubview:self.recImageView];
//        [self addSubview:self.volumeImageView];
        [self addSubview:self.centerImageView];
        [self addSubview:self.titleBackgroundView];
        [self addSubview:self.titleLabel];
        
        [self p_addMasonry];
    }
    return self;
}

- (void)setStatus:(PhotonRecorderStatus)status
{
    if (status == PhotonRecorderStatusWillCancel) {
        [self.centerImageView setHidden:YES];
        [self.centerImageView setImage:[UIImage imageNamed:@"chat_record_cancel"]];
        [self.titleBackgroundView setHidden:YES];
        [self.recImageView setImage:[UIImage imageNamed:@"warning_notice"]];
        [self.recImageView setHidden:NO];
        [self.volumeImageView setHidden:YES];
        [self.titleLabel setText:STR_CANCEL];
    }
    else if (status == PhotonRecorderStatusRecording) {
        [self.centerImageView setHidden:YES];
        [self.titleBackgroundView setHidden:YES];
        [self.recImageView setImage:[UIImage imageNamed:@"record_voice"]];
        [self.recImageView setHidden:NO];
        [self.volumeImageView setHidden:NO];
        [self.titleLabel setText:STR_RECORDING];
    }
    else if (status == PhotonRecorderStatusTooShort) {
//        [self.centerImageView setHidden:NO];
//        [self.centerImageView setImage:[UIImage imageNamed:@"chat_record_cancel"]];
//        [self.titleBackgroundView setHidden:YES];
        [self.recImageView setImage:[UIImage imageNamed:@"warning_notice"]];
        [self.recImageView setHidden:NO];
        [self.volumeImageView setHidden:YES];
        [self.titleLabel setText:STR_REC_SHORT];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (status == PhotonRecorderStatusTooShort) {
                [self removeFromSuperview];
            }
        });
    }
}

- (void)setVolume:(CGFloat)volume
{
    _volume = volume;
    NSInteger picId = 10 * (volume < 0 ? 0 : (volume > 1.0 ? 1.0 : volume));
    picId = picId > 8 ? 8 : picId;
    [self.volumeImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"chat_record_signal_%ld", (long)picId]]];
}

#pragma mark - # Private Methods
- (void)p_addMasonry
{
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.recImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.backgroundView.mas_centerX);
        make.centerY.mas_equalTo(self.backgroundView.mas_centerY).mas_offset(-10);
    }];
//    [self.volumeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.and.height.mas_equalTo(self.recImageView);
//        make.right.mas_equalTo(-21);
//    }];
    [self.centerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(15);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-25);
    }];
    [self.titleBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.titleLabel).mas_offset(UIEdgeInsetsMake(-2, -5, -2, -5)).priorityLow();
    }];
}

#pragma mark - # Getter
- (UIView *)backgroundView
{
    if (_backgroundView == nil) {
        _backgroundView = [[UIView alloc] init];
        [_backgroundView setBackgroundColor:[UIColor blackColor]];
        [_backgroundView setAlpha:0.6f];
        [_backgroundView.layer setMasksToBounds:YES];
        [_backgroundView.layer setCornerRadius:5.0f];
    }
    return _backgroundView;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular;" size:15]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setText:STR_RECORDING];
    }
    return _titleLabel;
}

- (UIView *)titleBackgroundView
{
    if (_titleBackgroundView == nil) {
        _titleBackgroundView = [[UIView alloc] init];
        [_titleBackgroundView setHidden:YES];
        [_titleBackgroundView setBackgroundColor:[UIColor redColor]];
        [_titleBackgroundView.layer setMasksToBounds:YES];
        [_titleBackgroundView.layer setCornerRadius:2.0f];
    }
    return _titleBackgroundView;
}

- (UIImageView *)recImageView
{
    if (_recImageView == nil) {
        _recImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"record_voice"]];
    }
    return _recImageView;
}

- (UIImageView *)centerImageView
{
    if (_centerImageView == nil) {
        _centerImageView = [[UIImageView alloc] init];
        [_centerImageView setHidden:YES];
    }
    return _centerImageView;
}

- (UIImageView *)volumeImageView
{
    if (_volumeImageView == nil) {
        _volumeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"record_voice"]];
    }
    return _volumeImageView;
}

@end
