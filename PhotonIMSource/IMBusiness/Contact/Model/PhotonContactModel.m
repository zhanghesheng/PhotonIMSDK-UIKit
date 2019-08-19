//
//  PhotonContactModel.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/27.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonContactModel.h"
@interface PhotonContactModel()
@end
@implementation PhotonContactModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)loadItems:(nullable NSDictionary *)params finish:(void (^)(NSDictionary * _Nullable))finish failure:(void (^)(PhotonErrorDescription * _Nullable))failure{
    [super loadItems:params finish:finish failure:failure];
    __weak typeof(self)weakSelf = self;
    [PhotonUtil showLoading:nil];
    [self.netService commonRequestMethod:PhotonRequestMethodPost queryString:@"photonimdemo/contact/onlineUser" paramter:nil completion:^(NSDictionary * _Nonnull responseDict) {
        [weakSelf wrappResponseddDict:responseDict];
        if (finish) {
            finish(nil);
        }
        [PhotonUtil hiddenLoading];
    } failure:^(PhotonErrorDescription * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [PhotonUtil hiddenLoading];
    }];
}

- (void)wrappResponseddDict:(NSDictionary *)dict{
    [super wrappResponseddDict:dict];
    NSDictionary *data = [dict objectForKey:@"data"];
    if (data.count > 0) {
        NSArray *lists = [data objectForKey:@"lists"];
        if (lists.count > 0) {
            self.items = [NSMutableArray arrayWithCapacity:lists.count];
            for (NSDictionary *item in lists) {
                PhotonUser *user = [[PhotonUser alloc] init];
                user.userID = [[item objectForKey:@"userId"] isNil];
                user.nickName = [[item objectForKey:@"nickname"] isNil];
                user.avatarURL = [[item objectForKey:@"avatar"] isNil];
                user.type = [[[item objectForKey:@"type"] isNil] intValue];
                [PhotonContent addFriendToDB:user];
                PhotonContactItem *conItem = [[PhotonContactItem alloc] init];
                conItem.fIcon = user.avatarURL;
                conItem.fNickName = user.nickName? user.nickName: user.userID;
                conItem.userInfo = user;
                [self.items addObject:conItem];
            }
        }
    }
}
@end
