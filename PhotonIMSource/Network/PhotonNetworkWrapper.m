//
//  PhotonNetworkWrapper.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonNetworkWrapper.h"
#import "PhotonMacros.h"
@interface PhotonNetworkWrapper()
@property(nonatomic, strong) NSMutableArray *requestArray;
@end

@implementation PhotonNetworkWrapper
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestArray = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}
// 一般请求（get post put）
- (void)send:(id<PhotonNetworkProtocol>)request{
    [self setRequest:request];
    [request sendRequest];
}

// 开始下载
- (void)downLoad:(id<PhotonNetworkProtocol>)request{
    [self setRequest:request];
    [request sendDownLoad];
}

// 开始上传
- (void)upLoad:(id<PhotonNetworkProtocol>)request{
    [self setRequest:request];
    [request sendUpLoad];
}

- (void)setRequest:(id<PhotonNetworkProtocol>)request{
    [request setDelegate:self];
    [_requestArray addObject:request];
}

// 取消请求
- (void)cancleRequest:(id<PhotonNetworkProtocol>)request{
    [request cancel];
}
// 请求挂载
- (void)suspendRequest:(id<PhotonNetworkProtocol>)request{
    [request suspend];
}

// 请求上传
- (void)resumeRequest:(id<PhotonNetworkProtocol>)request{
    [request resume];
}
- (void)removeRequestFromArray:(id<PhotonNetworkProtocol>)pRequest {
    int inx = -1;
    for (id<PhotonNetworkProtocol> req in _requestArray) {
        inx++;
        if (req == pRequest) {
            [req cancel];
            [req setDelegate:nil];
            [_requestArray removeObjectAtIndex:inx];
            break;
        }
    }
}

- (void)removeAllRequestFromArray {
    if (!_requestArray) {
        return;
    }
    for (id<PhotonNetworkProtocol> req in _requestArray) {
        [req cancel];
        [req setDelegate:nil];
    }
    [_requestArray removeAllObjects];
}
- (void)requestFailed:(id<PhotonNetworkProtocol>)request{
    
}

- (void)requestFinished:(id<PhotonNetworkProtocol>)request{
    @try {
        [self removeRequestFromArray:request];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (NSDictionary*)getResponseJsonResult:(id)request {
    return [self getResponseJsonResultForAFNetwork:request];
}

- (NSDictionary*)getResponseJsonResultForAFNetwork:(PhotonNetworkRequest *)request {
    NSDictionary *resultDict = nil;
    
    BOOL isError = [self isResponseDidNetworkErrorForAFNetwork:request];
    if (isError) {
        return resultDict;
    }
    
    NSString *dataStr = request.responseString;
    
    dataStr = [dataStr trim];
    
    @try {
        resultDict = [dataStr JSONValue];
    }
    @catch (NSException *exception) {
        resultDict = [NSDictionary dictionary];
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request.request];
    }
    if (resultDict == nil) {
        resultDict = [NSDictionary dictionary];
    }
    
    return resultDict;
}

- (BOOL)isResponseDidNetworkErrorForAFNetwork:(PhotonNetworkRequest *)request {
    NSUInteger status = request.responseStatusCode;
    if (status >= 200 && status < 300) {
        return NO;
    }
    
    return YES;
}

- (NSDictionary *)getJsonResult:(nullable NSURLResponse *)response responseObject:(nullable id)responseObject{
    NSUInteger status = [(NSHTTPURLResponse *)response statusCode];
    if (status >= 200 && status < 300) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            return responseObject;
        }else if([responseObject isKindOfClass:[NSString class]]){
            NSDictionary *resultDict = [self p_stringToDict:responseObject];
            return resultDict;
        }else if([responseObject isKindOfClass:[NSData class]]){
            NSString *content = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSDictionary *resultDict = [self p_stringToDict:content];
            return resultDict;
        }
    }
    return nil;
}

- (NSDictionary *)p_stringToDict:(NSString *)content{
    NSDictionary *resultDict = nil;
    NSString *dataStr = content;
    dataStr = [dataStr trim];
    @try {
        resultDict = [dataStr JSONValue];
    }
    @catch (NSException *exception) {
        resultDict = [NSDictionary dictionary];
    }
    if (resultDict == nil) {
        resultDict = [NSDictionary dictionary];
    }
    return resultDict;
}


- (PhotonErrorDescription *)getErrorDescription:(id<PhotonNetworkProtocol>)request{
    PhotonErrorDescription *tbd = [[PhotonErrorDescription alloc] init];
    tbd.errorCode = request.responseStatusCode;
    if (tbd.errorCode>=400 && tbd.errorCode<500) {
        NSString *str = request.responseString;
        if (!str) {
            str = @"";
        }
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *dict = @{};
        @try {
            dict =
            [NSJSONSerialization JSONObjectWithData:data
                                            options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                              error:&error];
            
        }
        @catch (NSException *exception) {
            dict = @{};
        }
        @finally {
            
        }
        tbd.userInfo = dict;
    }
    
    return tbd;
}
@end
