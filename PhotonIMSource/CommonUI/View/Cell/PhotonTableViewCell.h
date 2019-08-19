//
//  PhotonTableViewCell.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PotonBaseTableViewCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface PhotonTableViewCell : PotonBaseTableViewCell
@property(nonatomic, strong, nullable) id object;
@property(nonatomic, strong, nullable) id item;
@property(nonatomic, weak,nullable) CALayer *lineLayer;
+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object;
@end

NS_ASSUME_NONNULL_END
