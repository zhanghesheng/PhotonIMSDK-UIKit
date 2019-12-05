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
@property (nonatomic,assign)BOOL startSyncServer;
@end

@implementation PhotonChatModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pageSize = 500;
        _anchorMsgId = @"";
        
    }
    return self;
}
- (void)loadMoreMeesages:(PhotonIMChatType)chatType chatWith:(NSString *)chatWith beforeAuthor:(BOOL)beforeAnchor asc:(BOOL)asc finish:(void (^)(NSDictionary * _Nullable))finish{
    PhotonIMClient *imclient = [PhotonIMClient sharedClient];
    PhotonWeakSelf(self);
    if (self.startSyncServer) {
            [imclient syncHistoryMessagesFromServer:chatType chatWith:chatWith size:(int)self.pageSize  beginTimeStamp:(int64_t)(([NSDate date].timeIntervalSince1970 * 1000) - (2* 24 * 60 * 60 * 1000)) reaultBlock:^(NSArray<PhotonIMMessage *> * _Nullable messageList,NSString * _Nullable an, NSError * _Nullable error ) {
                if (error) {
                    weakself.startSyncServer = NO;
                }else{
                    weakself.anchorMsgId = [an copy];
                    NSMutableArray *items = [NSMutableArray array];
                    for (PhotonIMMessage *msg in messageList) {
                        id item =  [weakself wrapperMessage:msg];
                        if (item) {
                            [items addObject:item];
                        }
                    }
                    NSMutableArray *totolItems = [NSMutableArray arrayWithCapacity:weakself.items.count + items.count];
                    [totolItems addObjectsFromArray:items];
                    [totolItems addObjectsFromArray:weakself.items];
                    weakself.items = [PhotonIMThreadSafeArray arrayWithArray:totolItems];
                }
                if (finish) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        finish(nil);
                    });
                }

            }];

    }else{
            if(!weakself.anchorMsgId || weakself.anchorMsgId.length == 0){
                weakself.anchorMsgId = [[[weakself.items firstObject] userInfo] messageID];
            }
            [imclient loadHistoryMessages:chatType chatWith:chatWith anchor:weakself.anchorMsgId size:(int)weakself.pageSize reaultBlock:^(NSArray<PhotonIMMessage *> * _Nullable messages, NSString * _Nullable an, BOOL remainHistoryInServer) {
                NSMutableArray *items = [NSMutableArray array];
                weakself.anchorMsgId = [an copy];
                
                weakself.startSyncServer = remainHistoryInServer;
                for (PhotonIMMessage *msg in messages) {
                    id item =  [weakself wrapperMessage:msg];
                    if (item) {
                        [items addObject:item];
                    }
                }
                NSMutableArray *totolItems = [NSMutableArray arrayWithCapacity:weakself.items.count + items.count];
                [totolItems addObjectsFromArray:items];
                [totolItems addObjectsFromArray:weakself.items];
                weakself.items = [PhotonIMThreadSafeArray arrayWithArray:totolItems];
                if (finish) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        finish(nil);
                    });
                }
            }] ;
    }

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
    NSString *avatarUrl = @"";
    if (message.chatType == PhotonIMChatTypeSingle) {
        avatarUrl = [PhotonContent friendDetailInfo:message.fr].avatarURL;
    }else if (message.chatType == PhotonIMChatTypeGroup){
        avatarUrl = [PhotonContent friendDetailInfo:message.fr].avatarURL;
    }
    switch (message.messageType) {
        case PhotonIMMessageTypeText:{// 文本
            PhotonTextMessageChatItem *textItem = [[PhotonTextMessageChatItem alloc] init];
            textItem.fromType = fromeType;
            textItem.timeStamp = message.timeStamp;
            PhotonIMTextBody * body = (PhotonIMTextBody *)message.messageBody;
            textItem.messageText = [body text];
            textItem.userInfo = message;
            textItem.avatalarImgaeURL = avatarUrl;
            resultItem = textItem;
        }
            break;
        case PhotonIMMessageTypeImage:{// 图片
            PhotonImageMessageChatItem *imageItem = [[PhotonImageMessageChatItem alloc] init];
            imageItem.fromType = fromeType;
            imageItem.timeStamp = message.timeStamp;
            imageItem.avatalarImgaeURL = avatarUrl;
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
            audioItem.avatalarImgaeURL = avatarUrl;
            resultItem = audioItem;
        }
            break;
        case PhotonIMMessageTypeRaw:{// 自定义
            PhotonIMCustomBody *customBody = (PhotonIMCustomBody *)message.messageBody;
            if (customBody.data) {
                PhotonChatNoticItem *noticItem = [[PhotonChatNoticItem alloc] init];
                noticItem.notic = [[NSString alloc] initWithData:customBody.data encoding:NSUTF8StringEncoding];
                noticItem.userInfo = message;
                return noticItem;
            }
          
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
    NSArray *items=[self.items copy];
    for (PhotonBaseChatItem *item in items) {
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
    NSArray *readMsgIds = message.readMsgIDs;
    if (readMsgIds.count > 0) {
        NSArray *items=[self.items copy];
        for (NSString *msgID in readMsgIds) {
            for (PhotonBaseChatItem *item in items) {
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

- (void)addItem:(id)item{
    PhotonWeakSelf(self);
    [PhotonUtil runMainThread:^{
        NSInteger count = weakself.items.count;
        if (item && count > weakself.pageSize * 2){
            NSArray *items = [self.items subarrayWithRange:NSMakeRange(count-(weakself.pageSize), weakself.pageSize)];
            weakself.items = [items mutableCopy];
            weakself.anchorMsgId = [[[self.items firstObject] userInfo] messageID];
            [weakself.items addObject:item];
        }else if (item){
            [weakself.items addObject:item];
        }
    }];
   
}

- (NSArray *)insertItem:(id)item{
    
    return nil;
}

@end
