//
//  PhotonIMSDKMessageHandler.m
//  PhotonIMSDKUIKitDemo
//
//  Created by Bruce on 2019/8/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonIMSDKMessageHandler.h"

@implementation PhotonIMSDKMessageHandler

// 当前用户的消息
- (PhotonUser *)getCurrentUserInfo{
    
    PhotonUser *user = [[PhotonUser alloc] initWithUserId:@"10015" userName:@"text1" avartarURL:@"http://img.momocdn.com/moment/07/72/07722C60-C9F7-31A4-DB5C-7B6A3124FA8020190822_L.jpg"];
    return user;
}

- (PhotonUser *)getFriendInfo:(NSString *)fid{
    // 业务端的profile中获取好友的信息h构建PhotonUser对象
    return nil;
}

// 业务端获取 im 登录的token
- (void)requestLoginToken:(void (^)(BOOL, NSString * _Nullable))completion{
    if (completion) {
        completion(YES,@"D6813718-1155-6160-DE1D-142ABCD62A30");
    }
}

// h告知业务端登录是否成功
- (void)loginSucceed:(BOOL)succeed{
    // 登录失败，重新登录调用login或者回到登录界面重新登录
    if (!succeed) {
        
    }
}

// 账号被踢，回到业务层界面重新登录
- (void)KickAccount{
    
}

// 业务层处理图片的上传操作
- (void)uploadImage:(NSString *)filePath completion:(void (^)(BOOL, NSString * _Nullable, NSString * _Nullable))completion{
    if (completion) {
        completion(YES,@"http://img.momocdn.com/moment/07/72/07722C60-C9F7-31A4-DB5C-7B6A3124FA8020190822_L.jpg",nil);
    }
}

// 业务层处理语音的上传操作
- (void)uploadVoice:(NSString *)filePath completion:(void (^)(BOOL, NSString * _Nullable))completion{
    if (completion) {
        completion(YES,@"http://img.momocdn.com/moment/07/72/07722C60-C9F7-31A4-DB5C-7B6A3124FA8020190822_L.jpg");
    }
}
@end
