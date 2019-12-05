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
    if (item.fromType == PhotonChatMessageFromSelf) {
        self.textMessageLabel.textColor = [UIColor colorWithHex:0xFFFFFF];
    }
    else if (item.fromType== PhotonChatMessageFromFriend){
        self.textMessageLabel.textColor = [UIColor colorWithHex:0x272727];
    }
    
}
- (void) p_layoutSubviews{
    PhotonTextMessageChatItem *item = (PhotonTextMessageChatItem *)self.item;

    
    CGRect contentBackgroundViewFrame = self.contentBackgroundView.frame;
    contentBackgroundViewFrame.size = CGSizeMake(item.contentSize.width + MSG_SPACE_RIGHT + MSG_SPACE_LEFT, item.contentSize.height + MSG_SPACE_TOP + MSG_SPACE_BTM);
     CGFloat contentBackgroundViewLeft = 0;
    if (item.fromType == PhotonChatMessageFromSelf) {
        contentBackgroundViewLeft = contentBackgroundViewFrame.origin.x-contentBackgroundViewFrame.size.width;
    }else{
        contentBackgroundViewLeft = contentBackgroundViewFrame.origin.x;
    }
    contentBackgroundViewFrame.origin.x = contentBackgroundViewLeft;
    self.contentBackgroundView.frame = contentBackgroundViewFrame;
    
    CGRect textMessageLabelFrame = self.textMessageLabel.frame;
    textMessageLabelFrame.size = item.contentSize;
    CGFloat textMessageLabelTop =  contentBackgroundViewFrame.origin.y + MSG_SPACE_TOP;
    CGFloat textMessageLabelLeft = 0;
    if (item.fromType== PhotonChatMessageFromSelf) {
        textMessageLabelLeft = contentBackgroundViewFrame.origin.x + MSG_SPACE_RIGHT;
    }else{
        textMessageLabelLeft = contentBackgroundViewFrame.origin.x + MSG_SPACE_LEFT;
        
    }
    textMessageLabelFrame.origin = CGPointMake(textMessageLabelLeft, textMessageLabelTop);
    self.textMessageLabel.frame = textMessageLabelFrame;
   
    
}
- (void)layoutSubviews{
    [super layoutSubviews];
    [self p_layoutSubviews];
    [self subview_layout];
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
