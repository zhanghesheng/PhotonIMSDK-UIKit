//
//  PhotonChatData.m
//  PhotonIM
//
//  Created by Bruce on 2019/11/28.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonChatData.h"

@implementation PhotonChatData
- (instancetype)init
{
    self = [super init];
    if (self) {
        _sendContent = @"测试";
        _totalMsgCount = 1000;
        _msgInterval = 1000;
        _sendedMessageCount = 0;
        _sendedSuccessedCount = 0;
        _sendedFailedCount = 0;
        _sendedFailedCount = 0;
        _toStart = NO;
    }
    return self;
}
- (void)resetRecord{
   _sendedMessageCount = 0;
   _sendedSuccessedCount = 0;
   _sendedFailedCount = 0;
   _sendedFailedCount = 0;
}
@end
