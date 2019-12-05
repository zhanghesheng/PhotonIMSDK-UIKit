//
//  PhotonConversationBaseCell.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/26.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN
@class PhotonTableViewCell;
@class PhotonChatTestItem;
@protocol PhotonChatTestBaseCellDelegate <NSObject>

@optional
/**
 点击头像事件代理
 
 @param cell <#cell description#>
 */
- (void)conCell:(PhotonTableViewCell *)cell didSelectAvatar:(nullable PhotonChatTestItem *)chatItem;

- (void)startChatCell:(PhotonTableViewCell *)cell startChat:(nullable PhotonChatTestItem *)chatItem;
- (void)clearChatCell:(nullable PhotonTableViewCell *)cell clearData:(nullable PhotonChatTestItem *)chatItem;
@end
@interface PhotonChatTestBaseCell : PhotonTableViewCell
@property (nonatomic, weak, nullable)id<PhotonChatTestBaseCellDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
