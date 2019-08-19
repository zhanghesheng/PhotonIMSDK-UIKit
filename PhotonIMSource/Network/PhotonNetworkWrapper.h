//
//  PhotonNetworkWrapper.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotonNetworkProtocol.h"
#import "PhotonNetworkRequest.h"
#import "PhotonErrorDescription.h"
NS_ASSUME_NONNULL_BEGIN

@interface PhotonNetworkWrapper : NSObject<PhotonNetworkRequestDelegate>
/**
 *  一般的请求
 *
 *  @param request QSNetworkRequest instance
 */
- (void)send:(id<PhotonNetworkProtocol>)request;

/**
 *  下载请求
 *
 *  @param request QSNetworkRequest instance
 */
- (void)downLoad:(id<PhotonNetworkProtocol>)request;

/**
 *  上传请求
 *
 *  @param request QSNetworkRequest instance
 */
- (void)upLoad:(id<PhotonNetworkProtocol>)request;

- (void)cancleRequest:(id<PhotonNetworkProtocol>)request;

- (void)suspendRequest:(id<PhotonNetworkProtocol>)request;

- (void)resumeRequest:(id<PhotonNetworkProtocol>)request;

- (NSDictionary*) getResponseJsonResult:(id)request;

- (PhotonErrorDescription *)getErrorDescription:(id<PhotonNetworkProtocol>)request;

- (NSDictionary *)getJsonResult:(nullable NSURLResponse *)response responseObject:(nullable id)responseObject;
@end

NS_ASSUME_NONNULL_END
