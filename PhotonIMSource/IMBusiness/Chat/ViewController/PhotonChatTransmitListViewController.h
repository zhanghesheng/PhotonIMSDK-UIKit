//
//  PhotonChatTransmitListViewController.h
//  PhotonIM
//
//  Created by Bruce on 2019/7/31.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseViewController.h"
#import "PhotonMessageCenter.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^ChatTransmitBlock) (id msg);

@interface PhotonChatTransmitListDataSource : PotonTableViewDataSource
@end
@interface PhotonChatTransmitListViewController : PhotonBaseViewController
- (instancetype)initWithMessage:(PhotonIMMessage *)message block:(nullable ChatTransmitBlock)chatBlock;
@end

NS_ASSUME_NONNULL_END
