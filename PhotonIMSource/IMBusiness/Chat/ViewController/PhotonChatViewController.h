//
//  PhotonChatViewController.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
// 聊天页

#import <UIKit/UIKit.h>

#import "PhotonChatModel.h"

#import "PhotonChatPanelManager.h"
#import "PhotonChatDataSource.h"
#import "PhotonBaseViewController.h"
#import "PhotonMenuView.h"
#import "PhotonAudioPlayer.h"
#import "PhotonRecorderIndicator.h"
NS_ASSUME_NONNULL_BEGIN
@class PhotonIMConversation;
@class PhotonBaseChatItem;
@interface PhotonChatViewController : PhotonBaseViewController<PhotonChatPanelDelegate,PhotonChatDataSourceDelegate,PhotonMessageProtocol>
@property(nonatomic, strong, readonly, nullable)PhotonChatModel *model;
@property(nonatomic, strong, readonly, nullable)PhotonIMConversation *conversation;
@property(nonatomic,strong,readonly,nullable)PhotonChatPanelManager *panelManager;
@property(nonatomic,strong,readonly,nullable)PhotonMenuView *menuView;
- (instancetype)initWithConversation:(nullable PhotonIMConversation *)conversation;
@end

NS_ASSUME_NONNULL_END
