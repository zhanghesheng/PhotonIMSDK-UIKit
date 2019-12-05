//
//  PhotonGroupContactCell.h
//  PhotonIM
//
//  Created by Bruce on 2019/9/23.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseContactCell.h"

NS_ASSUME_NONNULL_BEGIN
@class PhotonGroupContactCell;
@protocol PhotonGroupContactCellDelegate <NSObject>

- (void)cellEnterGroup:(PhotonGroupContactCell *)cell item:(id)item;

@end

@interface PhotonGroupContactCell : PhotonBaseContactCell
@property(nonatomic, weak, nullable)id<PhotonGroupContactCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
