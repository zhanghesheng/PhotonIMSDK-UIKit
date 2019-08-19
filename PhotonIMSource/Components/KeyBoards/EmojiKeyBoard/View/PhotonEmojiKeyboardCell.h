//
//  PhotonEmojiKeyboardCell.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/20.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PhotonEmojiKeyboardItem;
@interface PhotonEmojiKeyboardCell : UICollectionViewCell
- (void)bindItem:(PhotonEmojiKeyboardItem *)item;
@end

NS_ASSUME_NONNULL_END
