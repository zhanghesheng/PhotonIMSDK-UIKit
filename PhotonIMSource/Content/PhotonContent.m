//
//  PhotonContent.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonContent.h"
#import "PhotonMessageCenter.h"
@interface PhotonContent()
@property(nonatomic, strong, nullable)PhotonUser *currentUser;
@end
@implementation PhotonContent
+ (instancetype)sharedInstance{
    static PhotonContent *content = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        content = [[PhotonContent alloc] init];
    });
    return content;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentUser = [[PhotonUser alloc] init];
       id user = [[NSUserDefaults standardUserDefaults] objectForKey:@"photon_current_user"];
        if ([user isKindOfClass:[NSDictionary class]]) {
            NSDictionary *userDict = user;
            _currentUser.userID = [userDict objectForKey:@"photon_user_id"];
            _currentUser.userName = [userDict objectForKey:@"photon_user_name"];
            _currentUser.sessionID = [userDict objectForKey:@"photon_user_sessionid"];
        }
    }
    return self;
}
+ (id<UIApplicationDelegate>)sharedAppDelegate
{
    __block id appDelegate = nil;
    
    if ([NSThread isMainThread]) {
        appDelegate = [[UIApplication sharedApplication] delegate];
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            appDelegate = [[UIApplication sharedApplication] delegate];
        });
    }
    
    return appDelegate;
}
+ (PhotonUser *)currentUser{
    return [PhotonContent sharedInstance].currentUser;
}
+ (PhotonUser *)userDetailInfo{
    // TODO: 在数据库中获取当前用户的信息，接入方可接入自己的实现方式处理profile
    if (([PhotonMessageCenter sharedCenter].handler && [[PhotonMessageCenter sharedCenter].handler respondsToSelector:@selector(getCurrentUserInfo)])) {
        return [[PhotonMessageCenter sharedCenter].handler getCurrentUserInfo];
    }
    return nil;
}

+ (PhotonUser *)friendDetailInfo:(NSString *)fid{
    if (([PhotonMessageCenter sharedCenter].handler && [[PhotonMessageCenter sharedCenter].handler respondsToSelector:@selector(getFriendInfo:)])) {
        return [[PhotonMessageCenter sharedCenter].handler getFriendInfo:fid];
    }
    return nil;
}
@end
