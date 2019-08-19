//
//  PhotonVoiceMessageChatItem.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonVoiceMessageChatItem.h"

@implementation PhotonVoiceMessageChatItem
- (CGSize)contentSize{
    CGFloat defaultWith = PhotoScreenWidth * 0.58;
    return CGSizeMake(defaultWith, 44);
}

- (CGFloat)itemHeight{
    return [super itemHeight];
}
@end
