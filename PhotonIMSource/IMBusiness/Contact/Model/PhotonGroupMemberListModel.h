//
//  PhotonGroupMemberListModel.h
//  PhotonIM
//
//  Created by Bruce on 2019/9/24.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotonGroupMemberListModel : PhotonBaseModel
@property (nonatomic, assign)NSInteger memberCount;
@property (nonatomic, copy)NSString *gid;
@property (nonatomic, assign)BOOL showSelectBtn;
@end

NS_ASSUME_NONNULL_END
