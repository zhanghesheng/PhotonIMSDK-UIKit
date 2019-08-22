//
//  PhotonIMSDKMessageHandler.m
//  PhotonIMSDKUIKitDemo
//
//  Created by Bruce on 2019/8/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonIMSDKMessageHandler.h"

@implementation PhotonIMSDKMessageHandler
- (PhotonUser *)getCurrentUserInfo{
    PhotonUser *user = [[PhotonUser alloc] init];
    user.userID = @"12345";
    user.nickName = @"text1";
    user.userName = @"text1";
    user.sessionID = @"awddercdfdfsx";
    return user;
}

- (PhotonUser *)getFriendInfo:(NSString *)fid{
    return nil;
}
@end
