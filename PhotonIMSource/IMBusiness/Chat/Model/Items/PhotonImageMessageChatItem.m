//
//  PhotonImageMessageChatItem.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/22.
//  Copyright © 2019 Bruce. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PhotonImageMessageChatItem.h"
@implementation PhotonImageMessageChatItem
- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageSize = CGSizeZero;
        _whRatio = 0;
    }
    return self;
}

- (CGSize)imageSize{
    _whRatio  = _imageSize.width/_imageSize.height;
    return _imageSize;
}
- (CGSize)contentSize{
    CGFloat scale = 1.0 / self.whRatio;
    if (isinf(scale)) {
        scale = [UIScreen mainScreen].scale;
    }
    CGSize imageSize = CGSizeZero;
    CGFloat defaultWith = PhotoScreenWidth * 0.58;
    CGFloat realHeight = defaultWith * scale;
    imageSize = CGSizeMake(defaultWith, realHeight);
    _imageSize = imageSize;
    return imageSize;
}
- (CGFloat)itemHeight{
    return [super itemHeight];
}

@end
