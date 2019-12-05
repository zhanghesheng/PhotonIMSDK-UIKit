//
//  PhotonMessageSettingViewController.h
//  PhotonIM
//
//  Created by Bruce on 2019/7/31.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseViewController.h"
#import "PhotonMessageCenter.h"
NS_ASSUME_NONNULL_BEGIN
@interface PhotonSingleSettingDataSource : PotonTableViewDataSource
@end
@interface PhotonSingleSettingViewController : PhotonBaseViewController
- (instancetype)initWithConversation:(PhotonIMConversation *)conversation;
@end

NS_ASSUME_NONNULL_END
