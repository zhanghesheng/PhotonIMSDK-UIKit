//
//  PhotonChatModel.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonChatModel.h"
@interface PhotonChatModel()
@property (nonatomic,copy,nullable)NSString *anchorMsgId;
@end

@implementation PhotonChatModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pageSize = 50;
        _anchorMsgId = @"";
        
    }
    return self;
}
- (void)loadMoreMeesages:(PhotonIMChatType)chatType chatWith:(NSString *)chatWith beforeAuthor:(BOOL)beforeAnchor asc:(BOOL)asc finish:(void (^)(NSDictionary * _Nullable))finish{
    PhotonIMClient *imclient = [PhotonIMClient sharedClient];
    PhotonWeakSelf(self);
    dispatch_block_t block = ^(void){
       weakself.anchorMsgId = [[self.items.firstObject userInfo] messageID];
       NSArray<PhotonIMMessage *>* messages = [imclient findMessageListByIdRange:chatType chatWith:chatWith anchorMsgId:weakself.anchorMsgId beforeAuthor:beforeAnchor asc:asc size:(int)weakself.pageSize];
        NSMutableArray *items = [NSMutableArray array];
        for (PhotonIMMessage *msg in messages) {
           id item =  [weakself wrapperMessage:msg];
           [items addObject:item];
        }
        NSMutableArray *totolItems = [NSMutableArray arrayWithCapacity:self.items.count + items.count];
        [totolItems addObjectsFromArray:items];
        [totolItems addObjectsFromArray:self.items];
        self.items = [NSMutableArray arrayWithArray:totolItems];
        if (finish) {
            [PhotonUtil runMainThread:^{
                finish(nil);
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        }
    };
    [[PhotonIMClient sharedClient] runInPhotonIMDBQueue:block];
}

// 处理二人聊天收到的信息
- (PhotonBaseTableItem *)wrapperMessage:(PhotonIMMessage *)message{
    PhotonBaseChatItem * resultItem = nil;
    PhotonChatMessageFromType fromeType = [message.fr isEqualToString:[PhotonContent userDetailInfo].userID]?PhotonChatMessageFromSelf:PhotonChatMessageFromFriend;
    // 处理撤回的消息
    if (message.messageStatus == PhotonIMMessageStatusRecall) {
        PhotonChatNoticItem *noticItem = [[PhotonChatNoticItem alloc] init];
        noticItem.notic = message.withdrawNotice;
        noticItem.userInfo = message;
        return noticItem;
    }
    NSString *avatarURL = nil;
    if (fromeType == PhotonChatMessageFromSelf) {
        avatarURL = [PhotonContent userDetailInfo].avatarURL;
    }else{
        avatarURL = [PhotonContent friendDetailInfo:message.fr].avatarURL;
    }
    switch (message.messageType) {
        case PhotonIMMessageTypeText:{// 文本
            PhotonTextMessageChatItem *textItem = [[PhotonTextMessageChatItem alloc] init];
            textItem.fromType = fromeType;
            textItem.timeStamp = message.timeStamp;
            PhotonIMTextBody * body = (PhotonIMTextBody *)message.messageBody;
            textItem.messageText = [body text];
            textItem.userInfo = message;
            textItem.avatarURL = avatarURL;
            resultItem = textItem;
        }
            break;
        case PhotonIMMessageTypeImage:{// 图片
            PhotonImageMessageChatItem *imageItem = [[PhotonImageMessageChatItem alloc] init];
            imageItem.fromType = fromeType;
            imageItem.timeStamp = message.timeStamp;
            imageItem.avatarURL = avatarURL;
            PhotonIMImageBody *imgBody = (PhotonIMImageBody *)message.messageBody;
            if([imgBody.thumbURL isNotEmpty]){
                imageItem.thumURL = imgBody.thumbURL;
            }
            if([imgBody.url isNotEmpty]){
                imageItem.orignURL = imgBody.url;
            }
            imageItem.fileName = imgBody.localFileName;
            if(fromeType == PhotonChatMessageFromSelf){
                imageItem.localPath = [[PhotonMessageCenter sharedCenter] getImageFilePath:message.chatWith fileName:imageItem.fileName];
            }
            if (!CGSizeEqualToSize(imgBody.imageSize, CGSizeZero)) {
                imageItem.imageSize = imgBody.imageSize;
            }
            imageItem.whRatio = imgBody.whRatio;
            
            imageItem.userInfo = message;
            resultItem = imageItem;
        }
            break;
        case PhotonIMMessageTypeAudio:{// 语音
            PhotonVoiceMessageChatItem *audioItem = [[PhotonVoiceMessageChatItem alloc] init];
            audioItem.fromType = fromeType;
            audioItem.timeStamp = message.timeStamp;
            PhotonIMAudioBody *audioBody = (PhotonIMAudioBody *)message.messageBody;
            if([audioBody.url isNotEmpty]){
                audioItem.url = [NSURL URLWithString:audioBody.url];
            }
            audioItem.fileName = audioBody.localFileName;
            audioItem.duration = audioBody.mediaTime;
            audioItem.userInfo = message;
            audioItem.isPlayed = audioBody.localMediaPlayed;
            audioItem.avatarURL = avatarURL;
            resultItem = audioItem;
        }
            break;
            
        default:
            break;
    }
    resultItem.tipText = message.notic;
    return resultItem;
}


- (BOOL)wrapperWithdrawMessage:(PhotonIMMessage *)messag{
    PhotonBaseChatItem *tempItem = nil;
    for (PhotonBaseChatItem *item in self.items) {
        PhotonIMMessage *tempMsg = item.userInfo;
        if ([tempMsg.messageID isEqualToString:messag.withdrawMsgID]) {
            tempItem = item;
        }
    }
    if (tempItem) {
        NSInteger index = [self.items indexOfObject:tempItem];
        PhotonChatNoticItem *noticItem = [[PhotonChatNoticItem alloc] init];
        noticItem.notic = messag.withdrawNotice;
        [self.items replaceObjectAtIndex:index withObject:noticItem];
        return YES;
    }
    return NO;
}

- (BOOL)wrapperReadMessage:(PhotonIMMessage *)message{
    BOOL ret = NO;
    NSArray *readMsgIds = message.readMagIds;
    if (readMsgIds.count > 0) {
        for (NSString *msgID in readMsgIds) {
            for (PhotonBaseChatItem *item in self.items) {
                PhotonIMMessage *tempMsg = item.userInfo;
                if ([tempMsg.messageID isEqualToString:msgID]) {
                    tempMsg.messageStatus = PhotonIMMessageStatusSentRead;
                    ret = YES;
                }
            }
        }
    }
    return ret;
}
@end
