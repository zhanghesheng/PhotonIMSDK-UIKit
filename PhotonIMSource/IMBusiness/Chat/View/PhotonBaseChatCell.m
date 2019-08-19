//
//  PhotonBaseChatCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseChatCell.h"
#import "PhotonMessageCenter.h"
#import <SDWebImage/UIButton+WebCache.h>
@interface PhotonBaseChatCell()
/**
 头像
 */
@property (nonatomic, strong, nullable)UIButton *avatarBtn;

/**
 发送状态显示，失败显示，成功不显示
 */
@property (nonatomic, strong, nullable)UIButton *sendStateBtn;

/**
 时间
 */
@property (nonatomic, strong, nullable)UILabel  *timeLabel;

/**
 系统提示
 */
@property (nonatomic, strong, nullable)UILabel  *tipLable;

/**
 已读显示
 */
@property (nonatomic, strong, nullable)UILabel  *msgStatusLable;

/**
 文字背景
 */
@property (nonatomic, strong, nullable)UIImageView *contentBackgroundView;

@property (nonatomic, strong, nullable)UIActivityIndicatorView *indicatorView;


@end

@implementation PhotonBaseChatCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithHex:0XF3F3F3];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.avatarBtn];
        [self.contentView addSubview:self.sendStateBtn];
        [self.contentView addSubview:self.contentBackgroundView];
        [self.contentView addSubview:self.tipLable];
        [self.contentView addSubview:self.msgStatusLable];
        [self.contentView addSubview:self.timeLabel];
        
        [self p_layoutSubviews];
    }
    return self;
}
- (void)prepareForReuse{
    [super prepareForReuse];
    self.tipLable.text = nil;
    self.msgStatusLable.text = nil;
    self.timeLabel.text = nil;
}

- (void)setObject:(id)object{
    [super setObject:object];
    if (!self.item) {
        return;
    }
    PhotonBaseChatItem *item = (PhotonBaseChatItem *)object;
    
    self.lineLayer.hidden = YES;
    
    if (item.fromType == PhotonChatMessageFromSelf) {
        [self.contentBackgroundView setImage:[UIImage imageWithColor:[UIColor colorWithHex:0x3D82FF]]];
    }
    else if (item.fromType== PhotonChatMessageFromFriend){
       [self.contentBackgroundView setImage:[UIImage imageWithColor:[UIColor colorWithHex:0xFFFFFF]]];
    }
    
    [self.avatarBtn sd_setImageWithURL:[NSURL URLWithString:item.avatalarImgaeURL] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"tabbar_meHL"]];
    
    if (item.showTime) {
        [self.timeLabel setText:item.timeText];
    }else{
        [self.timeLabel setText:nil];
    }
    // 时间
    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(item.showTime ? TIMELABEL_HEIGHT : 0);
        make.width.mas_equalTo(item.showTime ? 200 : 0);
        make.top.mas_equalTo(self.contentView).mas_offset(item.showTime ? TIMELABEL_SPACE_Y : 0);
        make.centerX.mas_equalTo(self.contentView);
    }];
    // 头像
    [self.avatarBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.mas_equalTo(AVATAR_WIDTH);
        if (item.showTime) {
            make.top.mas_equalTo(self.timeLabel.mas_bottom).mas_offset(AVATAR_SPACE_Y);
        }else{
            make.top.mas_equalTo(self.contentView).mas_offset(AVATAR_SPACE_Y);
        }
        
        if(item.fromType == PhotonChatMessageFromSelf) {
            make.right.mas_equalTo(self.contentView).mas_offset(-AVATAR_SPACE_X);
        }else {
            make.left.mas_equalTo(self.contentView).mas_offset(AVATAR_SPACE_X);
        }
    }];
    
    // 背景
    [self.contentBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        item.fromType == PhotonChatMessageFromSelf ? make.right.mas_equalTo(self.avatarBtn.mas_left).mas_offset(-MSGBG_SPACE_X) : make.left.mas_equalTo(self.avatarBtn.mas_right).mas_offset(MSGBG_SPACE_X);
        make.top.mas_equalTo(self.avatarBtn.mas_top);
    }];
    
    PhotonIMMessage *message = [item userInfo];
    if (item.fromType == PhotonChatMessageFromSelf)
    {
        // 发送中转小菊花
        if (message.messageStatus == PhotonIMMessageStatusSending || message.messageStatus == PhotonIMMessageStatusDefault){
            [self.contentView addSubview:self.indicatorView];
            self.indicatorView.hidden = NO;
            [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(20, 20));
                make.centerY.mas_equalTo(self.contentBackgroundView.mas_centerY);
                make.right.mas_equalTo(self.contentBackgroundView.mas_left).mas_offset(-5);
            }];
            [self.indicatorView startAnimating];
        }else{
            self.indicatorView.hidden = YES;
        }
        
        // 发送失败显示小红叹号
        if (message.messageStatus == PhotonIMMessageStatusFailed ) {
            self.sendStateBtn.hidden = NO;
            [self.sendStateBtn setImage:[UIImage imageNamed:@"send_error"] forState:UIControlStateNormal];
            [self.sendStateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(21, 21));
                make.centerY.mas_equalTo(self.contentBackgroundView.mas_centerY);
                make.right.mas_equalTo(self.contentBackgroundView.mas_left).mas_offset(-6);
            }];
        }else{
             self.sendStateBtn.hidden = YES;
        }
        
        // 状态布局（已读，已发送）
        [self.msgStatusLable mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentBackgroundView.mas_bottom);
            make.right.mas_equalTo(self.contentBackgroundView.mas_left).mas_offset(-5.5);
        }];
        
        NSString *readStateText = @"";
        if(message.messageStatus == PhotonIMMessageStatusSucceed){
            readStateText = @"已发送";
        }
        if(message.messageStatus == PhotonIMMessageStatusSentRead){
            readStateText = @"已读";
        }
        
        self.msgStatusLable.text = readStateText;
        
        // 已发送显示已发送文案
        if (self.msgStatusLable.text.length > 0) {
            // 背景
            CGSize size = [self.msgStatusLable sizeThatFits:CGSizeMake(PhotoScreenWidth, MAXFLOAT)];
            [self.msgStatusLable mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(20);
                make.width.mas_equalTo(size.width + 10);
            }];
        }else{
            [self.msgStatusLable mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeZero);
            }];
        }
        
        
        [self.tipLable mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentBackgroundView.mas_bottom).mas_equalTo(TIPLABEL_SPACE_Y);
            make.right.mas_equalTo(self.contentBackgroundView.mas_right);
        }];
        
         
        if ([item.tipText isNotEmpty]) {
            // 背景
            self.tipLable.text = item.tipText;
            CGSize size = [self.tipLable sizeThatFits:CGSizeMake(40, 20)];
            CGFloat tip_width = size.width + 22;
            if (tip_width + AVATAR_WIDTH + AVATAR_SPACE_X + MSGBG_SPACE_X > PhotoScreenWidth) {
                [self.tipLable setFont:[UIFont systemFontOfSize:11.0f]];
                tip_width = PhotoScreenWidth - (AVATAR_WIDTH + AVATAR_SPACE_X + MSGBG_SPACE_X + 10);
            }
            [self.tipLable mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(TIPLABEL_HEIGHT);
                make.width.mas_equalTo(tip_width);
            }];
        }else{
            self.tipLable.text = nil;
            [self.tipLable mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeZero);
            }];
        }
    }else if(item.fromType == PhotonChatMessageFromFriend){
        self.indicatorView.hidden = YES;
        self.sendStateBtn.hidden = YES;
        [self.msgStatusLable mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeZero);
        }];
        [self.tipLable mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeZero);
        }];
        
    }
}
- (void)p_layoutSubviews{
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).mas_offset(TIMELABEL_SPACE_Y);
        make.centerX.mas_equalTo(self.contentView);
    }];
    
    [self.avatarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).mas_offset(-AVATAR_SPACE_X);
        make.width.and.height.mas_equalTo(AVATAR_WIDTH);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).mas_offset(AVATAR_SPACE_Y);
    }];
    
    [self.contentBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.avatarBtn.mas_left).mas_offset(-MSGBG_SPACE_X);
        make.top.mas_equalTo(self.avatarBtn.mas_top);
    }];
    
    [self.msgStatusLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentBackgroundView.right).mas_offset(-MSGBG_SPACE_X);
        make.top.mas_equalTo(self.contentBackgroundView.mas_bottom);
    }];
    
    [self.tipLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentBackgroundView.mas_bottom).mas_equalTo(TIPLABEL_SPACE_Y);
        make.right.mas_equalTo(self.contentBackgroundView.mas_right);
    }];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    
}

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    PhotonBaseChatItem *item = (PhotonBaseChatItem *)object;
    return item.itemHeight;
}


#pragma mark --------- Action ----------
- (void)avatarBtnAction:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatCell:didSelectAvatar:)]) {
        [self.delegate chatCell:self didSelectAvatar:self.item];
    }
}

- (void)sendStateBtnAction:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatCell:resendChatMessage:)]) {
        [self.delegate chatCell:self resendChatMessage:self.item];
    }
}

- (void)longPressBGView:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chatCell: chatMessageCellLongPress:rect:)]) {
        CGRect rect = self.contentBackgroundView.frame;
        rect.size.height -= 10;
        rect.origin.y += 10;
        [_delegate chatCell:self chatMessageCellLongPress:self.item rect:rect];
    }
}

- (void)tapBackgroundView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatCell:chatMessageCellTap:)]) {
        [self.delegate chatCell:self chatMessageCellTap:self.item];
    }
}

#pragma mark ------- getter ---------
- (UIButton *)avatarBtn{
    if (!_avatarBtn) {
        _avatarBtn = [[UIButton alloc] init];
        [_avatarBtn.layer setMasksToBounds:YES];
        _avatarBtn.layer.cornerRadius = 5;
        _avatarBtn.clipsToBounds = YES;
        [_avatarBtn.layer setBorderColor:[UIColor colorWithWhite:0.7 alpha:1.0].CGColor];
        [_avatarBtn addTarget:self action:@selector(avatarBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _avatarBtn;
}

- (UIButton *)sendStateBtn{
    if (!_sendStateBtn) {
        _sendStateBtn = [[UIButton alloc] init];
        _sendStateBtn.hidden = YES;
        [_sendStateBtn addTarget:self action:@selector(sendStateBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendStateBtn;
}

- (UIImageView *)contentBackgroundView{
    if (!_contentBackgroundView) {
        _contentBackgroundView = [[UIImageView alloc] init];
        [_contentBackgroundView setUserInteractionEnabled:YES];
        _contentBackgroundView.layer.cornerRadius = 5;
        self.contentBackgroundView.clipsToBounds = YES;
        UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressBGView:)];
        [_contentBackgroundView addGestureRecognizer:longPressGR];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundView)];
        [_contentBackgroundView addGestureRecognizer:tap];
    }
    return _contentBackgroundView;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [_timeLabel setTextColor:[UIColor colorWithHex:0x9D9D9D]];
        [_timeLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _timeLabel;
}

- (UILabel *)tipLable{
    if (!_tipLable) {
        _tipLable = [[UILabel alloc] init];
        [_tipLable setFont:[UIFont systemFontOfSize:12.0f]];
        [_tipLable setTextColor:[UIColor colorWithHex:0x777777]];
        [_tipLable setBackgroundColor:[UIColor colorWithHex:0xDADADA]];
        [_tipLable setTextAlignment:NSTextAlignmentCenter];
        [_tipLable.layer setMasksToBounds:YES];
        [_tipLable.layer setCornerRadius:5.0f];
    }
    return _tipLable;
}

- (UILabel *)msgStatusLable{
    if (!_msgStatusLable) {
        _msgStatusLable = [[UILabel alloc] init];
        [_msgStatusLable setFont:[UIFont systemFontOfSize:11.0f]];
        [_msgStatusLable setTextColor:[UIColor colorWithHex:0x9D9D9D]];
        [_msgStatusLable setTextAlignment:NSTextAlignmentCenter];
    }
    return _msgStatusLable;
}

- (UIActivityIndicatorView *)indicatorView{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _indicatorView;
}


#pragma mark -------- Identifier ---------
+ (NSString *) cellIdentifier{
    return @"PhotonBaseChatCell";
}
@end
