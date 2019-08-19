//
//  PhotonChatModel.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseModel.h"
#import "PhotonMessageCenter.h"
#import "PhotonTextMessageChatItem.h"
#import "PhotonImageMessageChatItem.h"
#import "PhotonVoiceMessageChatItem.h"
#import "PhotonConversationItem.h"
#import "PhotonChatNoticItem.h"
NS_ASSUME_NONNULL_BEGIN
@class PhotonIMMessage;
@interface PhotonChatModel : PhotonBaseModel
- (void)loadMoreMeesages:(PhotonIMChatType)chatType chatWith:(NSString *)chatWith beforeAuthor:(BOOL)beforeAnchor asc:(BOOL)asc finish:(void (^)(NSDictionary * _Nullable))finish;
- (PhotonBaseTableItem *)wrapperMessage:(PhotonIMMessage *)message;

- (BOOL)wrapperWithdrawMessage:(PhotonIMMessage *)messag;

- (BOOL)wrapperReadMessage:(PhotonIMMessage *)message;
@end

NS_ASSUME_NONNULL_END
