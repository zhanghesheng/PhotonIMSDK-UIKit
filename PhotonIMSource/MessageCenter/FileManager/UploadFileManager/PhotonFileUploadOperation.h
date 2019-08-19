//
//  PhotonFileUploadOperation.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/28.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PhotonNetworkService.h"
NS_ASSUME_NONNULL_BEGIN

@interface PhotonFileUploadOperation : NSOperation
@property (nonatomic, copy, readonly) NSString *filePath;
- (instancetype)initUploadRequestMethodWithMutiFile:(NSString *)queryString
                                           paramter:(nonnull NSDictionary *)paramter
                                          fromFiles:(NSArray *)fileItems
                                           progress:(void(^)(NSProgress *))progress
                                         completion:(void (^)(NSDictionary *))completion
                                            failure:(void (^)(PhotonErrorDescription *))failure;

- (void)suspend;

- (void)resume;

- (void)cancle;
@end

NS_ASSUME_NONNULL_END
