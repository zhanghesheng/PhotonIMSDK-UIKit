//
//  PhotonConversationBaseCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/26.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonConversationBaseCell.h"
#import "PhotonMessageCenter.h"
#import "PhotonConversationItem.h"
#import "PhoneBadgeView.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface PhotonConversationBaseCell()
@property (nonatomic, strong, nullable) UIImageView *iconView;
@property (nonatomic, strong, nullable) UILabel *nickLabel;
@property (nonatomic, strong, nullable) UILabel *timeLabel;
@property (nonatomic, strong, nullable) UILabel *contextLabel;
@property (nonatomic, strong, nullable) PhoneBadgeView *badgeView;
@property (nonatomic, strong, nullable) UIImageView *noalermView;

@property (nonatomic, strong, nullable)UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong, nullable)UIImageView *sendStatusView;
@end

@implementation PhotonConversationBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.nickLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.contextLabel];
        [self.contentView addSubview:self.badgeView];
        [self.contentView addSubview:self.sendStatusView];
        [self.sendStatusView addSubview:self.indicatorView];
        [self.contentView addSubview:self.noalermView];
    }
    return self;
}

- (void)setObject:(id)object{
    [super setObject:object];
    if (!self.item) {
        return;
    }
    PhotonConversationItem *item = (PhotonConversationItem *)object;
    PhotonIMConversation *conversation = (PhotonIMConversation *)item.userInfo;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:conversation.FAvatarPath] placeholderImage:[UIImage imageWithColor:RGBAColor(0, 0, 0, 0.6)]];
    
    NSString *nickName = @"";
    if ([conversation.FName isNotEmpty]) {
        nickName = conversation.FName;
        if (nickName.length > 15) {
            nickName = [NSString stringWithFormat:@"%@...",[nickName substringWithRange:NSMakeRange(0, 14)]];
        }
    }else{
        nickName = conversation.chatWith;
    }
    self.nickLabel.text = nickName;
     self.contextLabel.text = conversation.lastMsgContent;
    if([conversation.lastMsgContent isNotEmpty]){
        NSTimeInterval tempTimeStamp = (conversation.lastTimeStamp/1000.0);
        NSDate *localeDate = [NSDate dateWithTimeIntervalSince1970:tempTimeStamp];
        self.timeLabel.text = [localeDate chatTimeInfo];
    }else{
         self.timeLabel.text = @"";
    }
    NSInteger count = conversation.unReadCount;
    if (count > 0) {
        if (count > 0) {
            NSString *valueStr = [NSString stringWithFormat:@"%@",@(count)];
//            if (count > 99) {
//                count = 99;
//                valueStr = [NSString stringWithFormat:@"%@+",@(count)];
//            }
        [self.badgeView setBadgeValue:valueStr];
        }
    }
    BOOL isSending = [conversation.lastMsgContent isNotEmpty] && (conversation.lastMsgStatus == PhotonIMMessageStatusSending || conversation.lastMsgStatus == PhotonIMMessageStatusDefault);
    BOOL isSentFailed = [conversation.lastMsgContent isNotEmpty] && (conversation.lastMsgStatus == PhotonIMMessageStatusFailed);
    if (!conversation.lastMsgIsReceived) {
        isSending = NO;
        isSentFailed = NO;
    }
    if (isSentFailed) {
        [self.sendStatusView setImage:[UIImage imageNamed:@"send_error"]];
    }else{
        [self.sendStatusView setImage:nil];
    }
    // 发送中
    if (isSending) {
        self.indicatorView.hidden = NO;
        [self.indicatorView startAnimating];
    }else{
        [self.indicatorView stopAnimating];
    }
    [self p_layoutViews];
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)p_layoutViews{
    PhotonConversationItem *item = (PhotonConversationItem *)self.item;
    PhotonIMConversation *conversation = (PhotonIMConversation *)item.userInfo;
    // 头像
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(56, 56));
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(17.5);
    }];
    // 时间
   
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(16.5);
        make.right.mas_equalTo(self.contentView).mas_equalTo(-15);
    }];
    
     CGSize size = [self.timeLabel sizeThatFits:CGSizeMake(PhotoScreenWidth, MAXFLOAT)];
    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(size.height);
        make.width.mas_equalTo(size.width + 5);
    }];
    
    // 昵称
    size = [self.nickLabel sizeThatFits:CGSizeMake(PhotoScreenWidth, MAXFLOAT)];
    [self.nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(21);
        make.left.mas_equalTo(self.iconView.mas_right).mas_offset(15.5);
    }];
    
    [self.nickLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
    }];
    
    // 秒打扰图标
    [self.noalermView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nickLabel.mas_centerY);
        make.left.mas_equalTo(self.nickLabel.mas_right).mas_offset(5);
    }];
    if(conversation.ignoreAlert){
        [self.noalermView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(16, 11));
        }];
    }else{
        [self.noalermView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeZero);
        }];
    }
   
    if(conversation.unReadCount > 0){
        size = [PhoneBadgeView badgeSizeWithValue:[@(conversation.unReadCount) stringValue]];
    }else{
        size =CGSizeZero;
    }
    [self.badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).mas_offset(5);
        make.right.mas_equalTo(self.contentView.mas_right).mas_offset(-21.8);
    }];
    
    [self.badgeView mas_updateConstraints:^(MASConstraintMaker *make) {
         make.size.mas_equalTo(size);
    }];
    
    
    [self.sendStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.mas_equalTo(self.nickLabel.mas_bottom).mas_offset(1.5);
       make.left.mas_equalTo(self.nickLabel.mas_left);
    }];
   
    [self.contextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(18.5);
        make.top.mas_equalTo(self.nickLabel.mas_bottom).mas_offset(1.5);
        make.left.mas_equalTo(self.sendStatusView.mas_right).mas_offset(0);
        make.right.mas_equalTo(self.badgeView.mas_left).mas_equalTo(-5);
    }];
    if (!self.sendStatusView.image && !self.indicatorView.animating) {
        [self.sendStatusView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
            make.width.mas_equalTo(0);
        }];
    }else{
        [self.sendStatusView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(18.5);
            make.width.mas_equalTo(18.5);
        }];
    }
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(12);
        make.left.mas_equalTo(self.sendStatusView).mas_offset(0);
        make.centerY.mas_equalTo(self.sendStatusView);
    }];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)didSelectIcon:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(conCell:didSelectAvatar:)]) {
         PhotonConversationItem *item = (PhotonConversationItem *)self.item;
        [self.delegate conCell:self didSelectAvatar:item];
    }
}

#pragma mark ---- Getter ------
- (UIImageView *)iconView{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.clipsToBounds = YES;
        _iconView.layer.cornerRadius = 16.0;
        _iconView.userInteractionEnabled = NO;
        _iconView.backgroundColor = [UIColor clearColor];
    }
    return _iconView;
}

- (UIImageView *)noalermView{
    if (!_noalermView) {
        _noalermView = [[UIImageView alloc] init];
        [_noalermView setImage:[UIImage imageNamed:@"noalerm"]];
        _noalermView.contentMode = UIViewContentModeScaleAspectFit;
        _noalermView.backgroundColor = [UIColor clearColor];
    }
    return _noalermView;
}

- (UILabel *)nickLabel{
    if (!_nickLabel) {
        _nickLabel = [[UILabel alloc] init];
        _nickLabel.textColor = [UIColor colorWithHex:0x000000];
        _nickLabel.textAlignment = NSTextAlignmentLeft;
        _nickLabel.font = [UIFont systemFontOfSize:15.0];
        [_nickLabel setNumberOfLines:1];
    }
    return _nickLabel;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor colorWithHex:0xBEBEBE];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.font = [UIFont systemFontOfSize:11.0];
        [_timeLabel setNumberOfLines:1];
    }
    return _timeLabel;
}

- (UILabel *)contextLabel{
    if (!_contextLabel) {
        _contextLabel = [[UILabel alloc] init];
        _contextLabel.textColor = [UIColor colorWithHex:0x9B9B9B];
        _contextLabel.textAlignment = NSTextAlignmentLeft;
        _contextLabel.font = [UIFont systemFontOfSize:13.0];
        [_contextLabel setNumberOfLines:1];
    }
    return _contextLabel;
}

- (PhoneBadgeView *)badgeView{
    if (!_badgeView) {
        _badgeView = [[PhoneBadgeView alloc] init];
        _badgeView.titleFont = [UIFont systemFontOfSize:12];
    }
    return _badgeView;
}

- (UIActivityIndicatorView *)indicatorView{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidden = YES;
    }
    return _indicatorView;
}

- (UIImageView *)sendStatusView{
    if (!_sendStatusView) {
        _sendStatusView = [[UIImageView alloc] init];
        _sendStatusView.backgroundColor = [UIColor clearColor];
    }
    return _sendStatusView;
}


+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    PhotonConversationItem *item = (PhotonConversationItem *)object;
    return [item itemHeight];
}

+ (NSString *)cellIdentifier{
    return @"PhotonConversationBaseCell";
}

@end
