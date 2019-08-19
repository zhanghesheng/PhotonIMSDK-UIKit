//
//  PhotonContactItem.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/27.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotonBaseTableItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface PhotonContactItem : PhotonBaseTableItem

/**
 好友id
 */
@property (nonatomic, copy, nullable) NSString *fID;

/**
 好友头像
 */
@property (nonatomic, copy, nullable) NSString *fIcon;

/**
 昵称
 */
@property (nonatomic, copy, nullable) NSString *fNickName;
@end

NS_ASSUME_NONNULL_END
