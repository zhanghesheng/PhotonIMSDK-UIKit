//
//  PhotonVoiceMessageChatItem.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotonBaseChatItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface PhotonVoiceMessageChatItem : PhotonBaseChatItem

/**
 语音文件名
 */
@property(nonatomic, copy, nullable)NSString *fileName;

/**
 语音文件存储url
 */
@property(nonatomic, strong, nullable)NSURL *url;
/**
 语音文件时长
 */
@property(nonatomic, assign)int64_t duration;


/**
 语音是否点击播放
 */
@property(nonatomic, assign)BOOL isPlayed;
@end

NS_ASSUME_NONNULL_END
