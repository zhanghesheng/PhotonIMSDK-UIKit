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
#import "NSString+PhotonExtensions.h"
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
    
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *atTypeString = [[NSMutableAttributedString alloc] init];
    if (conversation.atType == PhotonIMConversationAtTypeAtMe) {
        atTypeString = [[NSMutableAttributedString alloc] initWithString:@"有人@了我" attributes:@{NSForegroundColorAttributeName:(id)[UIColor redColor]}];
    }else if (conversation.atType == PhotonIMConversationTypeAtAll){
         atTypeString = [[NSMutableAttributedString alloc] initWithString:@"@所有人" attributes:@{NSForegroundColorAttributeName:(id)[UIColor redColor]}];
    }
    if (atTypeString) {
        [content appendAttributedString:atTypeString];
    }
    NSMutableAttributedString *chatContent;
    if(conversation.chatType == PhotonIMChatTypeGroup && conversation.lastMsgContent && conversation.lastMsgContent.length > 0){
         PhotonUser *user =  [PhotonContent friendDetailInfo:conversation.lastMsgFr];
         chatContent = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:%@",user.nickName,[conversation.lastMsgContent trim]] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:0x9B9B9B]}];
    }else{
        if(conversation.lastMsgContent){
             chatContent = [[NSMutableAttributedString alloc] initWithString:[conversation.lastMsgContent trim] attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:0x9B9B9B]}];
        }
       
    }
    if (chatContent) {
        [content appendAttributedString:chatContent];
    }
    self.contextLabel.attributedText = content;
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
    BOOL isSending = [conversation.lastMsgContent isNotEmpty] && (conversation.lastMsgStatus == PhotonIMMessageStatusSending);
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
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self p_layoutViews];
}

- (void)p_layoutViews{
    PhotonConversationItem *item = (PhotonConversationItem *)self.item;
    PhotonIMConversation *conversation = (PhotonIMConversation *)item.userInfo;
    
    CGRect contentFrame = self.contentView.frame;
    CGRect iconFrame = self.iconView.frame;
    iconFrame.size = CGSizeMake(56.0, 56.0);
    CGFloat iconY = (contentFrame.size.height - 56.0)/2.0;
    iconFrame.origin = CGPointMake(17.5, iconY);
    self.iconView.frame = iconFrame;
    
    // 时间
    CGSize size = [self.timeLabel sizeThatFits:CGSizeMake(PhotoScreenWidth, MAXFLOAT)];
    CGRect timeFrame = self.timeLabel.frame;
    timeFrame.size = CGSizeMake(size.width + 5.0,size.height);
    CGFloat timeX = contentFrame.size.width - (size.width + 5.0 + 15.0);
    timeFrame.origin = CGPointMake(timeX, 16.5);
    self.timeLabel.frame = timeFrame;
    
//    // 昵称
    size = [self.nickLabel sizeThatFits:CGSizeMake(PhotoScreenWidth, MAXFLOAT)];
    CGRect nickFrame = self.nickLabel.frame;
    nickFrame.size = size;
    CGFloat nickX = iconFrame.size.width + iconFrame.origin.x + 15.5;
    nickFrame.origin = CGPointMake(nickX, 21.0);
    self.nickLabel.frame = nickFrame;
    
    // 免打扰图标
    CGRect noalermFrame = self.noalermView.frame;
    if(conversation.ignoreAlert){
         noalermFrame.size = CGSizeMake(16, 11);
         CGFloat noalermX = nickFrame.size.width + nickFrame.origin.x + 1.0;
         CGFloat noalermY = nickFrame.origin.y + (nickFrame.size.height - size.height)/2.0;
         noalermFrame.origin = CGPointMake(noalermX, noalermY);
         self.noalermView.frame = noalermFrame;
    }else{
         self.noalermView.frame = CGRectZero;
    }
   
    // 未读数
    if(conversation.unReadCount > 0){
       size = [PhoneBadgeView badgeSizeWithValue:[@(conversation.unReadCount) stringValue]];
      
    }else{
       size = CGSizeZero;
    }
    CGRect badgeFrame = self.badgeView.frame;
    badgeFrame.size = size;
    CGFloat badgeY = timeFrame.size.height + timeFrame.origin.y + 5.0;
    CGFloat badgex =  contentFrame.size.width - (size.width + 21.8);
    badgeFrame.origin = CGPointMake(badgex, badgeY);
    self.badgeView.frame = badgeFrame;
    
    
    // 状态
    if (!self.sendStatusView.image && !self.indicatorView.animating) {
        size = CGSizeZero;
    }else{
        size = CGSizeMake(18.5, 18.5);
    }
    
    CGRect sendStatusFrame = self.sendStatusView.frame;
    CGFloat sendStatusY = nickFrame.size.height + nickFrame.origin.y + 2.5;
    CGFloat sendStatusX = nickFrame.origin.x;
    sendStatusFrame.size = size;
    sendStatusFrame.origin = CGPointMake(sendStatusX, sendStatusY);
    self.sendStatusView.frame = sendStatusFrame;
    
    CGRect indicatorFrame = self.indicatorView.frame;
    indicatorFrame.size = CGSizeMake(12, 12);
    indicatorFrame.origin = CGPointMake(3.0, 3.0);
    self.indicatorView.frame = indicatorFrame;
    
    
    CGRect contextFrame = self.sendStatusView.frame;
    CGFloat contextY = nickFrame.size.height + nickFrame.origin.y + 1.5;
    CGFloat contextX = sendStatusFrame.size.width + sendStatusFrame.origin.x;
    CGFloat contextHeight = 18.5;
    CGFloat contextWidth = contentFrame.size.width - (contextX + badgeFrame.size.width + 21.8);
    contextFrame.size = CGSizeMake(contextWidth, contextHeight);
    contextFrame.origin = CGPointMake(contextX, contextY);
    self.contextLabel.frame = contextFrame;
    
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
