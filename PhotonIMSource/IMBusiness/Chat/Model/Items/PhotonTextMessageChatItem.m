//
//  PhotonTextMeesageChatItem.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonTextMessageChatItem.h"
#import "PhotonMacros.h"
@implementation PhotonTextMessageChatItem
- (NSAttributedString *)messageAttriText{
    if (!_messageAttriText) {
        _messageAttriText = [self.messageText toMessageString];
    }
    return _messageAttriText;
}
- (CGSize)contentSize{
    UILabel *textLabel = [[UILabel alloc] init];
    [textLabel setFont:[UIFont systemFontOfSize:16.0]];
    [textLabel setNumberOfLines:0];
    [textLabel setAttributedText:[self messageAttriText]];
    CGSize size = [textLabel sizeThatFits:CGSizeMake(PhotoScreenWidth * 0.58, MAXFLOAT)];
    return size;
}

- (CGFloat)itemHeight{
    return [super itemHeight];
}
@end
