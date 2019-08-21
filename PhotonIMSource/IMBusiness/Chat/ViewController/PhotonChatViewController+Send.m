//
//  PhotonChatViewController+Send.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/11.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonChatViewController+Send.h"

@implementation PhotonChatViewController (Send)
#pragma mark ------ 发送消息相关 ----------
// 发送文本消息
- (void)sendTextMessage:(NSString *)text{
    PhotonTextMessageChatItem *textItem = [[PhotonTextMessageChatItem alloc] init];
    textItem.fromType = PhotonChatMessageFromSelf;
    textItem.timeStamp = [[NSDate date] timeIntervalSince1970] * 1000.0;
    textItem.messageText = text;
    textItem.avatalarImgaeURL = [PhotonContent userDetailInfo].avatarURL;
    [self.model.items addObject:textItem];
    [self reloadData];
    PhotonWeakSelf(self);
    [[PhotonMessageCenter sharedCenter] sendTextMessage:textItem conversation:self.conversation completion:^(BOOL succeed, PhotonIMError * _Nullable error) {
        if (!succeed && error.code == 1001 && error.em) {
           textItem.tipText = error.em;
        }else if (!succeed){
             [PhotonUtil showErrorHint:error.em];
        }
        [weakself reloadData];
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
    imageItem.imageSize = image.size;
    imageItem.whRatio = image.size.width/image.size.height;
    imageItem.timeStamp = [[NSDate date] timeIntervalSince1970] * 1000.0;
    if (res) {
        imageItem.orignURL = imagePath;
        imageItem.thumURL = imagePath;
    }
    [self.model.items addObject:imageItem];
    [self reloadData];
     PhotonWeakSelf(self)
    [[PhotonMessageCenter sharedCenter] sendImageMessage:imageItem conversation:self.conversation completion:^(BOOL succeed, PhotonIMError * _Nullable error) {
        if (!succeed && error.code == 1001 && error.em) {
            imageItem.tipText = error.em;
        }else if (!succeed){
            [PhotonUtil showErrorHint:error.em];
        }
         [weakself reloadData];
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
    [self.model.items addObject:audioItem];
    [self reloadData];
    PhotonWeakSelf(self)
    [[PhotonMessageCenter sharedCenter] sendVoiceMessage:audioItem conversation:self.conversation completion:^(BOOL succeed, PhotonIMError * _Nullable error) {
        if (!succeed && error.em) {
            audioItem.tipText = error.em;
        }else if (!succeed){
            [PhotonUtil showErrorHint:error.em];
        }
        [weakself reloadData];
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
    [self.model.items addObject:item];
    
    [[PhotonMessageCenter sharedCenter] resendMessage:item completion:^(BOOL succeed, PhotonIMError * _Nullable error){
        if (!succeed && error.code == 1001 && error.em) {
            item.tipText = error.em;
        }else if (!succeed){
            [PhotonUtil showErrorHint:error.em];
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
            ret = YES;
        }
    }
    if (ret) {
        [self reloadData];
    }
}

@end
