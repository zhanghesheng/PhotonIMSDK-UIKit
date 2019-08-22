//
//  PhotonConversationModel.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/26.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonConversationModel.h"
#import "PhotonConversationItem.h"
#import "PhotonMessageCenter.h"
#import <MMKV/MMKV.h>
@interface PhotonConversationModel()
@property (nonatomic, strong)NSMutableArray  *cache;
@end

@implementation PhotonConversationModel
- (void)loadItems:(nullable NSDictionary *)params finish:(void (^)(NSDictionary * _Nullable))finish failure:(void (^)(PhotonErrorDescription * _Nullable))failure{
    [super loadItems:params finish:finish failure:failure];
    NSArray<PhotonIMConversation *> *conversations = [[PhotonIMClient sharedClient] findConversationList:0 size:200 asc:NO];
    if (conversations.count > 0) {
        NSMutableArray *chatWiths = [NSMutableArray array];
        for (PhotonIMConversation *conversation in  conversations) {
             PhotonUser *user = [PhotonContent friendDetailInfo:conversation.chatWith];
            if (!user) {
                [chatWiths addObject:conversation.chatWith];
            }
        }
        PhotonWeakSelf(self)
        [[PhotonContent currentUser] loadFriendProfileBatch:chatWiths completion:^(BOOL success) {
             [weakself.items removeAllObjects];
            for (PhotonIMConversation *conversation in  conversations){
                PhotonUser *tempUser = [PhotonContent friendDetailInfo:conversation.chatWith];
                conversation.FAvatarPath = tempUser.avatarURL;
                conversation.FName = tempUser.nickName;
                PhotonConversationItem *conItem = [[PhotonConversationItem alloc] init];
                conItem.userInfo = conversation;
                [weakself.items addObject:conItem];
            }
            [PhotonUtil runMainThread:^{
                if (finish) {
                    finish(nil);
                }
            }];
        }];
    }
    BOOL excute = [[MMKV defaultMMKV] getBoolForKey:[PhotonContent userDetailInfo].userID];
    if (conversations.count == 0 && !excute) {
        [[MMKV defaultMMKV] setBool:YES forKey:[PhotonContent userDetailInfo].userID];
        __weak typeof(self)weakSelf = self;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if (params && params.count > 0) {
            [dict addEntriesFromDictionary:params];
        }
        [self.netService commonRequestMethod:PhotonRequestMethodPost queryString:@"photonimdemo/contact/recentUser" paramter:dict completion:^(NSDictionary * _Nonnull responseDict) {
            [weakSelf wrappResponseddDict:responseDict];
            [PhotonUtil runMainThread:^{
                if (finish) {
                    finish(nil);
                }
            }];
        } failure:^(PhotonErrorDescription * _Nonnull error) {
        }];
    }
}


/**
 <#Description#>

 @param dict <#dict description#>
 */
- (void)wrappResponseddDict:(NSDictionary *)dict{
    [self.items removeAllObjects];
    [super wrappResponseddDict:dict];
    NSMutableArray<PhotonIMConversation *> *conversations = [[NSMutableArray alloc] init];
    NSDictionary *data = [dict objectForKey:@"data"];
    if (data.count > 0) {
        NSArray *lists = [data objectForKey:@"lists"];
        PhotonLog(@"history session data count: %@",@([lists count]));
        if (lists.count > 0) {
            for (NSDictionary *item in lists) {
                PhotonIMConversation *conversation = [[PhotonIMConversation alloc] init];
                conversation.CID = [[item objectForKey:@"userId"] isNil];
                conversation.chatWith = [[item objectForKey:@"userId"] isNil];
                conversation.FName = [[item objectForKey:@"nickname"] isNil];
                conversation.FAvatarPath = [[item objectForKey:@"avatar"] isNil];
                int type = [[[item objectForKey:@"type"] isNil] intValue];
                conversation.chatType = (PhotonIMChatType)type;
                [conversations addObject:conversation];
                PhotonConversationItem *conItem = [[PhotonConversationItem alloc] init];
                conItem.userInfo = conversation;
                [self.items addObject:conItem];
            }
        }
    }
    if (conversations.count) {
         [[PhotonIMClient sharedClient] saveConversationBatch:conversations];
    }
}

- (NSMutableArray *)cache{
    if (!_cache) {
        _cache = [NSMutableArray array];
    }
    return _cache;
}
@end
