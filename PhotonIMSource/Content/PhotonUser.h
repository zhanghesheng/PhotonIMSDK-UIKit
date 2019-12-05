//
//  PhotonUser.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotonUser : NSObject
/**
 用户id
 */
@property (nonatomic, copy, nullable)NSString *userID;

/**
 用户名
 */
@property (nonatomic, copy, nullable)NSString *userName;

/**
 用户m昵称
 */
@property (nonatomic, copy, nullable)NSString *nickName;

/**
 头像URL
 */
@property (nonatomic, copy, nullable)NSString *avatarURL;

/**
 头像path
 */
@property (nonatomic, copy, nullable)NSString *avatarPath;

/**
 用户备注
 */
@property (nonatomic, copy, nullable)NSString *remark;

/**
 (1 单人, 2 群)
 */
@property (nonatomic, assign) int type;

- (instancetype)initWithUserId:(NSString *)userid userName:(NSString *)userName avartarURL:(nullable NSString *)avartarURL;

@end

NS_ASSUME_NONNULL_END
