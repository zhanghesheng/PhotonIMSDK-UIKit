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
@class PhotonConversationItem;
@protocol PhotonConversationBaseCellDelegate <NSObject>

@optional
/**
 点击头像事件代理
 
 @param cell <#cell description#>
 */
- (void)conCell:(PhotonTableViewCell *)cell didSelectAvatar:(nullable PhotonConversationItem *)chatItem;
@end
@interface PhotonConversationBaseCell : PhotonTableViewCell
@property (nonatomic, weak, nullable)id<PhotonConversationBaseCellDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
