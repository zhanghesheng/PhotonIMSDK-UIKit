//
//  PhotonGroupContactModel.m
//  PhotonIM
//
//  Created by Bruce on 2019/9/23.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonGroupContactModel.h"
#import "PhotonMessageCenter.h"
#import "PhotonBaseContactItem.h"
#import "PhotonGroupContactItem.h"
@implementation PhotonGroupContactModel
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
    [self.netService commonRequestMethod:PhotonRequestMethodPost queryString:@"photonimdemo/contact/groups" paramter:nil completion:^(NSDictionary * _Nonnull responseDict) {
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
            self.items = [PhotonIMThreadSafeArray arrayWithCapacity:lists.count];
            for (NSDictionary *item in lists) {
                PhotonUser *user = [[PhotonUser alloc] init];
                user.userID = [[item objectForKey:@"gid"] isNil];
                user.nickName = [[item objectForKey:@"name"] isNil];
                user.userName = [[item objectForKey:@"name"] isNil];
                user.avatarURL = [[item objectForKey:@"avatar"] isNil];
                user.type = [[item objectForKey:@"type"] isNil]?2:[[[item objectForKey:@"type"] isNil] intValue];
                PhotonGroupContactItem *conItem = [[PhotonGroupContactItem alloc] init];
                conItem.contactAvatar = [[item objectForKey:@"avatar"] isNil];;
                conItem.contactName = [[item objectForKey:@"name"] isNil];
                conItem.contactID = [[item objectForKey:@"gid"] isNil];
                conItem.isInGroup = NO;
                [self.items addObject:conItem];
            }
        }
    }
}


- (void)enterGroup:(NSString *)gid finish:(void (^)(NSDictionary * _Nullable))finish failure:(void (^)(PhotonErrorDescription * _Nullable))failure{
    if (![gid isNotEmpty]) {
        return;
    }
   //  加入群组
}

- (void)sendEnterGroupNoticeMessage:(NSString *)gid{
    
    
    
}
@end
