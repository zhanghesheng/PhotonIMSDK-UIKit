//
//  PhotonMoreKeyboardCell.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotonMoreKeyboardItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface PhotonMoreKeyboardCell : UICollectionViewCell
@property (nonatomic, strong,nullable) PhotonMoreKeyboardItem *item;

@property (nonatomic, strong) void(^clickBlock)(PhotonMoreKeyboardItem *item);
@end

NS_ASSUME_NONNULL_END
