//
//  PhotonNetworkService.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonNetworkService.h"
@interface PhotonNetworkService()
@property (nonatomic, weak)PhotonNetworkRequest *uploadRequest;
@property (nonatomic, strong)NSMutableDictionary *requestHeaders;
@end
@implementation PhotonNetworkService
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
-(NSMutableDictionary *)requestHeaders{
    
    if (!_requestHeaders) {
        _requestHeaders = [NSMutableDictionary dictionary];
    }
    if ([[PhotonUtil getCookie] isNotEmpty]) {
        [_requestHeaders setValue:[PhotonUtil getCookie] forKey:@"Cookie"];
    }
    return _requestHeaders;
}
- (void)setRequestHeader:(NSString *)value key:(NSString *)key{
    if ([value isNotEmpty] && [key isNotEmpty]) {
        [self.requestHeaders setValue:value forKey:key];
    }
}
// 通用数据请求（get，post，put）
- (void)commonRequestMethod:(NSString *)method
                queryString:(NSString *)queryString
                   paramter:(nullable NSDictionary *)paramter
                 completion:(void (^)(NSDictionary *))completion
                    failure:(void (^)(PhotonErrorDescription *))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",self.baseUrl,queryString];
    PhotonNetworkRequest *request = [PhotonNetworkRequest initWithUrl:urlString andParamer:paramter];
    request.delegate = self;
    request.requestMethod = method;
    [request setRequestHeaders:self.requestHeaders];
    __weak PhotonNetworkRequest *pRequest = request;
    __weak typeof(self)instance = self;
    [request setCompletionBlock:^{
        NSDictionary *dict = [instance getResponseJsonResult:pRequest];
        if (!dict) {
            failure(nil);
            return;
        }
        NSInteger code = [[[dict objectForKey:@"ec"] isNil] integerValue];
        if (code != 0) {
            NSString *msg = [dict objectForKey:@"em"];
            PhotonErrorDescription *tbd = [[PhotonErrorDescription alloc] init];
            tbd.errorCode = code;
            tbd.errorMessage = msg;
            failure(tbd);
            return;
        }
        completion(dict);
    }];
    
    [request setFailedBlock:^{
        PhotonErrorDescription *error =  [instance getErrorDescription:pRequest];
        failure(error);
    }];
    
    [self send:request];
}

//下载文件
- (void)downLoadRequestMethod:(NSString *)queryString
        documentsDirectoryURL:(NSURL *)documentsDirectoryURL
                     progress:(void(^)(NSProgress *))progress
                   completion:(void (^)(NSDictionary *))completion
                      failure:(void (^)(PhotonErrorDescription *))failure{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",self.baseUrl,queryString];
    PhotonNetworkRequest *request = [PhotonNetworkRequest initWithUrl:urlString andParamer:@{}];
    request.delegate = self;
    request.destinationUrl = documentsDirectoryURL;
    __weak typeof(self)instance = self;
    __weak PhotonNetworkRequest *pRequest = request;
    [request setRequestHeaders:self.requestHeaders];
    [request setLoadProgressBlock:^(NSProgress * uploadProgress) {
        progress(uploadProgress);
    }];
    
    [request setDownLoadCompletionBlock:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath) {
        NSDictionary *dict = [instance getResponseJsonResult:pRequest];
        if (!dict) {
            failure(nil);
            return;
        }
        completion(dict);
    }];
    [request setFailedBlock:^{
        PhotonErrorDescription *error =  [instance getErrorDescription:pRequest];
        failure(error);
    }];
    [self downLoad:request];
}

// 文件的上传，自行拼装formdata
- (void)uploadRequestMethodWithBodyData:(NSString *)queryString
                               fromData:(NSData *)bodyData
                               progress:(void(^)(NSProgress *))progress
                             completion:(void (^)(NSDictionary *))completion
                                failure:(void (^)(PhotonErrorDescription *))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",self.baseUrl,queryString];
    PhotonNetworkRequest *request = [PhotonNetworkRequest initWithUrl:urlString andParamer:@{}];
    request.delegate = self;
    request.requestMethod = PhotonRequesUpLoadData;
    request.uploadBody = bodyData;
    __weak typeof(self)instance = self;
    __weak PhotonNetworkRequest *pRequest = request;
    [request setRequestHeaders:self.requestHeaders];
    [request setLoadProgressBlock:^(NSProgress * uploadProgress) {
        progress(uploadProgress);
    }];
    
    [request setUpLoadCompletionBlock:^(NSURLResponse * _Nonnull response, id _Nullable responseObject) {
        NSDictionary *dict = [instance getResponseJsonResult:pRequest];
        if (!dict) {
            failure(nil);
            return;
        }
        completion(dict);
    }];
    [request setFailedBlock:^{
        PhotonErrorDescription *error =  [instance getErrorDescription:pRequest];
        failure(error);
    }];
    
    [self upLoad:request];
    
}

- (void)uploadRequestMethodWithData:(NSString *)queryString
                           paramter:(nullable NSDictionary *)paramter
                          fromFiles:(NSArray<PhotonUploadFileInfo *>*)fileItems
                           progress:(void(^)(NSProgress *))progress
                         completion:(void (^)(NSDictionary *))completion
                            failure:(void (^)(PhotonErrorDescription *))failure{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",self.baseUrl,queryString];
    if ([queryString containsString:@"http://"]) {
        urlString = [NSString stringWithFormat:@"%@",queryString];
    }
    
    PhotonNetworkRequest *request = [PhotonNetworkRequest initWithUrl:urlString andParamer:paramter];
    request.delegate = self;
    request.requestMethod = PhotonRequesUpLoadData;
    self.uploadRequest = request;
    [request setRequestHeaders:self.requestHeaders];
    [request.mutifileItems addObjectsFromArray:fileItems];
    __weak typeof(self)instance = self;
    __weak PhotonNetworkRequest *pRequest = request;
    [request setLoadProgressBlock:^(NSProgress * uploadProgress) {
        progress(uploadProgress);
    }];
    
    [request setUpLoadCompletionBlock:^(NSURLResponse * _Nonnull response, id _Nullable responseObject) {
        NSDictionary *dict = [instance getJsonResult:response responseObject:responseObject];
        if (!dict) {
            failure(nil);
            return;
        }
        NSInteger code = [[[dict objectForKey:@"ec"] isNil] integerValue];
        if (code != 0) {
            NSString *msg = [dict objectForKey:@"em"];
            PhotonErrorDescription *tbd = [[PhotonErrorDescription alloc] init];
            tbd.errorCode = code;
            tbd.errorMessage = msg;
            failure(tbd);
            return;
        }
        completion(dict);
    }];
    
    [request setFailedBlock:^{
        PhotonErrorDescription *error =  [instance getErrorDescription:pRequest];
        failure(error);
    }];
    [self upLoad:request];
    
}

- (void)uploadRequestMethodWithFileURL:(NSString *)queryString
                              paramter:(nonnull NSDictionary *)paramter
                              filePath:(NSString *)filePath
                              progress:(void(^)(NSProgress *))progress
                            completion:(void (^)(NSDictionary *))completion
                               failure:(void (^)(PhotonErrorDescription *))failure{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",self.baseUrl,queryString];
    PhotonNetworkRequest *request = [PhotonNetworkRequest initWithUrl:urlString andParamer:paramter];
    request.delegate = self;
    request.requestMethod = PhotonRequesUpLoadFile;
    request.fileUrlString = filePath;
    __weak typeof(self)instance = self;
    [request setRequestHeaders:self.requestHeaders];
    __weak PhotonNetworkRequest *pRequest = request;
    [request setLoadProgressBlock:^(NSProgress * uploadProgress) {
        progress(uploadProgress);
    }];
    [request setDownLoadCompletionBlock:^(NSURLResponse * _Nonnull response, id _Nullable responseObject) {
        NSDictionary *dict = [instance getJsonResult:response responseObject:responseObject];
        if (!dict) {
            failure(nil);
            return;
        }
        NSInteger code = [[[dict objectForKey:@"ec"] isNil] integerValue];
        if (code != 0) {
            NSString *msg = [dict objectForKey:@"em"];
            PhotonErrorDescription *tbd = [[PhotonErrorDescription alloc] init];
            tbd.errorCode = code;
            tbd.errorMessage = msg;
            failure(tbd);
            return;
        }
        completion(dict);
    }];
    [request setFailedBlock:^{
        PhotonErrorDescription *error =  [instance getErrorDescription:pRequest];
        failure(error);
    }];
    
    [self upLoad:request];
    
}

- (void)uploadRequestMethodWithMutiFile:(NSString *)queryString
                               paramter:(nonnull NSDictionary *)paramter
                              fromFiles:(NSArray *)fileItems
                               progress:(void(^)(NSProgress *))progress
                             completion:(void (^)(NSDictionary *))completion
                                failure:(void (^)(PhotonErrorDescription *))failure{
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",self.baseUrl,queryString];
    PhotonNetworkRequest *request = [PhotonNetworkRequest initWithUrl:urlString andParamer:paramter];
    request.delegate = self;
    request.requestMethod = PhotonRequesUpLoadMultiFile;
    self.uploadRequest = request;
    [request setRequestHeaders:self.requestHeaders];
    [request.mutifileItems addObjectsFromArray:fileItems];
    __weak typeof(self)instance = self;
    __weak PhotonNetworkRequest *pRequest = request;
    [request setLoadProgressBlock:^(NSProgress * uploadProgress) {
        progress(uploadProgress);
    }];
    
    [request setUpLoadCompletionBlock:^(NSURLResponse * _Nonnull response, id _Nullable responseObject) {
        NSDictionary *dict = [instance getJsonResult:response responseObject:responseObject];
        if (!dict && dict.count == 0) {
            failure(nil);
            return;
        }
        NSInteger code = [[[dict objectForKey:@"ec"] isNil] integerValue];
        if (code != 0) {
            NSString *msg = [dict objectForKey:@"em"];
            PhotonErrorDescription *tbd = [[PhotonErrorDescription alloc] init];
            tbd.errorCode = code;
            tbd.errorMessage = msg;
            failure(tbd);
            return;
        }
        completion(dict);
    }];
    
    [request setFailedBlock:^{
        PhotonErrorDescription *error =  [instance getErrorDescription:pRequest];
        failure(error);
    }];
    [self upLoad:request];
    
}

- (void)requestResume{
    [_uploadRequest resume];
}
- (void)requestSuspend{
    [_uploadRequest suspend];
}
- (void)requestCancle{
    [_uploadRequest cancel];
}
@end
