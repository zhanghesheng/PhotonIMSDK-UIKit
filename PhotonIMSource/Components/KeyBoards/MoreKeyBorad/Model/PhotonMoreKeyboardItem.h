//
//  PhotonMoreKeyboardItem.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, PhotonMoreKeyboardItemType) {
    PhotonMoreKeyboardItemTypeImage,
    PhotonMoreKeyboardItemTypeCamera,
};

@interface PhotonMoreKeyboardItem : NSObject
@property (nonatomic, assign) PhotonMoreKeyboardItemType type;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *imagePath;

+ (PhotonMoreKeyboardItem *)createByType:(PhotonMoreKeyboardItemType)type title:(NSString *)title imagePath:(NSString *)imagePath;
@end

NS_ASSUME_NONNULL_END
