//
//  PhotonChatPanelManager.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/20.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotonCharBar.h"
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@protocol PhotonChatPanelDelegate <NSObject>

@optional
// 聊天面板高度改变，控制相关视图的移动
- (void)scrollToBottomWithAnimation:(BOOL)animation;
// 发送文本，emoji信息
- (void)sendTextMessage:(NSString *)text;
// 发送图片信息
- (void)sendImageMessage:(NSData *)imageData;
// 发送语音信息
- (void)sendVoiceMessage:(NSString *)fileName duraion:(CGFloat)duraion;
@end

@interface PhotonChatPanelManager : NSObject
@property(nonatomic, weak)id<PhotonChatPanelDelegate> delegate;
@property(nonatomic,strong,readonly)PhotonCharBar *chatBar;
- (instancetype)initWithIdentifier:(NSString *)identifier;
- (void)addChatPanelWithSuperView:(UIView *)superView;
- (void)dismissKeyboard;
@end

NS_ASSUME_NONNULL_END
