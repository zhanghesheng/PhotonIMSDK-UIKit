//
//  PhotonChatData.h
//  PhotonIM
//
//  Created by Bruce on 2019/11/28.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotonChatData : NSObject
@property(nonatomic,copy, nullable)NSString *sendContent;
@property(nonatomic,assign)NSInteger totalMsgCount;
@property(nonatomic,assign)NSInteger msgInterval;
@property(nonatomic,assign)NSInteger sendedMessageCount;
@property(nonatomic,assign)NSInteger sendedSuccessedCount;
@property(nonatomic,assign)NSInteger sendedFailedCount;
@property(nonatomic,assign)NSInteger totalTime;
@property(nonatomic,assign)BOOL toStart;
- (void)resetRecord;
@end

NS_ASSUME_NONNULL_END
