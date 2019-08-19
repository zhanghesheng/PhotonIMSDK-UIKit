//
//  PhotonChatDataSource.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PotonTableViewDataSource.h"

NS_ASSUME_NONNULL_BEGIN
@class PhotonIMError;
@protocol PhotonChatDataSourceDelegate <NSObject>
@optional
- (void)sendReadMsgs:(NSArray * _Nullable)msgids completion:(nullable void(^)(BOOL succeed, PhotonIMError * _Nullable error ))completion;

@end
@interface PhotonChatDataSource : PotonTableViewDataSource
@property(nonatomic, weak, nullable)id<PhotonChatDataSourceDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
