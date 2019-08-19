//
//  PhotonAudioPlayer.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface PhotonAudioPlayer : NSObject


@property (nonatomic, assign, readonly) BOOL isPlaying;

+ (PhotonAudioPlayer *)sharedAudioPlayer;

- (void)playAudioAtPath:(NSString *)path complete:(void (^)(BOOL finished))complete;

- (void)stopPlayingAudio;
@end

NS_ASSUME_NONNULL_END
