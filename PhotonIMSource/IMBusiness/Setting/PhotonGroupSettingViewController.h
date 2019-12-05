//
//  PhotonGroupSettingViewController.h
//  PhotonIM
//
//  Created by Bruce on 2019/9/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseViewController.h"
#import "PhotonMessageCenter.h"
NS_ASSUME_NONNULL_BEGIN
@interface PhotonGroupSettingDataSource : PotonTableViewDataSource
@end
@interface PhotonGroupSettingViewController : PhotonBaseViewController
- (instancetype)initWithGroupID:(PhotonIMConversation *)conversation;
@end

NS_ASSUME_NONNULL_END
