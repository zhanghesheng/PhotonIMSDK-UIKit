//
//  PhotonChatTransmitCell.h
//  PhotonIM
//
//  Created by Bruce on 2019/7/31.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseContactCell.h"

NS_ASSUME_NONNULL_BEGIN
@protocol PhotonChatTransmitCellDelegate <NSObject>

- (void)cell:(id)cell selectedItem:(id)item;

@end
@interface PhotonChatTransmitCell : PhotonBaseContactCell
@property (nonatomic, weak, nullable)id<PhotonChatTransmitCellDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
