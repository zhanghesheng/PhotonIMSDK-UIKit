//
//  PhotonIMDispatchSource.h
//  PhotonIM
//
//  Created by Bruce on 2019/11/26.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^PhotonIMDispatchSourceEventBlock)(id userInfo);
@interface PhotonIMDispatchSource : NSObject
- (instancetype)initWithEventQueue:(dispatch_queue_t)eventQueue eventBlack:(PhotonIMDispatchSourceEventBlock)envent;
- (void)addEventSource:(nullable id)userInfo;
- (void)clearDelegateAndCancel;
@end

NS_ASSUME_NONNULL_END
