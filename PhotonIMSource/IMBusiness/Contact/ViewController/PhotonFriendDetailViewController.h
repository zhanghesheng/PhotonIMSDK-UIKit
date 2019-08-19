//
//  PhotonFriendDetailViewController.h
//  PhotonIM
//
//  Created by Bruce on 2019/7/2.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseViewController.h"
#import "PhotonMacros.h"
NS_ASSUME_NONNULL_BEGIN

@interface PhotonFriendDetailViewController : PhotonBaseViewController
- (instancetype)initWithFriend:(PhotonUser *)user;
- (instancetype)initWithUserid:(NSString *)userid;
@end

NS_ASSUME_NONNULL_END
