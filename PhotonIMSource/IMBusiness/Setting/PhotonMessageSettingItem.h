//
//  PhotonMessageSettingItem.h
//  PhotonIM
//
//  Created by Bruce on 2019/7/31.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseTableItem.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, PhotonMessageSettingType){
    PhotonMessageSettingTypeIgnorSticky = 1,
    PhotonMessageSettingTypeIgnoreAlert
};
@interface PhotonMessageSettingItem : PhotonBaseTableItem
@property (nonatomic, copy, nullable) NSString *settingName;
@property (nonatomic, assign) PhotonMessageSettingType type;
@property (nonatomic, assign) BOOL open;
@end

NS_ASSUME_NONNULL_END
