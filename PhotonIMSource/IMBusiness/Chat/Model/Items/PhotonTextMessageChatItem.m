//
//  PhotonTextMeesageChatItem.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonTextMessageChatItem.h"
#import "PhotonMacros.h"
@interface PhotonTextMessageChatItem()
@end
@implementation PhotonTextMessageChatItem
- (instancetype)init
{
    self = [super init];
    if (self) {
       
    }
    return self;
}
- (NSAttributedString *)messageAttriText{
    if (!_messageAttriText) {
        _messageAttriText = [self.messageText toMessageString];
    }
    return _messageAttriText;
}
- (CGSize)contentSize{
    if (!CGSizeEqualToSize(self.size, CGSizeZero)) {
        return self.size;
    }
    UILabel *textLabel = [[UILabel alloc] init];
    [textLabel setFont:[UIFont systemFontOfSize:16.0]];
    [textLabel setNumberOfLines:0];
    [textLabel setAttributedText:[self messageAttriText]];
    CGSize size = [textLabel sizeThatFits:CGSizeMake(PhotoScreenWidth * 0.58, MAXFLOAT)];
    self.size = size;
    return size;
}

- (CGFloat)itemHeight{
    return [super itemHeight];
}
@end
