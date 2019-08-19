//
//  PhotonMoreKeyBoard.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotonBaseKeyBoard.h"
#import "PhotonMoreKeyboardItem.h"
NS_ASSUME_NONNULL_BEGIN
@protocol PhotonMoreKeyBoardDelegate <NSObject>
@optional
- (void)moreKeyboard:(id)keyboard didSelectedKeyboardItem:(PhotonMoreKeyboardItem *)item;

@end

@interface PhotonMoreKeyBoard :PhotonBaseKeyBoard
@property (nonatomic, weak,nullable) id<PhotonMoreKeyBoardDelegate> delegate;

@property (nonatomic,copy,nullable) NSArray *chatMoreKeyboardItems;

@property (nonatomic, strong,nullable) UICollectionView *collectionView;

@property (nonatomic, strong,nullable) UIPageControl *pageControl;
+ (instancetype)sharedKeyBoard;
@end

NS_ASSUME_NONNULL_END
