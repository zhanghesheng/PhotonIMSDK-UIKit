//
//  PhotonTextMeesageChatItem.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseChatItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotonTextMessageChatItem : PhotonBaseChatItem
@property(nonatomic, copy, nullable) NSString *messageText;
@property(nonatomic, copy, nullable) NSAttributedString *messageAttriText;
@end

NS_ASSUME_NONNULL_END
