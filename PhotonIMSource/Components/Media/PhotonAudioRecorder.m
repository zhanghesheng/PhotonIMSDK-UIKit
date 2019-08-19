//
//  PhotonAudioRecorder.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "PhotonAudioRecorder.h"
#import "PhotonMacros.h"

#import <MDAudioKit/MDAudioKit.h>
@interface PhotonAudioRecorder()<AVAudioRecorderDelegate,MDAudioRecorderDelegate>
@property (nonatomic, copy, nullable) NSString *cachePath;
@property (nonatomic, strong, nullable) AVAudioRecorder *recorder;
@property (nonatomic, strong, nullable) NSTimer *timer;

//
@property (nonatomic, strong, nullable)MDAudioRecorder  *audioRecorder;
@end
@implementation PhotonAudioRecorder
- (void)dealloc{
    [self cancleRecording];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _cachePath = [[NSFileManager cachesPath] stringByAppendingPathComponent:@"photon_audio_rec.opus"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showVolumePeak) name:NTF_PEAKANDTIME object:nil];
    }
    return self;
}
- (void)startRecording{
    [self stopRecording];
    [self addAudioBus];
    [self.audioRecorder startRecord];
}

- (void)addAudioBus{
    __weak typeof(self)weakSelf = self;
    MDAudioStreamBus *bus = [[MDAudioStreamBus alloc] initWithOpusPath:_cachePath blockQueue:dispatch_get_main_queue() partEncoded:^(MDAudioStreamBus *bus, NSData *opusBuffer, NSTimeInterval duration, u_int64_t opusFileSize) {
        
    } completion:^(MDAudioStreamBus *bus, BOOL isCancel, NSTimeInterval duration, u_int64_t opusFileSize, NSString *opusFilePath, NSError *error) {
        if (isCancel) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(cancleAudioRecorder:)]) {
                [weakSelf.delegate cancleAudioRecorder:weakSelf];
            }
        }
        BOOL isFail = YES;
        if (!error) {
            if (!isCancel) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(finishAudioRecorder:time:)]) {
                    [weakSelf.delegate finishAudioRecorder:self time:duration];
                }
                isFail = NO;
            }
        } else {
            PhotonLog(@"语音文件录制失败-----%@",error);
        }
        
        if (isFail) {
            [[NSFileManager defaultManager] removeItemAtPath:weakSelf.cachePath error:nil];
        }
        
    }];
    [self.audioRecorder addBus:bus];
}
// 停止录制
- (void)stopRecording{
    
    [_audioRecorder stopRecord];
}

 // 取消录制
- (void)cancleRecording{
   
    [_audioRecorder cancelRecord];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancleAudioRecorder:)]) {
        [self.delegate cancleAudioRecorder:self];
    }
}

// 获取音量值
- (void)showVolumePeak{
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorder:volume:)]) {
        [self.delegate audioRecorder:self volume:_audioRecorder.peak];
    }
}
- (BOOL)isRecording{
    return self.audioRecorder.isRecording;
}
#pragma mark ----- Getter -----
- (MDAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        _audioRecorder = [[MDAudioRecorder alloc] initWithMaxDuration:180 minDuration:1];
        _audioRecorder.delegate = self;
    }
    return _audioRecorder;
}

#pragma  mark ------ MDAudioRecorderDelegate ------
- (void)audioRecorder:(MDAudioRecorder *)audioRecorder recordFail:(MDAudioRecorderType)errorType{
    if (errorType == MDAudioRecorderTypeTimeTooShort) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioRecorderTimeTooShort:)]) {
            [self.delegate audioRecorderTimeTooShort:self];
        }
    }else if (errorType == MDAudioRecorderTypeManualCancel){
        PhotonLog(@"手动取消录制");
    }
}

// 每次回调的参数
- (void)audioRecorder:(MDAudioRecorder *)audioRecorder currentRecordTiem:(NSTimeInterval)time{
    NSLog(@"time = %@",@(time));
}
@end
