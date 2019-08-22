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
    user.userID = @"10015";
    user.nickName = @"text1";
    user.userName = @"text1";
    user.sessionID = @"awddercdfdfsx";
    return user;
}

- (PhotonUser *)getFriendInfo:(NSString *)fid{
    return nil;
}

- (void)requestLoginToken:(void (^)(BOOL, NSString * _Nullable))completion{
    if (completion) {
        completion(YES,@"D6813718-1155-6160-DE1D-142ABCD62A30");
    }
}
@end
