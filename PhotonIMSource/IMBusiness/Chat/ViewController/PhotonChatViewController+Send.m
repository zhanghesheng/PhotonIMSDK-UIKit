//
//  PhotonChatViewController+Send.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/11.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonChatViewController+Send.h"
#import "PhotonAtMemberListViewController.h"
@implementation PhotonChatViewController (Send)
#pragma mark ------ 发送消息相关 ----------
// 发送文本消息
- (void)sendTextMessage:(NSString *)text atItems:(nonnull NSArray<PhotonChatAtInfo *> *)atItems type:(AtType)atType{
    PhotonTextMessageChatItem *textItem = [[PhotonTextMessageChatItem alloc] init];
    textItem.fromType = PhotonChatMessageFromSelf;
    textItem.timeStamp = [[NSDate date] timeIntervalSince1970] * 1000.0;
    textItem.messageText = text;
    textItem.avatalarImgaeURL = [PhotonContent userDetailInfo].avatarURL;
    textItem.atInfo = [atItems copy];
    textItem.type = (int)atType;
    PhotonWeakSelf(self);
    [self addItem:textItem];
   
    [PhotonUtil runMainThread:^{
        NSInteger count = weakself.totleSendCount + 1;
         weakself.totleSendCount =  count;
        
    }];
    [[PhotonMessageCenter sharedCenter] sendTextMessage:textItem conversation:self.conversation completion:^(BOOL succeed, PhotonIMError * _Nullable error) {
        if (succeed) {
             NSInteger count = weakself.sendSucceedCount + 1;
            weakself.sendSucceedCount = count;

        }else{
             NSInteger count = weakself.sendFailedCount + 1;
            weakself.sendFailedCount =  count;

        }
        if ( weakself.sendSucceedCount + weakself.sendFailedCount == weakself.count) {
            NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970] * 1000.0;
            int duration = endTime - weakself.startTime;
            NSLog(@"%@",[NSString stringWithFormat:@"总耗时(毫秒)：%@",@(duration)]);
             weakself.totalTimeLable.text = [NSString stringWithFormat:@"总耗时(毫秒)：%@",@(duration)];
        }
        if (!succeed && error.code >=1000 && error.em) {
           textItem.tipText = error.em;
        }else if (!succeed){
            if (error.code != -1 && error.code != -2) {
                 [PhotonUtil showErrorHint:error.em];
            }
            
        }
        if (succeed) {
            textItem.tipText = @"";
        }
        [weakself updateItem:textItem];
    }];
    
}

// 发送图片消息
- (void)sendImageMessage:(NSData *)imageData{
    UIImage *image = [UIImage imageWithData:imageData];
    
    double dataLength = [imageData length] * 1.0;
    dataLength = (dataLength/1024.0)/1024.0;
    if(dataLength > 10){
        [PhotonUtil showInfoHint:@"仅支持发送10M以内的图片"];
        return;
    }
    
    NSString *imageName = [NSString stringWithFormat:@"%.0lf.jpg", [NSDate date].timeIntervalSince1970];
    NSString *imagePath = [[PhotonMessageCenter sharedCenter] getImageFilePath:self.conversation.chatWith fileName:imageName];
   
    BOOL res =  [[NSFileManager defaultManager] createFileAtPath:imagePath contents:imageData attributes:nil];
    PhotonImageMessageChatItem *imageItem = [[PhotonImageMessageChatItem alloc] init];
    imageItem.fromType = PhotonChatMessageFromSelf;
    imageItem.fileName = imageName;
    imageItem.avatalarImgaeURL = [PhotonContent userDetailInfo].avatarURL;
    imageItem.whRatio = image.size.width/image.size.height;
    imageItem.timeStamp = [[NSDate date] timeIntervalSince1970] * 1000.0;
    if (res) {
        imageItem.orignURL = imagePath;
        imageItem.thumURL = imagePath;
    }
    [self addItem:imageItem];
     PhotonWeakSelf(self)
    [[PhotonMessageCenter sharedCenter] sendImageMessage:imageItem conversation:self.conversation completion:^(BOOL succeed, PhotonIMError * _Nullable error) {
        if (!succeed && error.code >=1000 && error.em) {
            imageItem.tipText = error.em;
        }else if (!succeed){
            if (error.code != -1 && error.code != -2) {
                [PhotonUtil showErrorHint:error.em];
            }
        }
        if (succeed) {
            imageItem.tipText = @"";
        }
        [weakself updateItem:imageItem];
    }];
}
// 发送语音消息
- (void)sendVoiceMessage:(nonnull NSString *)fileName duraion:(CGFloat)duraion{
    PhotonVoiceMessageChatItem *audioItem = [[PhotonVoiceMessageChatItem alloc] init];
    audioItem.fromType = PhotonChatMessageFromSelf;
    audioItem.timeStamp = [[NSDate date] timeIntervalSince1970] * 1000.0;
    audioItem.fileName = fileName;
    audioItem.duration = duraion;
    audioItem.avatalarImgaeURL = [PhotonContent userDetailInfo].avatarURL;
    [self addItem:audioItem];
    PhotonWeakSelf(self)
    [[PhotonMessageCenter sharedCenter] sendVoiceMessage:audioItem conversation:self.conversation completion:^(BOOL succeed, PhotonIMError * _Nullable error) {
        if (!succeed && error.em) {
            audioItem.tipText = error.em;
        }else if (!succeed){
            if (error.code != -1 && error.code != -2) {
                [PhotonUtil showErrorHint:error.em];
            }
        }
        if (succeed) {
            audioItem.tipText = @"";
        }
        [weakself updateItem:audioItem];
    }];
}

// 发送消息已读

- (void)sendReadMsgs:(NSArray *)msgids completion:(void (^)(BOOL, PhotonIMError * _Nullable))completion{
    [[PhotonMessageCenter sharedCenter] sendReadMessage:msgids conversation:self.conversation completion:^(BOOL succeed, PhotonIMError * _Nullable error) {
        if (completion) {
            completion(succeed,error);
        }
    }];
}

- (void)resendMessage:(PhotonBaseChatItem *)item{
    [self.model.items removeObject:item];
    PhotonWeakSelf(self)
    item.timeStamp = [[NSDate date] timeIntervalSince1970] * 1000.0;
    [(PhotonChatModel *)self.model addItem:item];
    
    [[PhotonMessageCenter sharedCenter] resendMessage:item completion:^(BOOL succeed, PhotonIMError * _Nullable error){
        if (!succeed && error.code >=1000 && error.em) {
            item.tipText = error.em;
        }else if (!succeed){
            if (error.code != -1 && error.code != -2) {
                [PhotonUtil showErrorHint:error.em];
            }
        }
        if (succeed) {
            item.tipText = @"";
        }
        [weakself reloadData];
    }];
}

#pragma mark ------  PhotonMessageProtocol ------
- (void)sendMessageResultCallBack:(PhotonIMMessage *)message{
    BOOL ret  = NO;
    NSArray *tempItems = [self.model.items copy];
    for (PhotonBaseChatItem *item in tempItems) {
        if ([[item.userInfo messageID] isEqualToString:[message messageID]]) {
            ((PhotonIMMessage *)item.userInfo).messageStatus = [message messageStatus];
            ((PhotonIMMessage *)item.userInfo).notic = [message notic];
            item.tipText = message.notic;
            ret = YES;
        }
    }
    if (ret) {
        [self reloadData];
    }
}

- (void)processAtAction:(PhotonCharBar *)charBar{
    if (self.conversation.chatType == PhotonIMChatTypeGroup) {
        NSMutableArray *items = [NSMutableArray array];
        PhotonAtMemberListViewController *memberListCtl = [[PhotonAtMemberListViewController alloc] initWithGid:self.conversation.chatWith result:^(AtType type, NSArray * _Nullable resultItems) {
            charBar.atType = type;
            [charBar deleteLastCharacter];
            [items addObjectsFromArray:charBar.atInfos];
            [items addObjectsFromArray:resultItems];
            charBar.atInfos = [items copy];
            for (PhotonChatAtInfo *item in resultItems) {
                [charBar addAtContent:item.nickName];
            }
        }];
        [self.navigationController pushViewController:memberListCtl animated:YES];
    }
   
    
}
@end
