//
//  PhotonMessageCenter.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/27.
//  Copyright © 2019 Bruce. All rights reserved.
//  业务端处理消息的管理类，单利的方式实现

#import "PhotonMessageCenter.h"
#import "PhotonFileUploadManager.h"
#import "PhotonDownLoadFileManager.h"
#import "PhotonNetworkService.h"
static PhotonMessageCenter *center = nil;
@interface PhotonMessageCenter()<PhotonIMClientProtocol>
@property (nonatomic, strong, nullable)PhotonNetworkService *netService;
@property (nonatomic, strong, nullable) PhotonIMClient *imClient;
@property (nonatomic, strong, nullable) NSHashTable *observers;

@property (nonatomic, assign) NSInteger unreadCount;


// 处理已读相关
@property (nonatomic, strong, nullable)PhotonIMThreadSafeArray *readMsgIdscCache;
@property (nonatomic, strong, nullable)NSDictionary*readMsgIdscDict;
@property (nonatomic, strong, nullable)PhotonIMTimer   *timer;

@property (nonatomic, strong,nullable) NSMutableArray<PhotonIMMessage *> *messages;
@end

#define TOKENKEY [NSString stringWithFormat:@"photonim_token_%@",[PhotonContent userDetailInfo].userID]
@implementation PhotonMessageCenter
+ (instancetype)sharedCenter{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[self alloc] init];
        [[PhotonIMClient sharedClient] addObservers:center];
        
    });
    return center;
}

- (void)addMessageHandler:(id<PhotonMessageCenterProtocol>)handler{
    _handler = handler;
}

- (void)initPhtonIMSDKWithAppid:(NSString *)appid{
    if (appid) {
        [[PhotonIMClient sharedClient] registerIMClientWithAppid:appid];
    }else{
        [[PhotonIMClient sharedClient] registerIMClientWithAppid:APP_ID];
    }
    [[PhotonIMClient sharedClient] setPhotonIMDBMode:PhotonIMDBModeDBAsync];
    
    [[PhotonIMClient sharedClient] openPhotonIMLog:YES];
    
#ifdef DEBUG
    [[PhotonIMClient sharedClient] setAssertEnable:YES];
#else
    [[PhotonIMClient sharedClient] setAssertEnable:NO];
#endif
}

- (void)login{
    [[PhotonIMClient sharedClient] bindCurrentUserId:[PhotonContent userDetailInfo].userID];
     _messages = [[[PhotonIMClient sharedClient] getAllSendingMessages] mutableCopy];
    [self getToken];
}

- (void)logout{
    [[PhotonIMClient sharedClient] logout];
}

- (NSInteger)unreadMsgCount{
    _unreadCount = [self.imClient getAllUnreadCount];
    return _unreadCount;
}

- (PhotonIMClient *)imClient{
    if (!_imClient) {
        _imClient = [PhotonIMClient sharedClient];
    }
    return _imClient;
}

- (NSHashTable *)observers{
    if (!_observers) {
        _observers = [NSHashTable weakObjectsHashTable];
    }
    return _observers;
}

- (void)addObserver:(id<PhotonMessageProtocol>)target{
    if (![self.observers containsObject:target]) {
        [self.observers addObject:target];
    }
    if (self.imClient) {
        [self.imClient addObservers:target];
    }
}

- (void)removeObserver:(id<PhotonMessageProtocol>)target{
    if ([self.observers containsObject:target]) {
        [self.observers removeObject:target];
    }
    if (self.imClient) {
        [self.imClient removeObserver:target];
    }
}

- (void)removeAllObserver{
    [self.observers removeAllObjects];
    if (self.imClient) {
        [self.imClient removeAllObservers];
    }
}

- (void)sendTextMessage:(PhotonTextMessageChatItem *)item conversation:(nullable PhotonIMConversation *)conversation completion:(nullable CompletionBlock)completion{
    // 文本消息，直接构建文本消息对象发送
    PhotonIMMessage *message =[[PhotonIMMessage alloc] init];
    message.fr = [PhotonContent userDetailInfo].userID;
    message.to = conversation.chatWith;
    message.chatWith = conversation.chatWith;
    message.timeStamp = [[NSDate date] timeIntervalSince1970] * 1000.0;
    message.chatType = PhotonIMChatTypeSingle;
    message.messageType = PhotonIMMessageTypeText;
    message.messageStatus = PhotonIMMessageStatusSending;
    
    PhotonIMTextBody *body = [[PhotonIMTextBody alloc] initWithText:item.messageText];
    [message setMesageBody:body];
    item.userInfo = message;
    [self _sendMessage:message completion:completion];
}

- (void)sendImageMessage:(PhotonImageMessageChatItem *)item conversation:(nullable PhotonIMConversation *)conversation completion:(nullable CompletionBlock)completion{
    // 文本消息，直接构建文本消息对象发送
    PhotonIMMessage *message =[[PhotonIMMessage alloc] init];
    message.fr = [PhotonContent userDetailInfo].userID;
    message.to = conversation.chatWith;
    message.chatWith = conversation.chatWith;
    message.timeStamp = item.timeStamp;
    message.messageType = PhotonIMMessageTypeImage;
    message.messageStatus = PhotonIMMessageStatusDefault;
    message.chatType = PhotonIMChatTypeSingle;
    PhotonIMImageBody *body = [[PhotonIMImageBody alloc] init];
    body.localFileName = item.fileName;
    body.whRatio = item.whRatio;
    [message setMesageBody:body];
    item.userInfo = message;
    
    // 先做图片上传处理，获得资源地址后构建图片消息对象发送消息
    [self p_sendImageMessage:message completion:completion];
}

- (void)sendVoiceMessage:(PhotonVoiceMessageChatItem *)item conversation:(nullable PhotonIMConversation *)conversation completion:(nullable CompletionBlock)completion{
    
    // 文本消息，直接构建文本消息对象发送
    PhotonIMMessage *message =[[PhotonIMMessage alloc] init];
    message.fr = [PhotonContent userDetailInfo].userID;
    message.to = conversation.chatWith;
    message.chatWith = conversation.chatWith;
    message.timeStamp = item.timeStamp;
    message.messageType = PhotonIMMessageTypeAudio;
    message.messageStatus = PhotonIMMessageStatusDefault;
    message.chatType = PhotonIMChatTypeSingle;
    PhotonIMAudioBody *body = [[PhotonIMAudioBody alloc] init];
    body.localFileName = item.fileName;
    body.mediaTime = item.duration;
    [message setMesageBody:body];
    item.userInfo = message;
    
    [[PhotonMessageCenter sharedCenter] insertOrUpdateMessage:message];
    // 先做语音上传处理，获得资源地址后构建图片消息对象发送消息
    [self p_sendVoiceMessage:message completion:completion];
}




#pragma mark  -------- Private ---------------
- (void)p_sendImageMessage:(PhotonIMMessage *)message completion:(nullable CompletionBlock)completion{
    // 存储文件上传前的message
    [[PhotonMessageCenter sharedCenter] insertOrUpdateMessage:message];
    // 先做图片上传处理，获得资源地址后构建图片消息对象发送消息
    PhotonIMImageBody *body =(PhotonIMImageBody *)message.messageBody;
    NSString *filePath = [[PhotonMessageCenter sharedCenter] getImageFilePath:message.chatWith fileName:body.localFileName];
    PhotonWeakSelf(self)
    if (self.handler && [self.handler respondsToSelector:@selector(uploadImage:completion:)]) {
        [self.handler uploadImage:filePath completion:^(BOOL succeed, NSString * _Nullable url, NSString * _Nullable thumImageUrl) {
            [weakself p_sendMessag:message url:url thumUrl:thumImageUrl completion:completion];
        }];
    }else{
        PhotonUploadFileInfo *fileInfo = [[PhotonUploadFileInfo alloc]init];
        fileInfo.name = @"fileUpload";
        fileInfo.fileName = @"chatimage.jpg";
        fileInfo.mimeType = @"image/jpeg";
        fileInfo.fileURLString = filePath;
        [[PhotonFileUploadManager defaultManager] uploadRequestMethodWithMutiFile:PHOTON_IMAGE_UPLOAD_PATH paramter:nil fromFiles:@[fileInfo] progressBlock:^(NSProgress * _Nonnull progress) {
        } completion:^(NSDictionary * _Nonnull dict) {
            NSString *fileURL = [[[[dict objectForKey:@"data"] isNil] objectForKey:@"url"] isNil];
            [weakself p_sendMessag:message url:fileURL thumUrl:nil completion:completion];
        } failure:^(PhotonErrorDescription * _Nonnull error) {
            [weakself p_sendMessag:message url:nil thumUrl:nil completion:completion];
        }];
    }
    
}

- (void)p_sendVoiceMessage:(PhotonIMMessage *)message completion:(nullable CompletionBlock)completion{
    // 存储文件上传前的message
    [[PhotonMessageCenter sharedCenter] insertOrUpdateMessage:message];
    // 先做图片上传处理，获得资源地址后构建图片消息对象发送消息
    PhotonIMAudioBody *body =(PhotonIMAudioBody *)message.messageBody;
     NSString *filePath = [[PhotonMessageCenter sharedCenter] getImageFilePath:message.chatWith fileName:body.localFileName];
    PhotonWeakSelf(self)
    if (self.handler && [self.handler respondsToSelector:@selector(uploadVoice::completion:)]) {
        [self.handler uploadVoice:filePath completion:^(BOOL succeed, NSString * _Nullable url) {
            [weakself p_sendMessag:message url:url thumUrl:nil completion:completion];
        }];
    }else{
        PhotonUploadFileInfo *fileInfo = [[PhotonUploadFileInfo alloc]init];
        fileInfo.name = @"fileUpload";
        fileInfo.fileName = @"chataudio.opus";
        fileInfo.mimeType = @"audio/opus";
        fileInfo.fileURLString = filePath;
        [[PhotonFileUploadManager defaultManager] uploadRequestMethodWithMutiFile:PHOTON_AUDIO_UPLOAD_PATH paramter:nil fromFiles:@[fileInfo] progressBlock:^(NSProgress * _Nonnull progress) {
        } completion:^(NSDictionary * _Nonnull dict) {
            NSString *fileURL = [[[[dict objectForKey:@"data"] isNil] objectForKey:@"url"] isNil];
            [weakself p_sendMessag:message url:fileURL thumUrl:nil completion:completion];
        } failure:^(PhotonErrorDescription * _Nonnull error) {
            [weakself p_sendMessag:message url:nil thumUrl:nil completion:completion];
        }];
    }
   
}

- (void)p_sendMessag:(PhotonIMMessage *)message url:(NSString *)url thumUrl:(NSString *)thumUrl completion:(nullable CompletionBlock)completion{
    
    if (!message) {
        return;
    }
    if ([url isNotEmpty]) {
        if(message.messageType == PhotonIMMessageTypeImage){
            PhotonIMImageBody *body = (PhotonIMImageBody *)message.messageBody;
            body.url = url;
            if([thumUrl isNotEmpty]){
                body.thumbURL = thumUrl;
            }
        }else if(message.messageType == PhotonIMMessageTypeAudio){
            PhotonIMAudioBody *body = (PhotonIMAudioBody *)message.messageBody;
            body.url = url;
        }
        // 文件下载成功
        if (completion) {
            completion(YES,nil);
        }
        [self _sendMessage:message completion:completion];
    }else{
        message.messageStatus = PhotonIMMessageStatusFailed;
        [self insertOrUpdateMessage:message];
        PhotonIMError *error = [PhotonIMError errorWithDomain:@"photoimdomain" code:-1 errorMessage:@"文件上传失败" userInfo:@{}];
        if (completion) {
            completion(NO,error);
        }
        
    }
}

// 重发消息
- (void)resendMessage:(nullable PhotonBaseChatItem *)item completion:(nullable CompletionBlock)completion{
    PhotonIMMessage *message = (PhotonIMMessage *)item.userInfo;
    if(message.messageStatus != PhotonIMMessageStatusDefault){
        message.messageStatus = PhotonIMMessageStatusSending;
    }
    // 文件发送
    if (completion) {
        completion(YES,nil);
    }
    if(message.messageType == PhotonIMMessageTypeImage || message.messageType == PhotonIMMessageTypeAudio){
        PhotonIMBaseBody *body = message.messageBody;
        if ([body.url isNotEmpty]) {// 文件上传完成，直接发送
            [self _sendMessage:message completion:completion];
        }else{// 文件上传未完成，先上再发送
            if (message.messageType == PhotonIMMessageTypeImage) {
                [self p_sendImageMessage:message completion:completion];
            }else if (message.messageType == PhotonIMMessageTypeAudio){
                [self p_sendVoiceMessage:message completion:completion];
            }
        }
    }else if(message.messageType == PhotonIMMessageTypeText){//文本直接发送
        [self _sendMessage:message completion:completion];
    }
}

// 重新发送未发送完成的消息
- (void)reSendAllSendingMessages{
    if(self.messages){
        __weak typeof(self)weakSelf = self;
        NSArray<PhotonIMMessage *> *messages = [self.messages copy];
        for(PhotonIMMessage *message in messages){
            message.timeStamp = [[NSDate date] timeIntervalSince1970] * 1000.0;
            if(message.messageType == PhotonIMMessageTypeImage || message.messageType == PhotonIMMessageTypeAudio){
                PhotonIMBaseBody *body = message.messageBody;
                if ([body.url isNotEmpty]) {// 文件上传完成，直接发送
                    [self _sendMessage:message completion:^(BOOL succeed, PhotonIMError * _Nullable error) {
                        if (succeed) {
                            [weakSelf.messages removeObject:message];
                        }
                        
                    }];
                }else{// 文件上传未完成，先上再发送
                    if (message.messageType == PhotonIMMessageTypeImage) {
                        [self p_sendImageMessage:message completion:^(BOOL succeed, PhotonIMError * _Nullable error) {
                            if (succeed) {
                                [weakSelf.messages removeObject:message];
                            }
                        }];
                    }else if (message.messageType == PhotonIMMessageTypeAudio){
                        [self p_sendVoiceMessage:message completion:^(BOOL succeed, PhotonIMError * _Nullable error) {
                            if (succeed) {
                                [weakSelf.messages removeObject:message];
                            }
                        }];
                    }
                }
            }else if(message.messageType == PhotonIMMessageTypeText){//文本直接发送
                [self _sendMessage:message completion:nil];
            }
        }
    }
    
}

// 发送已读消息
- (void)sendReadMessage:(NSArray<NSString *> *)readMsgIDs conversation:(nullable PhotonIMConversation *)conversation completion:(nullable CompletionBlock)completion{
    [self.imClient sendReadMessage:readMsgIDs fromid:[PhotonContent userDetailInfo].userID toid:conversation.chatWith completion:^(BOOL succeed, PhotonIMError * _Nullable error) {
        [PhotonUtil runMainThread:^{
            if (completion) {
                completion(succeed,error);
            }
        }];
    }];
}
- (void)sendWithDrawMessage:(nullable PhotonBaseChatItem *)item completion:(nullable CompletionBlock)completion{
    id message = item.userInfo;
    if ([message isKindOfClass:[PhotonIMMessage class]]) {
        [self.imClient sendWithDrawMessage:message completion:^(BOOL succeed, PhotonIMError * _Nullable error) {
            [PhotonUtil runMainThread:^{
                if (completion) {
                    completion(succeed,error);
                }
            }];
        }];
    }
}

- (void)transmitMessage:(nullable PhotonIMMessage *)message conversation:(nullable PhotonIMConversation *)conversation completion:(nullable CompletionBlock)completion{
    // 文件操作，转发时将文件拷贝到转发的会话下
    if (message.messageType == PhotonIMMessageTypeImage || message.messageType == PhotonIMMessageTypeAudio) {
        PhotonIMMediaBody *imgBody = (PhotonIMMediaBody *)message.messageBody;
        NSString *fileName = imgBody.localFileName;
        NSString *originFilePath = [self getImageFilePath:message.chatWith fileName:fileName];
        if ([PhotonUtil jugdeFileExit:originFilePath]) {
            NSString *desFilePath = [self getImageFilePath:conversation.chatWith fileName:fileName];
            if (![originFilePath isEqualToString:desFilePath]) {
                NSError *error;
                [[NSFileManager defaultManager] copyItemAtPath:originFilePath toPath:desFilePath error:&error];
            } 
        }
    }
    
    PhotonIMMessage *sendMessage = [[PhotonIMMessage alloc] init];
    sendMessage.chatWith = conversation.chatWith;
    sendMessage.chatType = conversation.chatType;
    sendMessage.fr = [PhotonContent userDetailInfo].userID;
    sendMessage.to = conversation.chatWith;
    sendMessage.timeStamp = [[NSDate date] timeIntervalSince1970] * 1000.0;
    sendMessage.messageType = message.messageType;
    sendMessage.messageStatus = PhotonIMMessageStatusDefault;
    sendMessage.chatType = message.chatType;
    [sendMessage setMesageBody:message.messageBody];
    [self _sendMessage:sendMessage completion:completion];
}

- (void)_sendMessage:(nullable PhotonIMMessage *)message completion:(nullable void(^)(BOOL succeed, PhotonIMError * _Nullable error ))completion{
    [[PhotonIMClient sharedClient] sendMessage:message completion:^(BOOL succeed, PhotonIMError * _Nullable error) {
        [PhotonUtil runMainThread:^{
            if (completion) {
                completion(succeed,error);
            }
            NSHashTable *_observer = [self.observers copy];
            for (id<PhotonMessageProtocol> observer in _observer) {
                if (observer && [observer respondsToSelector:@selector(sendMessageResultCallBack:)]) {
                    [observer sendMessageResultCallBack:message];
                }
            }
        }];
    }];
}

#pragma mark ---  数据操作相关 -----
- (void)insertOrUpdateMessage:(PhotonIMMessage *)message{
    [self.imClient insertOrUpdateMessage:message updateConversion:YES];
}
- (void)deleteMessage:(PhotonIMMessage *)message{
    [self.imClient deleteMessage:message];
}
- (void)deleteConversation:(PhotonIMConversation *)conversation clearChatMessage:(BOOL)clearChatMessage{
    [self.imClient deleteConversation:conversation clearChatMessage:clearChatMessage];
    if (clearChatMessage) {// 删除文件夹下的所有文件
        [self deleteAllFile:conversation.chatWith];
    }
    
}

- (void)clearConversationUnReadCount:(PhotonIMConversation *)conversation{
    [self.imClient clearConversationUnReadCount:conversation.chatType chatWith:conversation.chatWith];
}
- (void)updateConversationIgnoreAlert:(PhotonIMConversation *)conversation{
    [self.imClient updateConversationIgnoreAlert:conversation];
}

- (void)saveConversation:(PhotonIMConversation *)conversation{
    [[PhotonIMClient sharedClient] saveConversation:conversation];
}

#pragma mark --------- 文件操作相关 ----------------

- (NSString *)getVoiceFilePath:(NSString *)chatWith fileName:(nullable NSString *)fileName{
    if(!fileName || fileName.length == 0){
        return nil;
    }
    NSString *path = [NSString stringWithFormat:@"%@/PhotonIM/File/%@/%@/voices", [NSFileManager documentsPath], [PhotonContent userDetailInfo].userID,chatWith];
    if (![PhotonUtil createDirectoryIfExit:path]) {
        return nil;
    }
    return [path stringByAppendingPathComponent:fileName];
}

- (NSURL *)getVoiceFileURL:(NSString *)chatWith fileName:(nullable NSString *)fileName{
    if(!fileName || fileName.length == 0){
        return nil;
    }
    NSString * path =  [self getVoiceFilePath:chatWith fileName:fileName];
    if ([path isNotEmpty]) {
        return [NSURL fileURLWithPath:path];
    }
    return nil;
}

- (NSString *)getImageFilePath:(NSString *)chatWith fileName:(nullable NSString *)fileName{
    if(!fileName || fileName.length == 0){
        return nil;
    }
    NSString *path = [NSString stringWithFormat:@"%@/PhotonIM/File/%@/%@/images", [NSFileManager documentsPath], [PhotonContent userDetailInfo].userID,chatWith];
    if (![PhotonUtil createDirectoryIfExit:path]) {
        return nil;
    }
    return [path stringByAppendingPathComponent:fileName];
}
- (NSURL *)getImageFileURL:(NSString *)chatWith fileName:(nullable NSString *)fileName{
    if(!fileName || fileName.length == 0){
        return nil;
    }
    NSString * path =  [self getImageFilePath:chatWith fileName:fileName];
    if ([path isNotEmpty]) {
        return [NSURL fileURLWithPath:path];
    }
    return nil;
}

- (BOOL)deleteVoiceFile:(NSString *)chatWith fileName:(nullable NSString *)fileName{
    if(!fileName || fileName.length == 0){
        return NO;
    }
    NSString *path = [self getVoiceFilePath:chatWith fileName:fileName];
    bool res = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    return res;
}

- (BOOL)deleteImageFile:(NSString *)chatWith fileName:(nullable NSString *)fileName{
    if(!fileName || fileName.length == 0){
        return NO;
    }
    NSString *path = [self getImageFilePath:chatWith fileName:fileName];
    bool res = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    return res;
}

- (BOOL)deleteAllFile:(NSString *)chatWith{
     NSString *path = [NSString stringWithFormat:@"%@/PhotonIM/File/%@/%@/", [NSFileManager documentsPath], [PhotonContent userDetailInfo].userID,chatWith];
    bool res = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    return res;
}

- (void)imClient:(id)client didReceiveCustomMesage:(PhotonIMMessage *)message{
    [PhotonUtil showInfoHint:@"这是自定义消息"];
}

#pragma mark --------- 消息接收相关 ----------------

- (void)imClientLogin:(nonnull id)client failedType:(PhotonIMLoginFailedType)failedType {
    switch (failedType) {
        case PhotonIMLoginFailedTypeTokenError:
        case PhotonIMLoginFailedTypeParamterError:{
            [PhotonUtil runMainThread:^{
                if (self.handler  && [self.handler respondsToSelector:@selector(loginSucceed:)]){
                    [self.handler loginSucceed:NO];
                }
            }];
            
        }
            break;
        case PhotonIMLoginFailedTypeKick:{
            [PhotonUtil runMainThread:^{
                if (self.handler  && [self.handler respondsToSelector:@selector(KickAccount)]){
                    [self.handler KickAccount];
                }
            }];
            
        }
            break;
        default:
            break;
    }
}

- (void)imClientLogin:(nonnull id)client loginStatus:(PhotonIMLoginStatus)loginstatus {
    if (loginstatus ==  PhotonIMLoginStatusLoginSucceed) {
        [self reSendAllSendingMessages];
        [PhotonUtil runMainThread:^{
            if (self.handler  && [self.handler respondsToSelector:@selector(loginSucceed:)]){
                [self.handler loginSucceed:YES];
            }
        }];
    }
}



#pragma mark ---- 登录相关 ----
- (void)getToken{
    if (self.handler  && [self.handler respondsToSelector:@selector(requestLoginToken:)]) {
        [self.handler requestLoginToken:^(BOOL succeed, NSString * _Nullable token) {
            if (succeed) {
                if ([token isNotEmpty]) {
                    [[PhotonIMClient sharedClient] loginWithToken:token extra:nil];
                }
            }
        }];
    }
}

- (PhotonNetworkService *)netService{
    if (!_netService) {
        _netService = [[PhotonNetworkService alloc] init];
        _netService.baseUrl = PHOTON_BASE_URL;
        
    }
    return _netService;
}
@end
