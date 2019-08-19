//
//  PhotonScreenImageCell.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface PhotonScreenImageCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) CGFloat imageZoomScale;
@property (nonatomic, assign, readonly) CGRect imageZoomRect;

- (void)startLoading;
- (void)stopLoading;
@end

NS_ASSUME_NONNULL_END
