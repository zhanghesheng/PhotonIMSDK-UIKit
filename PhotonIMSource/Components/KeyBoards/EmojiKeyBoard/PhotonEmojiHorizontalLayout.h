//
//  PhotonEmojiHorizontalLayout.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/20.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotonEmojiHorizontalLayout : UICollectionViewFlowLayout
@property (nonatomic,assign,readonly) NSUInteger pageCount;
@property (nonatomic,assign) NSUInteger itemCount;

+ (CGFloat)heightOfCollectionView;
@end

NS_ASSUME_NONNULL_END
