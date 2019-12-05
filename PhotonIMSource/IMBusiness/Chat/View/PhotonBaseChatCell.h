//
//  PhotonBaseChatCell.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Masonry/Masonry.h>
#import "PhotonTableViewCell.h"
#import "PhotonBaseChatItem.h"
NS_ASSUME_NONNULL_BEGIN
@class PhotonBaseChatCell;
@protocol PhotonBaseChatCellDelegate <NSObject>

@optional
/**
 点击头像事件代理

 @param cell <#cell description#>
 */
- (void)chatCell:(PhotonBaseChatCell *)cell didSelectAvatar:(nullable PhotonBaseChatItem *)chatItem;
/**
 重发状态

 @param cell <#cell description#>
 */
- (void)chatCell:(PhotonBaseChatCell *)cell resendChatMessage:(nullable PhotonBaseChatItem *)chatItem;

/**
 长按事件，处理

 @param chatItem chatItem description
 @param rect <#rect description#>
 */
- (void)chatCell:(PhotonBaseChatCell *)cell chatMessageCellLongPress:(nullable PhotonBaseChatItem *)chatItem rect:(CGRect)rect;


/**
 单击事件

 @param chatItem <#chatItem description#>
 */
- (void)chatCell:(PhotonBaseChatCell *)cell chatMessageCellTap:(nullable PhotonBaseChatItem *)chatItem;
@end

@interface PhotonBaseChatCell : PhotonTableViewCell
@property (nonatomic, weak, nullable)id<PhotonBaseChatCellDelegate> delegate;
/**
 文字背景
 */
@property (nonatomic, strong, readonly, nullable)UIImageView *contentBackgroundView;

@property (nonatomic, strong, readonly, nullable)UIButton *avatarBtn;

- (void)longPressBGView:(UIGestureRecognizer *)gestureRecognizer;

- (void)tapBackgroundView;
- (void)subview_layout;
@end

NS_ASSUME_NONNULL_END
