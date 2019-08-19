//
//  PhotonMoreKeyboardItem.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonMoreKeyboardItem.h"

@implementation PhotonMoreKeyboardItem
+ (PhotonMoreKeyboardItem *)createByType:(PhotonMoreKeyboardItemType)type title:(NSString *)title imagePath:(NSString *)imagePath
{
    PhotonMoreKeyboardItem *item = [[PhotonMoreKeyboardItem alloc] init];
    item.type = type;
    item.title = title;
    item.imagePath = imagePath;
    return item;
}
@end
