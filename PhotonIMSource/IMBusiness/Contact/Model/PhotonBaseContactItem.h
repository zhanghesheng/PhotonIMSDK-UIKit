//
//  PhotonBaseContactItem.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/27.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotonBaseTableItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface PhotonBaseContactItem : PhotonBaseTableItem

/**
 好友id
 */
@property (nonatomic, copy, nullable) NSString *contactID;

/**
 好友头像
 */
@property (nonatomic, copy, nullable) NSString *contactAvatar;

/**
 昵称
 */
@property (nonatomic, copy, nullable) NSString *contactName;


/**
 昵称
 */
@property (nonatomic, copy, nullable) NSString *contactIcon;

@end

NS_ASSUME_NONNULL_END
