//
//  PhotonBaseChatItem.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseChatItem.h"

@implementation PhotonBaseChatItem
- (instancetype)init
{
    self = [super init];
    if (self) {
        _avatalarImgaeURL = @"";
        _tempItemHeight = 0;
         _size = CGSizeZero;
    }
    return self;
}
- (void)setTimeStamp:(uint64_t)timeStamp{
    _timeStamp = timeStamp;
    NSTimeInterval tempTimeStamp = (_timeStamp/1000.0);
    NSDate *localeDate = [NSDate dateWithTimeIntervalSince1970:tempTimeStamp];
    _showTime = [PhotonUtil itemNeedShowTime:localeDate];
    if (_timeText.length == 0) {
        _timeText = [localeDate chatTimeInfo];
    }
}

- (CGFloat)itemHeight{
    CGFloat timeHeight = self.showTime?TIMELABEL_HEIGHT + TIMELABEL_SPACE_Y + AVATAR_SPACE_Y:AVATAR_SPACE_Y;
    CGFloat contentHeight = self.contentSize.height + MSG_SPACE_TOP + MSG_SPACE_BTM;
    CGFloat tipContentHeight = [self.tipText isNotEmpty]?TIPLABEL_HEIGHT+TIPLABEL_SPACE_Y + TIPLABEL_SPACE_Y:TIMELABEL_SPACE_Y;
    _tempItemHeight = timeHeight + contentHeight + tipContentHeight;
    return _tempItemHeight;
}

- (BOOL)canWithDrawMsg{
    NSTimeInterval currentTimeStamp = [[NSDate date]timeIntervalSince1970];
    NSTimeInterval msgTimeStamp = (_timeStamp/1000.0);
    return ((currentTimeStamp - msgTimeStamp) < 2 * 60);
}

@end
