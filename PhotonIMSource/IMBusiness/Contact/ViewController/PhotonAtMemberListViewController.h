//
//  PhotonGroupMemberListViewController.h
//  PhotonIM
//
//  Created by Bruce on 2019/9/24.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseViewController.h"
#import "PhotonMacros.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^ PhotonAtMemberListBlock)(AtType type,NSArray * _Nullable);

@interface PhotonAtMemberListViewController : PhotonBaseViewController
- (instancetype)initWithGid:(NSString *)gid result:(PhotonAtMemberListBlock)result;
@end

NS_ASSUME_NONNULL_END
