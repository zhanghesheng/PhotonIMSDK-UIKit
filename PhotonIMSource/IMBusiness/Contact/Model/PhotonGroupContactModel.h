//
//  PhotonGroupContactModel.h
//  PhotonIM
//
//  Created by Bruce on 2019/9/23.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotonGroupContactModel : PhotonBaseModel
- (void)enterGroup:(NSString *)gid finish:(void (^)(NSDictionary * _Nullable))finish failure:(void (^)(PhotonErrorDescription * _Nullable))failure;
@end

NS_ASSUME_NONNULL_END
