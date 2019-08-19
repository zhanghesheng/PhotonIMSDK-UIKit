//
//  PhotonChatViewController+Receive.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/12.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonChatViewController+Receive.h"

@implementation PhotonChatViewController(Receive)

- (NSString *)getChatWith{
    return self.conversation.chatWith;
}
/**
 接收单人聊天消息

 @param client <#client description#>
 @param message <#message description#>
 */
- (void)imClient:(id)client didReceiveSingleMesage:(PhotonIMMessage *)message{
    [self wrapperMessage:message];
}


/**
 二人聊天消息的撤回

 @param client <#client description#>
 @param message <#message description#>
 */
- (void)imClient:(id)client didReceiveSingleWithDrawMesage:(PhotonIMMessage *)message{
    [self wrapperWithdrawMessage:message];
}


/**
 二人聊天已读消息

 @param client <#client description#>
 @param message <#message description#>
 */
- (void)imClient:(id)client didReceiveReadMesage:(PhotonIMMessage *)message{
    [self wrapperReadMessage:message];
}

#pragma mark ------ Private Method---------
// 处理二人聊天收到的信息
- (void)wrapperMessage:(PhotonIMMessage *)message{
    id item = [self.model wrapperMessage:message];
    [self.model.items addObject:item];
    [self reloadData];
}
// 处理撤回消息
- (void)wrapperWithdrawMessage:(PhotonIMMessage *)message{
    BOOL ret = [self.model wrapperWithdrawMessage:message];
    if (ret) {
         [self reloadData];
    }
}

// 消息已读的处理
- (void)wrapperReadMessage:(PhotonIMMessage *)message{
    BOOL ret = [self.model wrapperReadMessage:message];
    if (ret) {
        [self reloadData];
    }
    
}
@end
