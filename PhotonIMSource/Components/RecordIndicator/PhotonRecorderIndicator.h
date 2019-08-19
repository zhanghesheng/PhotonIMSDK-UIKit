//
//  PhotonRecorderIndicator.h
//  PhotonIM
//
//  Created by Bruce on 2019/7/8.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PhotonRecorderStatus) {
    PhotonRecorderStatusRecording,
    PhotonRecorderStatusWillCancel,
    PhotonRecorderStatusTooShort,
};

@interface PhotonRecorderIndicator : UIView

@property (nonatomic, assign) PhotonRecorderStatus status;

/**
 *  音量大小，取值（0-1）
 */
@property (nonatomic, assign) CGFloat volume;

@end
NS_ASSUME_NONNULL_END
