//
//  PhotonPersonCell.h
//  PhotonIM
//
//  Created by Bruce on 2019/7/2.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonTableViewCell.h"
#import "PhotonBaseTableItem.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,PhotonPersonItemType) {
    PhotonPersonItemTypeEmpty,
    PhotonPersonItemTypeAvatar,
    PhotonPersonItemTypeAccount,
    PhotonPersonItemTypeNick,
    PhotonPersonItemTypeBTN,
};
@interface PhotonPersonItem : PhotonBaseTableItem
@property (nonatomic, copy, nullable)NSString *key;
@property (nonatomic, copy, nullable)NSString *value;
@property (nonatomic, strong, nullable)UIColor *valueColor;
@property (nonatomic, assign)PhotonPersonItemType type;
@property (nonatomic, assign)BOOL shorArrow;
@end

@protocol PhotonPersonCellDelegate <NSObject>
- (void)logout:(id)cell;
@end
@interface PhotonPersonCell : PhotonTableViewCell
@property(nonatomic, weak,nullable)id<PhotonPersonCellDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
