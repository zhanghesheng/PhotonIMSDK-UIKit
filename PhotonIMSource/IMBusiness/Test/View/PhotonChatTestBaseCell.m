//
//  PhotonConversationBaseCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/26.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonChatTestBaseCell.h"
#import "PhotonMessageCenter.h"
#import "PhotonChatTestItem.h"
#import "PhoneBadgeView.h"
#import "NSString+PhotonExtensions.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface PhotonChatTestBaseCell()
@property (nonatomic, strong, nullable) UIImageView *iconView;
@property (nonatomic, strong, nullable) UILabel *nickLabel;
@property (nonatomic, strong, nullable) UILabel *contextLabel;


@property (nonatomic, strong, nullable)UIButton *startChatBtn;
@property (nonatomic, strong, nullable)UIButton *clearBtn;
@end

@implementation PhotonChatTestBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.nickLabel];
        [self.contentView addSubview:self.contextLabel];
        [self.contentView addSubview:self.startChatBtn];
        [self.contentView addSubview:self.clearBtn];
    }
    return self;
}

- (void)setObject:(id)object{
    [super setObject:object];
    if (!self.item) {
        return;
    }
    PhotonChatTestItem *item = (PhotonChatTestItem *)object;
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
    
    if (item.isStartChat) {
         [_startChatBtn setTitle:@"停止" forState:UIControlStateNormal];
    }else{
         [_startChatBtn setTitle:@"开始" forState:UIControlStateNormal];
    }
    
    
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
    BOOL isSending = [conversation.lastMsgContent isNotEmpty] && (conversation.lastMsgStatus == PhotonIMMessageStatusSending);
    BOOL isSentFailed = [conversation.lastMsgContent isNotEmpty] && (conversation.lastMsgStatus == PhotonIMMessageStatusFailed);
    if (!conversation.lastMsgIsReceived) {
        isSending = NO;
        isSentFailed = NO;
    }
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self p_layoutViews];
}

- (void)p_layoutViews{
    PhotonChatTestItem *item = (PhotonChatTestItem *)self.item;
    PhotonIMConversation *conversation = (PhotonIMConversation *)item.userInfo;
    // 头像
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(56, 56));
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(17.5);
    }];
    
    
    // 昵称
    CGSize size = [self.nickLabel sizeThatFits:CGSizeMake(PhotoScreenWidth, MAXFLOAT)];
    [self.nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(21);
        make.left.mas_equalTo(self.iconView.mas_right).mas_offset(15.5);
    }];
    
    [self.nickLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
    }];
   
    if(conversation.unReadCount > 0){
        size = [PhoneBadgeView badgeSizeWithValue:[@(conversation.unReadCount) stringValue]];
    }else{
        size =CGSizeZero;
    }
    
    [self.startChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(55);
        make.top.mas_equalTo(self.contentView).mas_offset(5);
        make.right.mas_equalTo(self.contentView).mas_offset(-5);
    }];
    
    
    [self.clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           make.height.mas_equalTo(30);
           make.width.mas_equalTo(55);
           make.bottom.mas_equalTo(self.contentView).mas_offset(-5);
           make.right.mas_equalTo(self.contentView).mas_offset(-5);
    }];
           
    [self.contextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(18.5);
        make.top.mas_equalTo(self.nickLabel.mas_bottom).mas_offset(1.5);
        make.left.mas_equalTo(self.nickLabel.mas_left).mas_offset(0);
        make.right.mas_equalTo(self.clearBtn.mas_left).mas_equalTo(-5);
    }];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)didSelectIcon:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(conCell:didSelectAvatar:)]) {
         PhotonChatTestItem *item = (PhotonChatTestItem *)self.item;
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




+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    PhotonChatTestItem *item = (PhotonChatTestItem *)object;
    return [item itemHeight];
}

+ (NSString *)cellIdentifier{
    return @"PhotonChatTestBaseCell";
}

- (UIButton *)startChatBtn{
    if (!_startChatBtn) {
        _startChatBtn= [UIButton buttonWithType:UIButtonTypeCustom];
        [_startChatBtn setTitle:@"开始" forState:UIControlStateNormal];
        [_startChatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_startChatBtn setBackgroundColor:[UIColor colorWithHex:0x41b6e6] forState:UIControlStateNormal];
        [_startChatBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        _startChatBtn.layer.cornerRadius = 5;
        [_startChatBtn addTarget:self action:@selector(startChat:) forControlEvents:UIControlEventTouchUpInside];
    }
      return _startChatBtn;
}
-(UIButton *)clearBtn{
    if (!_clearBtn) {
           _clearBtn= [UIButton buttonWithType:UIButtonTypeCustom];
           [_clearBtn setTitle:@"清空" forState:UIControlStateNormal];
           [_clearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
           [_clearBtn setBackgroundColor:[UIColor colorWithHex:0x41b6e6] forState:UIControlStateNormal];
           [_clearBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
           _clearBtn.layer.cornerRadius = 5;
           [_clearBtn addTarget:self action:@selector(clearData:) forControlEvents:UIControlEventTouchUpInside];
       }
         return _clearBtn;
}

- (void)startChat:(id)sender{
    PhotonChatTestItem *item = (PhotonChatTestItem *)self.item;
    item.isStartChat = !item.isStartChat;
    if (item.isStartChat) {
           [_startChatBtn setTitle:@"停止" forState:UIControlStateNormal];
      }else{
           [_startChatBtn setTitle:@"开始" forState:UIControlStateNormal];
      }
    if(self.delegate && [self.delegate respondsToSelector:@selector(startChatCell:startChat:)]){
        [self.delegate startChatCell:self startChat:item];
    }
}

- (void)clearData:(id)sender{
    PhotonChatTestItem *item = (PhotonChatTestItem *)self.item;
    if(self.delegate && [self.delegate respondsToSelector:@selector(clearChatCell:clearData:)]){
        [self.delegate clearChatCell:self clearData:item];
    }
}

@end
