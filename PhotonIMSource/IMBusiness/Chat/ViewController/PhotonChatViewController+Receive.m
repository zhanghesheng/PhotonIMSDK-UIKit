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

 @param client client im sdk client 句柄
 @param message 消息
 */
- (void)imClient:(id)client didReceiveMesage:(PhotonIMMessage *)message{
    [[PhotonIMClient sharedClient] consumePacket:message.lt lv:message.lv];
    [self wrapperMessage:message];
}

/**
 二人聊天消息的撤回

 @param client im sdk client 句柄
 @param message 消息
 */
- (void)imClient:(id)client didReceiveSingleWithDrawMesage:(PhotonIMMessage *)message{
    [self wrapperWithdrawMessage:message];
}

- (void)imClient:(id)client didReceiveGroupWithDrawMesage:(PhotonIMMessage *)message{
     [self wrapperWithdrawMessage:message];
}


/**
 二人聊天已读消息

 @param client <#client description#>
 @param message <#message description#>
 */
- (void)imClient:(id)client di2dReceiveReadMesage:(PhotonIMMessage *)message{
    [self wrapperReadMessage:message];
}

#pragma mark ------ Private Method---------
// 处理二人聊天收到的信息
- (void)wrapperMessage:(PhotonIMMessage *)message{
    [self _wrapperMessage:message];
}
- (void)_wrapperMessage:(PhotonIMMessage *)message{
    id item = [(PhotonChatModel *)self.model wrapperMessage:message];
    if (!item) {
        return;
    }
    [self addItem:item];
    
    if(message.chatType == PhotonIMChatTypeGroup && message.msgAtType != PhotonIMAtTypeNoAt){
        [[PhotonMessageCenter sharedCenter] resetAtType:self.conversation];
    }
    
}
// 处理撤回消息
- (void)wrapperWithdrawMessage:(PhotonIMMessage *)message{
    BOOL ret = [(PhotonChatModel *)self.model wrapperWithdrawMessage:message];
    if (ret) {
         [self reloadData];
    }
}


// 消息已读的处理
- (void)wrapperReadMessage:(PhotonIMMessage *)message{
    BOOL ret = [(PhotonChatModel *)self.model wrapperReadMessage:message];
    if (ret) {
        [self reloadData];
    }
    
}
@end
