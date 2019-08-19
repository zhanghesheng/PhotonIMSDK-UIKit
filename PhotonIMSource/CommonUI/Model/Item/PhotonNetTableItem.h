//
//  PhotonNetTableItem.h
//  PhotonIM
//
//  Created by Bruce on 2019/7/5.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotonBaseTableItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface PhotonNetTableItem : PhotonBaseTableItem
@property (nonatomic, copy, nullable)NSString *title;
@property (nonatomic, copy, nullable)NSString *message;
@end

NS_ASSUME_NONNULL_END
