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

- (void)uploadImage:(NSString *)filePath completion:(void (^)(BOOL, NSString * _Nullable, NSString * _Nullable))completion{
    if (completion) {
    completion(YES,@"http://img.momocdn.com/moment/07/72/07722C60-C9F7-31A4-DB5C-7B6A3124FA8020190822_L.jpg",nil);
    
    }
}
@end
