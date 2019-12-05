//
//  PhotonVoiceMessageChatCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonVoiceMessageChatCell.h"
#import "PhotonAnimatedImageView.h"
#import "PhotonVoiceMessageChatItem.h"
@interface PhotonVoiceMessageChatCell()
@property (nonatomic, strong, nullable)PhotonAnimatedImageView *voiceView;
@property (nonatomic, strong, nullable)UILabel *durationLabel;
@property (nonatomic, strong, nullable)UIView *redDoteView;
@property (nonatomic, assign) BOOL isDoingAnimation;
@end

@implementation PhotonVoiceMessageChatCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self.contentBackgroundView addSubview:self.voiceView];
        [self.contentBackgroundView addSubview:self.durationLabel];
        [self.contentView addSubview:self.redDoteView];
    }
    return self;
}

- (void)setObject:(id)object{
    [super setObject:object];
    if (!self.item) {
        return;
    }
    PhotonVoiceMessageChatItem *item = (PhotonVoiceMessageChatItem *)object;
    CGFloat duration = item.duration;
    self.durationLabel.text = [NSString stringWithFormat:@"%ld \"",lround(duration)];
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.durationLabel.text = nil;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    PhotonVoiceMessageChatItem *item = (PhotonVoiceMessageChatItem *)self.item;
    CGFloat duration = item.duration;
    CGFloat bgViewWidth = 90 + (duration * (150.0f/60.0f));
    CGFloat maxWidth = PhotoScreenWidth - (AVATAR_WIDTH + AVATAR_SPACE_X + MSGBG_SPACE_X + 100);
    if (bgViewWidth > maxWidth) {
        bgViewWidth = maxWidth;
    }
    PhotonChatMessageFromType fromType = item.fromType;
    CGSize bgViewSize = CGSizeMake(bgViewWidth, 44);
    CGRect contentBackgroundViewFrame = self.contentBackgroundView.frame;
    contentBackgroundViewFrame.size = bgViewSize;
    CGFloat contentBackgroundViewLeft = 0;
    if (item.fromType == PhotonChatMessageFromSelf) {
        contentBackgroundViewLeft = contentBackgroundViewFrame.origin.x-contentBackgroundViewFrame.size.width;
    }else{
        contentBackgroundViewLeft = contentBackgroundViewFrame.origin.x;
    }
    contentBackgroundViewFrame.origin.x = contentBackgroundViewLeft;
    self.contentBackgroundView.frame = contentBackgroundViewFrame;
    
    
    
    if (fromType == PhotonChatMessageFromSelf) {
        CGFloat voiceViewHeight  = contentBackgroundViewFrame.size.height;
        CGFloat voiceViewWidth = 40;
        CGFloat voiceViewTop = 0;
        CGFloat voiceViewLeft = contentBackgroundViewFrame.size.width - 10 - voiceViewWidth;
        CGRect voiceViewFrame = CGRectMake(voiceViewLeft, voiceViewTop, voiceViewWidth, voiceViewHeight);
        self.voiceView.frame = voiceViewFrame;
        
        CGFloat durationLabelHeight  = contentBackgroundViewFrame.size.height;
        CGFloat durationLabelWidth = contentBackgroundViewFrame.size.width - voiceViewWidth - 10 - 5;
        CGFloat durationLabelTop = 0;
        CGFloat durationLabelLeft = 0;
        CGRect durationLabelFrame = CGRectMake(durationLabelLeft, durationLabelTop, durationLabelWidth, durationLabelHeight);
        self.durationLabel.frame = durationLabelFrame;
    }else if(fromType == PhotonChatMessageFromFriend){
        CGFloat voiceViewHeight  = contentBackgroundViewFrame.size.height;
        CGFloat voiceViewWidth = 40;
        CGFloat voiceViewTop = 0;
        CGFloat voiceViewLeft = 10;
        CGRect voiceViewFrame = CGRectMake(voiceViewLeft, voiceViewTop, voiceViewWidth, voiceViewHeight);
        self.voiceView.frame = voiceViewFrame;

        
        CGFloat durationLabelHeight  = contentBackgroundViewFrame.size.height;
        CGFloat durationLabelWidth = contentBackgroundViewFrame.size.width - voiceViewWidth - 10 - 5;
        CGFloat durationLabelTop = 0;
        CGFloat durationLabelLeft = voiceViewLeft + voiceViewWidth + 5;
        CGRect durationLabelFrame = CGRectMake(durationLabelLeft, durationLabelTop, durationLabelWidth, durationLabelHeight);
        self.durationLabel.frame = durationLabelFrame;
        
        if (!item.isPlayed && !self.redDoteView.hidden) {
            CGFloat redDoteViewHeight  = 10;
            CGFloat redDoteViewWidth = 10;
            CGFloat redDoteViewTop = self.contentBackgroundView.center.y - redDoteViewHeight/2.0;
            CGFloat redDoteViewLeft = contentBackgroundViewFrame.origin.x + contentBackgroundViewFrame.size.width  + 5;
            CGRect redDoteViewFrame = CGRectMake(redDoteViewLeft, redDoteViewTop, redDoteViewWidth, redDoteViewHeight);
            self.redDoteView.frame = redDoteViewFrame;
        }
    }
    
    [self subview_layout];
}

- (void)tapBackgroundView{
    [super tapBackgroundView];
    if (!self.redDoteView.hidden) {
        self.redDoteView.hidden = YES;
    }
    _isDoingAnimation = !_isDoingAnimation;
    if (_isDoingAnimation) {
        [self startAudioAnimating];
    } else {
        [self stopAudioAnimating];
    }
    
}
- (void)startAudioAnimating{
    [self.voiceView startAnimating];
}
- (void)stopAudioAnimating
{
    [self.voiceView stopAnimating];
    _isDoingAnimation = NO;
    self.voiceView.image = [UIImage imageNamed:@"chat_voice_pause"];
}

#pragma mark -------- Getter ----------
- (PhotonAnimatedImageView *)voiceView
{
    if (!_voiceView) {
        _voiceView = [[PhotonAnimatedImageView alloc] initWithFrame:CGRectZero];
        _voiceView.image = [UIImage imageNamed:@"chat_voice_pause"];
        _voiceView.contentMode = UIViewContentModeCenter;
        [_voiceView setUserInteractionEnabled:NO];
        _voiceView.framesPerSecond = 30;
        _voiceView.repeatCount = 0;
        NSMutableArray *imageArr = [NSMutableArray arrayWithCapacity:0];
        for (NSInteger i = 0; i < 11; i++) {
            NSString *imageString = [NSString stringWithFormat:@"icon_chat_audio_playstatus_%@@2x.png",@(i)];
            [imageArr addObject:imageString];
        }
        _voiceView.animateImages = imageArr;
    }
    return _voiceView;
}

- (UIView *)redDoteView{
    if (!_redDoteView) {
        _redDoteView = [[UIView alloc] init];
        _redDoteView.layer.cornerRadius = 5;
        _redDoteView.clipsToBounds = YES;
        _redDoteView.backgroundColor = [UIColor redColor];
    }
    return _redDoteView;
}

- (UILabel *)durationLabel
{
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _durationLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        _durationLabel.textColor = [UIColor blackColor];
        [_durationLabel setUserInteractionEnabled:NO];
    }
    return _durationLabel;
}
+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    PhotonVoiceMessageChatItem *item = (PhotonVoiceMessageChatItem *)object;
    return item.itemHeight;
}

+ (NSString *)cellIdentifier{
    return @"PhotonVoiceMessageChatCell";
}

@end
