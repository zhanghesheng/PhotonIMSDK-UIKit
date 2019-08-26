//
//  PhotonUser.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonUser.h"
#import "PhotonNetworkService.h"
@interface PhotonUser()
@property (nonatomic, strong, nullable)PhotonNetworkService *netService;
@end

@implementation PhotonUser
- (instancetype)initWithUserId:(NSString *)userid userName:(NSString *)userName avartarURL:(nullable NSString *)avartarURL{
    self = [super init];
    if (self) {
        _userID = userid;
        _userName = userName;
        _nickName = userName;
        _avatarURL = avartarURL;
    }
}
- (void)loadFriendProfile{
    __weak typeof(self)weakSelf = self;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [self.netService commonRequestMethod:PhotonRequestMethodPost queryString:@"photonimdemo/user/my/profile" paramter:dict completion:^(NSDictionary * _Nonnull responseDict) {
        [weakSelf wrappFriendProfileDict:responseDict];
    } failure:^(PhotonErrorDescription * _Nonnull error) {
    }];
}
- (void)loadFriendProfileBatch:(NSArray *)remoteids completion:(void(^)(BOOL success))completion{
    if (remoteids.count == 0) {
        if (completion) {
            completion(YES);
        }
    }
    NSString *ids = [remoteids componentsJoinedByString:@","];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:ids forKey:@"remoteids"];
    PhotonWeakSelf(self)
    [self.netService commonRequestMethod:PhotonRequestMethodPost queryString:@"photonimdemo/user/remote/profiles" paramter:dict completion:^(NSDictionary * _Nonnull responseDict) {
        [weakself wrappFriendProfileBatchDict:responseDict];
        if (completion) {
            completion(YES);
        }
    } failure:^(PhotonErrorDescription * _Nonnull error) {
        if (completion) {
            completion(NO);
        }
    }];
}
- (void)wrappFriendProfileBatchDict:(NSDictionary *)responseDict {
    NSDictionary *data = [responseDict objectForKey:@"data"];
    if (data.count > 0) {
        NSArray *lists = [data objectForKey:@"lists"];
        for (NSDictionary *profile in lists) {
            if (profile.count > 0) {
                PhotonUser *user = [[PhotonUser alloc] init];
                user.userID = [[profile objectForKey:@"userId"] isNil];
                user.nickName = [[profile objectForKey:@"nickname"] isNil];
                user.avatarURL = [[profile objectForKey:@"avatar"] isNil];
            }
        }
       
    }
}

- (void)loadFriendProfile:(NSString *)remoteid completion:(void(^)(BOOL success))completion{
    __weak typeof(self)weakSelf = self;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:remoteid forKey:@"remoteid"];
    [self.netService commonRequestMethod:PhotonRequestMethodPost queryString:@"photonimdemo/user/remote/profile" paramter:dict completion:^(NSDictionary * _Nonnull responseDict) {
        [weakSelf wrappFriendProfileDict:responseDict];
        if (completion) {
            completion(YES);
        }
    } failure:^(PhotonErrorDescription * _Nonnull error) {
        if (completion) {
            completion(NO);
        }
    }];
}

- (void)wrappFriendProfileDict:(NSDictionary *)responseDict {
    NSDictionary *data = [responseDict objectForKey:@"data"];
    if (data.count > 0) {
        NSDictionary *profile = [data objectForKey:@"profile"];
        if (profile.count > 0) {
            PhotonUser *user = [[PhotonUser alloc] init];
            user.userID = [[profile objectForKey:@"userId"] isNil];
            user.nickName = [[profile objectForKey:@"nickname"] isNil];
            user.avatarURL = [[profile objectForKey:@"avatar"] isNil];
        }
    }
}

- (void)getIgnoreAlert:(NSString *)remoteId completion:(void(^)(BOOL success,BOOL open))completion{
    NSMutableDictionary *paramter = [NSMutableDictionary dictionary];
    [paramter setValue:remoteId forKey:@"remoteid"];
    [self.netService commonRequestMethod:PhotonRequestMethodPost queryString:@"photonimdemo/setting/msg/getP2pRemind" paramter:paramter completion:^(NSDictionary * _Nonnull dict) {
        NSDictionary *data = dict[@"data"];
        if (data.count > 0) {
            id switch_ = data[@"switch"];
            if (completion && [switch_ isKindOfClass:[NSNumber class]]) {
                completion(YES,[switch_ boolValue]);
            }
        }else{
            if (completion) {
                completion(NO,NO);
            }
        }
    } failure:^(PhotonErrorDescription * _Nonnull error) {
        if (completion) {
            completion(NO,NO);
        }
    }];
}


- (PhotonNetworkService *)netService{
    if (!_netService) {
        _netService = [[PhotonNetworkService alloc] init];
        _netService.baseUrl = PHOTON_BASE_URL;
        
    }
    return _netService;
}
@end
