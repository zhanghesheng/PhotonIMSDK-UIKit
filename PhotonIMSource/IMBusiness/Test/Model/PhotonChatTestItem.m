//
//  PhotonConversationItem.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/26.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonChatTestItem.h"

@implementation PhotonChatTestItem
- (instancetype)init
{
    self = [super init];
    if (self) {
        _isStartChat = NO;
    }
    return self;
}
- (CGFloat)itemHeight{
    return 81.0;
}
@end
