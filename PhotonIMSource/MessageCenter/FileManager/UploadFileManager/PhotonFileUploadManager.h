//
//  PhotonFileUploadManager.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/28.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotonFileUploadOperation.h"
NS_ASSUME_NONNULL_BEGIN

@interface PhotonFileUploadManager : NSObject
+ (instancetype)defaultManager;

- (void)uploadRequestMethodWithMutiFile:(NSString *)queryString
                               paramter:(nullable NSDictionary *)paramter
                              fromFiles:(NSArray *)fileItems
                          progressBlock:(void(^)(NSProgress *))progressBlock
                             completion:(void (^)(NSDictionary *))completion
                                failure:(void (^)(PhotonErrorDescription *))failure;
@end

NS_ASSUME_NONNULL_END
