//
//  PhotonAudioRecorder.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
// 语音录制例子，暂时支持wav格式

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class PhotonAudioRecorder;
@protocol PhotonAudioRecorderDelegate <NSObject>

@optional
- (void)audioRecorder:(nullable PhotonAudioRecorder *)recorder volume:(CGFloat)volume;
- (void)finishAudioRecorder:(nullable PhotonAudioRecorder *)recorder time:(CGFloat)time;
- (void)audioRecorderTimeTooShort:(nullable PhotonAudioRecorder *)recorder;
- (void)cancleAudioRecorder:(nullable PhotonAudioRecorder *)recorder;
@end

@interface PhotonAudioRecorder : NSObject
@property (nonatomic, copy, readonly, nullable) NSString *cachePath;
@property (nonatomic, weak, nullable)id<PhotonAudioRecorderDelegate> delegate;
- (void)startRecording;
- (void)stopRecording;
- (void)cancleRecording;
@end

NS_ASSUME_NONNULL_END
