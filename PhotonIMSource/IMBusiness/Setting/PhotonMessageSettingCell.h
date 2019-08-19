//
//  PhotonMessageSettingCell.h
//  PhotonIM
//
//  Created by Bruce on 2019/7/31.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN
@class PhotonMessageSettingItem;
@protocol PhotonMessageSettingCellDelegate <NSObject>

- (void)cell:(id)cell switchItem:(PhotonMessageSettingItem *)item;

@end
@interface PhotonMessageSettingCell : PhotonTableViewCell
@property (nonatomic, weak, nullable)id<PhotonMessageSettingCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
