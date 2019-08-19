//
//  PhotonChatTransmitModel.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/31.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonChatTransmitModel.h"
#import "PhotonChatTransmitItem.h"
#import "PhotonEmptyTableItem.h"
#import "PhotonTitleTableItem.h"
@implementation PhotonChatTransmitModel
- (void)loadItems:(NSDictionary *)params finish:(void (^)(NSDictionary * _Nullable))finish failure:(void (^)(PhotonErrorDescription * _Nullable))failure{
    [super loadItems:params finish:finish failure:failure];
    PhotonTitleTableItem *titleItem = [[PhotonTitleTableItem alloc] init];
    titleItem.title = @"最近会话";
    [self.items addObject:titleItem];
    NSArray<PhotonIMConversation *> *conversations = [[PhotonIMClient sharedClient] findConversationList:0 size:INT_MAX asc:NO];
    for (PhotonIMConversation *conversation in conversations) {
        PhotonUser *user = [PhotonContent friendDetailInfo:conversation.chatWith];
        PhotonChatTransmitItem *item = [[PhotonChatTransmitItem alloc] init];
        item.fNickName = user.nickName?user.nickName:conversation.chatWith;
        item.fIcon = user.avatarURL;
        item.selected = NO;
        item.userInfo = conversation;
        [self.items addObject:item];
    }
    if(self.items.count > 0){
        if (finish) {
            finish(nil);
        }
    }
    PhotonEmptyTableItem *emptyItem = [[PhotonEmptyTableItem alloc] init];
    emptyItem.itemHeight = 10.5f;
     emptyItem.backgroudColor = [UIColor clearColor];
    [self.items addObject:emptyItem];
    
    PhotonTitleTableItem *titleItem1 = [[PhotonTitleTableItem alloc] init];
    titleItem1.title = @"在线好友";
    [self.items addObject:titleItem1];
    PhotonWeakSelf(self);
    [self.netService commonRequestMethod:PhotonRequestMethodPost queryString:@"photonimdemo/contact/onlineUser" paramter:nil completion:^(NSDictionary * _Nonnull responseDict) {
        [weakself wrappResponseddDict:responseDict];
        if (finish) {
            finish(nil);
        }
        [PhotonUtil hiddenLoading];
    } failure:^(PhotonErrorDescription * _Nonnull error) {
        if (finish) {
            finish(nil);
        }
    }];
}

- (void)wrappResponseddDict:(NSDictionary *)dict{
    [super wrappResponseddDict:dict];
    NSDictionary *data = [dict objectForKey:@"data"];
    if (data.count > 0) {
        NSArray *lists = [data objectForKey:@"lists"];
        if (lists.count > 0) {
            for (NSDictionary *item in lists) {
                PhotonIMConversation *conversation = [[PhotonIMConversation alloc] init];
                conversation.chatWith = [[item objectForKey:@"userId"] isNil];
                conversation.FName = [[item objectForKey:@"nickname"] isNil];
                conversation.FAvatarPath = [[item objectForKey:@"avatar"] isNil];

                PhotonChatTransmitItem *item = [[PhotonChatTransmitItem alloc] init];
                item.fNickName = conversation.FName?conversation.FName:conversation.chatWith;
                item.fIcon = conversation.FAvatarPath;
                item.selected = NO;
                item.userInfo = conversation;
                [self.items addObject:item];
            }
        }
    }
}
@end
