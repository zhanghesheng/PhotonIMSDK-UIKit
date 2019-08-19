//
//  PhotonAudioPlayer.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MDAudioKit/MDAudioKit.h>
@interface PhotonAudioPlayer() <MDOpusPlayerDelegate>

@property (nonatomic, copy, nullable) void (^ completeBlock)(BOOL finished);
@property (nonatomic, strong, nullable)MDOpusPlayer  *opusPlayer;
@property (nonatomic, copy, nullable)NSString  *filePath;
@end
@implementation PhotonAudioPlayer

+ (PhotonAudioPlayer *)sharedAudioPlayer
{
    static PhotonAudioPlayer *audioPlayer;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        audioPlayer = [[PhotonAudioPlayer alloc] init];
    });
    return audioPlayer;
}

- (void)playAudioAtPath:(NSString *)path complete:(void (^)(BOOL finished))complete;
{
    
    if ([self isPlaying] && [_filePath isEqualToString:path]) {// 是同一个资源的请求
        [self stopPlayingAudio];
        return;
    }
    if ([self isPlaying]) {
        if (self.completeBlock) {
            self.completeBlock(YES);
            self.completeBlock = nil;
        }
        [self stopPlayingAudio];
    }
    _filePath = path;
    MDOpusPlayerOptions *option = [[MDOpusPlayerOptions alloc] init];
    option.filePath = path;
    _completeBlock = [complete copy];
    BOOL res = [self.opusPlayer startPlayingWithOptions:option];
    if (!res) {
        if (_completeBlock) {
            _completeBlock(YES);
        }
    }
}

- (void)stopPlayingAudio
{
    [self.opusPlayer stopPlaying];
}

- (BOOL)isPlaying
{
    return self.opusPlayer.isPlaying;
}

#pragma mark ----- Getter --------
- (MDOpusPlayer *)opusPlayer{
    if (!_opusPlayer) {
        _opusPlayer = [[MDOpusPlayer alloc] init];
        _opusPlayer.delegate = self;
    }
    return _opusPlayer;
}

#pragma mark ---- MDOpusPlayerDelegate ----

- (void)opusPlayer:(MDOpusPlayer *)sender didFinishPlaying:(BOOL)flag {
    if (self.completeBlock) {
        self.completeBlock(flag);
        self.completeBlock = nil;
    }
}

- (void)opusPlayer:(MDOpusPlayer *)sender didOccurError:(NSError *)error {
    if (error) {
        if (self.completeBlock) {
            self.completeBlock(NO);
            self.completeBlock = nil;
        }
    }
}
- (void)opusPlayer:(MDOpusPlayer *)sender didStop:(BOOL)flag {
    if (self.completeBlock) {
        self.completeBlock(NO);
        self.completeBlock = nil;
    }
}

@end
