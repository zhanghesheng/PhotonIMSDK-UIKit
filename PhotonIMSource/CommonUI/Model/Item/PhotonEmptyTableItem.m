//
//  PhotonEmptyTableItem.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/8.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonEmptyTableItem.h"

@implementation PhotonEmptyTableItem
- (instancetype)init
{
    self = [super init];
    if (self) {
        _backgroudColor = [UIColor clearColor];
    }
    return self;
}

- (CGFloat)itemHeight{
    return 20.0;
}
@end
