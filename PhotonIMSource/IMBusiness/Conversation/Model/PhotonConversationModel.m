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
@interface PhotonConversationModel()
@property (nonatomic, strong)PhotonIMThreadSafeArray  *cache;
@end

@implementation PhotonConversationModel
- (void)loadItems:(nullable NSDictionary *)params finish:(void (^)(NSDictionary * _Nullable))finish failure:(void (^)(PhotonErrorDescription * _Nullable))failure{
    PhotonWeakSelf(self);
        [super loadItems:params finish:finish failure:failure];
        NSArray<PhotonIMConversation *> *conversations = [[PhotonIMClient sharedClient] findConversationList:0 size:200 asc:NO];
        [weakself.items removeAllObjects];
        if (conversations.count > 0) {
            NSMutableArray *chatWiths = [NSMutableArray array];
            for (PhotonIMConversation *conversation in  conversations) {
                PhotonUser *user = [PhotonContent friendDetailInfo:conversation.chatWith];
                conversation.FAvatarPath = user.avatarURL;
                conversation.FName = user.nickName;
                PhotonConversationItem *conItem = [[PhotonConversationItem alloc] init];
                conItem.userInfo = conversation;
                [weakself.items addObject:conItem];
            }
            [PhotonUtil runMainThread:^{
                if (finish) {
                    finish(nil);
                }
            }];
            
           
        }


}


- (PhotonIMThreadSafeArray *)cache{
    if (!_cache) {
        _cache = [PhotonIMThreadSafeArray array];
    }
    return _cache;
}
@end
