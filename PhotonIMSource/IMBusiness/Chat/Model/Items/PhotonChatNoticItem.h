//
//  PhotonChatNoticItem.h
//  PhotonIM
//
//  Created by Bruce on 2019/7/23.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseTableItem.h"
#import "PhotonBaseChatItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface PhotonChatNoticItem : PhotonBaseTableItem
/**
 撤回的显示文本
 */
@property (nonatomic, copy, nullable)NSString  *notic;
@end

NS_ASSUME_NONNULL_END
