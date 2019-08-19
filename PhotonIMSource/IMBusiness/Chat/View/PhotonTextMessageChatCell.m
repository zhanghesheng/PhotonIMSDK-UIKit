//
//  PhotonTextMessageChatCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonTextMessageChatCell.h"
#import "PhotonTextMessageChatItem.h"
@interface PhotonTextMessageChatCell()
@property(nonatomic, strong, nullable)UILabel  *textMessageLabel;
@end

@implementation PhotonTextMessageChatCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.textMessageLabel];
    }
    return self;
}

- (void)setObject:(id)object{
    [super setObject:object];
    if (!self.item) {
        return;
    }
    PhotonTextMessageChatItem *item = (PhotonTextMessageChatItem *)object;
    [self.textMessageLabel setAttributedText:item.messageAttriText];
    [self.textMessageLabel setContentCompressionResistancePriority:500 forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentBackgroundView setContentCompressionResistancePriority:100 forAxis:UILayoutConstraintAxisHorizontal];
    [self p_layoutSubviews];
}
- (void) p_layoutSubviews{
    PhotonTextMessageChatItem *item = (PhotonTextMessageChatItem *)self.item;
    if (item.fromType == PhotonChatMessageFromSelf) {
        self.textMessageLabel.textColor = [UIColor colorWithHex:0xFFFFFF];
        [self.textMessageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentBackgroundView).mas_offset(-MSG_SPACE_RIGHT);
            make.top.mas_equalTo(self.contentBackgroundView).mas_offset(MSG_SPACE_TOP);
        }];
        [self.contentBackgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.textMessageLabel).mas_offset(-MSG_SPACE_LEFT);
            make.bottom.mas_equalTo(self.textMessageLabel).mas_offset(MSG_SPACE_BTM);
        }];
    }
    else if (item.fromType== PhotonChatMessageFromFriend){
         self.textMessageLabel.textColor = [UIColor colorWithHex:0x272727];
        
        [self.textMessageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentBackgroundView).mas_offset(MSG_SPACE_LEFT);
            make.top.mas_equalTo(self.contentBackgroundView).mas_offset(MSG_SPACE_TOP);
        }];
        [self.contentBackgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.textMessageLabel).mas_offset(MSG_SPACE_RIGHT);
            make.bottom.mas_equalTo(self.textMessageLabel).mas_offset(MSG_SPACE_BTM);
        }];
    }
    [self.textMessageLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(item.contentSize);
    }];
    
    
}
- (void)layoutSubviews{
    [super layoutSubviews];
}
#pragma mark - Getter -
- (UILabel *)textMessageLabel
{
    if (_textMessageLabel == nil) {
        _textMessageLabel = [[UILabel alloc] init];
        [_textMessageLabel setFont:[UIFont systemFontOfSize:16.0]];
        [_textMessageLabel setNumberOfLines:0];
    }
    return _textMessageLabel;
}
+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    PhotonTextMessageChatItem *item = (PhotonTextMessageChatItem *)object;
    return item.itemHeight;
}

+ (NSString *)cellIdentifier{
    return @"PhotonTextMessageChatCell";
}
@end
