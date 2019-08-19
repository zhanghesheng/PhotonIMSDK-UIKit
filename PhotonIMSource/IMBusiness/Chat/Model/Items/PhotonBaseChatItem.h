//
//  PhotonBaseChatItem.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PhotonMacros.h"
#import "PhotonBaseTableItem.h"

#define     TIMELABEL_HEIGHT    18.5f
#define     TIMELABEL_SPACE_Y   10.0f

#define     NAMELABEL_HEIGHT    14.0f
#define     NAMELABEL_SPACE_X   12.0f
#define     NAMELABEL_SPACE_Y   1.0f

#define     AVATAR_WIDTH        44.0f
#define     AVATAR_SPACE_X      15.0f
#define     AVATAR_SPACE_Y      16.5f

#define     MSGBG_SPACE_X       5.0f
#define     MSGBG_SPACE_Y       1.0f

#define     TIPLABEL_SPACE_Y    14.0f
#define     TIPLABEL_HEIGHT     29.0f

#define     MSG_SPACE_TOP       11
#define     MSG_SPACE_BTM       10.5
#define     MSG_SPACE_LEFT      15
#define     MSG_SPACE_RIGHT     15

NS_ASSUME_NONNULL_BEGIN



/**
 消息来源属于那方
 
 - PhotonChatMessageFromUnknown: 未知
 - PhotonChatMessageFromSelf: 来自自己
 - PhotonChatMessageFromFriend: 来自好友
 */
typedef NS_ENUM(NSInteger,PhotonChatMessageFromType){
    PhotonChatMessageFromUnknown,
    PhotonChatMessageFromSelf,
    PhotonChatMessageFromFriend
};

@interface PhotonBaseChatItem : PhotonBaseTableItem
/*
 * 消息的id
*/
@property(nonatomic, copy, nullable) NSString *msgid;


/**
 消息来源者头像
 */
@property(nonatomic, copy, nullable)NSString *avatalarImgaeURL;


/**
 消息类型
 */
@property(nonatomic, assign) PhotonChatMessageFromType fromType;


/**
 时间戳
 */
@property(nonatomic, assign) uint64_t timeStamp;

/**
 是否显示消息时间戳
 */
@property(nonatomic, assign, readonly)BOOL  showTime;

/**
 时间标签，
 • 今日内（0:00-24:00）：格式为“上午/下午+时间（24小时制）”，如上午 11:59、下午 12:00、下午 19:01。
 • 昨日内：格式为“昨天”。
 • 昨日之前：格式为“年/月/日”。
 */
@property(nonatomic, copy, readonly, nullable)NSString  *timeText;


/**
 系统提示
 如:发送的内容不合规
 */
@property(nonatomic, copy, nullable) NSString *tipText;


/**
 消息的发送状态
 已发送，已读
 */
@property(nonatomic, copy, nullable)NSString *messageStatusText;


/**
 可以撤回消息
 */
@property(nonatomic, assign)BOOL canWithDrawMsg;

@property (nonatomic, strong, nullable)NSString *localPath;
@end

NS_ASSUME_NONNULL_END
