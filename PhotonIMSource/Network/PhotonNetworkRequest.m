//
//  PhotonNetworkRequest.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonNetworkRequest.h"
#import "PhotonMacros.h"
#import "AFHTTPSessionManager.h"
NSString *const PhotonRequestMethodGet = @"GET";
NSString *const PhotonRequestMethodPost = @"POST";
NSString *const PhotonRequestMethodPut = @"PUT";
NSString *const PhotonRequestMethodDelete = @"DELETE";
NSString *const PhotonRequestMethodHEAD = @"HEAD";
NSString *const PhotonServiceMethod = @"serviceMethod";

NSString *const PhotonRequesUpLoadData = @"UpLoadData";
NSString *const PhotonRequesUpLoadFile = @"UpLoadFile";
NSString *const PhotonRequesUpLoadMultiFile = @"UpLoadMultiFile";
@interface PhotonNetworkRequest()
@property (nonatomic, copy, nullable) PhotonNetworkCompletionBlock completionBlock;
@property (nonatomic, copy, nullable) PhotonNetworkCompletionBlock failureBlock;
@property (nonatomic, copy, nullable) PhotonNetworkLoadProgressBlock loadProgressBlock;
@property (nonatomic, copy, nullable) PhotonNetworkDownLoadCompletionBlock downLoadCompletionBlock;
@property (nonatomic, copy, nullable) PhotonNetworkUpLoadCompletionBlock upLoadCompletionBlock;
@property (nonatomic, strong, nullable) AFHTTPSessionManager *manager;
@property (nonatomic) NSTimeInterval timeOut;// 超时时间
@property (nonatomic, strong, nullable) NSArray *cerArray;// 是否需要验证证书
@property (nonatomic, strong, nullable) NSURLSessionDataTask *task;
@property (nonatomic, strong, nullable) NSURLSessionDownloadTask *downLoadTask;
@property (nonatomic, strong, nullable) NSURLSessionUploadTask *uploadTask;
@property (nonatomic) NSInteger scode;
@property (nonatomic, copy, nullable) NSString *repString;
@property (nonatomic, strong, nullable) NSData *resumeData;
@property (nonatomic, copy, nullable)NSString *urlString;// 请求url
@end
@implementation PhotonNetworkRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.manager = [AFHTTPSessionManager manager];
//        self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.requestHeaders = [NSMutableDictionary dictionaryWithCapacity:10];
        self.mutifileItems = [NSMutableArray arrayWithCapacity:10];
        
    }
    return self;
}

- (instancetype)initWithUrl:(NSString *)urlString andParamer:(NSDictionary *)paramter{
    self =  [super init];
    if (self) {
        self.manager = [AFHTTPSessionManager manager];
//        self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.requestHeaders = [NSMutableDictionary dictionaryWithCapacity:10];
        self.urlString = urlString;
        self.parameters = [NSMutableDictionary dictionaryWithDictionary:paramter];
        self.timeOut = 15;
        self.cerArray = nil;
        self.mutifileItems = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)setUrlString:(NSString *)urlString {
    _urlString = urlString;
}

- (void)setPostValue:(id <NSObject>)value forKey:(NSString *)key {
    [self.parameters setValue:value forKey:key];
}
+ (instancetype)initWithUrl:(NSString *)urlString andParamer:(NSDictionary *)paramter{
    return [[self alloc] initWithUrl:urlString andParamer:paramter];
}

- (void)setCompletionBlock:(PhotonNetworkCompletionBlock)aCompletionBlock{
    _completionBlock = [aCompletionBlock copy];
}

- (void)setFailedBlock:(PhotonNetworkCompletionBlock)aFailedBlock{
    _failureBlock = [aFailedBlock copy];
    
}

- (void)setLoadProgressBlock:(PhotonNetworkLoadProgressBlock)aLoadProgressBlock{
    _loadProgressBlock = [aLoadProgressBlock copy];
}

- (void)setDownLoadCompletionBlock:(PhotonNetworkDownLoadCompletionBlock)aDownLoadCompletionBlock{
    _downLoadCompletionBlock = [aDownLoadCompletionBlock copy];
}

- (void)setUpLoadCompletionBlock:(PhotonNetworkUpLoadCompletionBlock)aUpLoadCompletionBlock{
    _upLoadCompletionBlock = [aUpLoadCompletionBlock copy];
}

- (void)addRequestHeader:(NSString *)header value:(NSString *)value {
    [self.requestHeaders setValue:value forKey:header];
}

- (AFSecurityPolicy*)customSecurityPolicy
{
    // /先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"hgcang" ofType:@"cer"];//证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = YES;
    
    securityPolicy.pinnedCertificates = [NSSet setWithObjects:certData, nil];
    
    return securityPolicy;
}

/**
 *  发送请求
 */
- (void)sendRequest{
    
    __weak typeof(self)weakInstance = self;
    
    if (self.cerArray) {
        NSMutableSet *pSet = [[NSMutableSet alloc] init];
        for (id item in self.cerArray) {
            [pSet addObject:item];
        }
        //自动加载.cer证书
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        [securityPolicy setPinnedCertificates:pSet];
        
        self.manager.securityPolicy = [self customSecurityPolicy];
    } else {
        self.manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    }
    
    for (NSString *key in self.requestHeaders) {
        NSString *value = [self.requestHeaders objectForKey:key];
        [self.manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
    
    //设置超时
    self.manager.requestSerializer.timeoutInterval = self.timeOut;
    //默认会按json解析，这里不用默认的
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    if ([self.requestMethod isEqualToString:PhotonRequestMethodGet]) {
        self.task = [self.manager GET:self.urlString parameters:self.parameters
                             progress:nil
                              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                  [weakInstance completion:task rep:responseObject];
                              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                  [weakInstance failed:task error:error];
                              }];
    } else if ([self.requestMethod isEqualToString:PhotonRequestMethodPost]) {
        self.task = [self.manager POST:self.urlString parameters:self.parameters
                              progress:nil
                               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                   [weakInstance completion:task rep:responseObject];
                               } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                   [weakInstance failed:task error:error];
                               }];
    } else if ([self.requestMethod isEqualToString:PhotonRequestMethodPut]) {
        self.task = [self.manager PUT:self.urlString
                           parameters:self.parameters
                              success:^(NSURLSessionDataTask *operation, id responseObject) {
                                  [weakInstance completion:operation rep:responseObject];
                              } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                                  [weakInstance failed:operation error:error];
                              }];
    }
}

// 下载方法
- (void)sendDownLoad{
    __weak typeof(self)instance = self;
    [self.manager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
    }];
    
    NSURL *URL = [NSURL URLWithString:self.urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    // 如果之前有下载记录，则在原下载记录继续下载
    if (self.resumeData) {
        _downLoadTask = [self.manager downloadTaskWithResumeData:self.resumeData progress:^(NSProgress * _Nonnull downloadProgress) {
            [instance loadPorgress:downloadProgress];
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            if (instance.destinationUrl) {
                documentsDirectoryURL = instance.destinationUrl;
            }
            return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            [instance downLoadCompletion:response filePath:filePath];
        }];
        
    }else{// 如果没有则继续加载
        _downLoadTask = [self.manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            [instance loadPorgress:downloadProgress];
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            if (instance.destinationUrl) {
                documentsDirectoryURL = instance.destinationUrl;
            }
            return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            [instance downLoadCompletion:response filePath:filePath];
        }];
        
    }
    
    [_downLoadTask resume];
    
    
}

// 上传文件
- (void)sendUpLoad{
    __weak typeof(self)instance = self;
    if([self.requestMethod isEqualToString:PhotonRequesUpLoadData]){
        if (self.mutifileItems.count <= 0) {
            return;
        }
        NSMutableURLRequest *request=[[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:self.urlString  parameters:self.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            for (PhotonUploadFileInfo *fileBVO in self.mutifileItems) {
                if([fileBVO.fileName isNotEmpty] && [fileBVO.mimeType isNotEmpty]){
                     [formData appendPartWithFileData:fileBVO.sourceData name:fileBVO.name fileName:fileBVO.fileName mimeType:fileBVO.mimeType];
                }else{
                    [formData appendPartWithFormData:fileBVO.sourceData name:fileBVO.name];
                }
            }
        } error:nil];
        
        for (NSString *key in self.requestHeaders) {
            NSString *value = [self.requestHeaders objectForKey:key];
            [request setValue:value forHTTPHeaderField:key];
        }
        _uploadTask=[_manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [instance loadPorgress:uploadProgress];
            });
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (error) {
                [instance failed:nil error:error];
            }else{
                [instance upLoadCompletion:response responseObject:responseObject];
            }
        }];
        
    }else if([self.requestMethod isEqualToString:PhotonRequesUpLoadFile]){
        NSURL *URL = [NSURL URLWithString:self.urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        for (NSString *key in self.requestHeaders) {
            NSString *value = [self.requestHeaders objectForKey:key];
            [request setValue:value forHTTPHeaderField:key];
        }
        NSURL *filePath = nil;
        if (_fileUrlString) {
            filePath = [NSURL URLWithString:_fileUrlString];
        }
        _uploadTask = [self.manager uploadTaskWithRequest:request fromFile:filePath progress:^(NSProgress * _Nonnull uploadProgress) {
            [instance loadPorgress:uploadProgress];
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (error) {
                [instance failed:nil error:error];
            }else{
                [instance upLoadCompletion:response responseObject:responseObject];
            }
        }];
        
    }else if([self.requestMethod isEqualToString:PhotonRequesUpLoadMultiFile]){
        if (self.mutifileItems.count <= 0) {
            return;
        }
        NSMutableURLRequest *request=[[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:self.urlString  parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            for (PhotonUploadFileInfo *fileinfo in self.mutifileItems) {
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:fileinfo.fileURLString] name:fileinfo.name fileName:fileinfo.fileName mimeType:fileinfo.mimeType error:nil];
            }
            
        } error:nil];
        for (NSString *key in self.requestHeaders) {
            NSString *value = [self.requestHeaders objectForKey:key];
            [request setValue:value forHTTPHeaderField:key];
        }
        _uploadTask=[_manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [instance loadPorgress:uploadProgress];
            });
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (error) {
                [instance failed:nil error:error];
            }else{
                [instance upLoadCompletion:response responseObject:responseObject];
            }
        }];
        
    }
    [_uploadTask resume];
    
}

// 回复请求
- (void)resume{
    if (_task) {
        [_task resume];
    }
    
    if (_downLoadTask) {
        [_downLoadTask resume];
    }
    
    if (_uploadTask) {
        [_uploadTask resume];
    }
}
// 挂载，暂停
- (void)suspend{
    if (_task) {
        [_task suspend];
    }
    if (_downLoadTask) {
        [_downLoadTask suspend];
    }
    
    if (_uploadTask) {
        [_uploadTask suspend];
    }
}

// 取消请求
- (void)cancel {
    if (_task) {
        [_task cancel];
    }
    if (_downLoadTask) {
        [self dowloadCancle:_downLoadTask];
    }
    if (_uploadTask) {
        [_uploadTask cancel];
    }
    self.isCancelled = YES;
}

- (void) didCompletion {
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestFinished:)]) {
        [self.delegate requestFinished:self];
    }
    
    if (self.completionBlock) {
        self.completionBlock();
    }
}
- (void)dowloadCancle:(NSURLSessionDownloadTask *)downLoadTask{
    __weak typeof(self)instance = self;
    [downLoadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        instance.resumeData = resumeData;
        instance.downLoadTask = nil;
    }];
}
- (void)completion:(NSURLSessionDataTask *)operation rep: (id)responseObject {
    NSHTTPURLResponse *response = (NSHTTPURLResponse*) self.task.response;
    self.scode = response.statusCode;
    self.responseData = responseObject;
    self.request = operation.originalRequest;
    self.responseHeaders = [response allHeaderFields];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.repString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf didCompletion];
        });
    });
}

- (void)failed:(NSURLSessionDataTask *)operation error: (NSError*)error {
    self.request = operation.originalRequest;
    self.error = operation.error;
    if (self.error){
        self.error = error;
    }
    if ([operation.response isKindOfClass:[NSHTTPURLResponse class]]) {
        self.scode = ((NSHTTPURLResponse *)operation.response).statusCode;
    }
    if (error.code == NSURLErrorCancelled) {
        self.isCancelled = YES;
    }
    if (error.code == NSURLErrorTimedOut) {
        
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestFailed:)]) {
        [self.delegate requestFailed:self];
    }
    if (self.failureBlock) {
        self.failureBlock();
    }
}



- (void)loadPorgress:(NSProgress * _Nonnull)uploadProgress{
    if(self.loadProgressBlock){
        self.loadProgressBlock(uploadProgress);
    }
}

- (void)downLoadCompletion:(NSURLResponse * _Nonnull)response filePath:(NSURL * _Nullable)filePath{
    if (self.downLoadCompletionBlock) {
        self.downLoadCompletionBlock(response,filePath);
    }
}

- (void)upLoadCompletion:(NSURLResponse * _Nonnull)response responseObject:(id)responseObject{
    self.responseData = responseObject;
    if (self.upLoadCompletionBlock) {
        self.upLoadCompletionBlock(response,responseObject);
    }
}
- (NSUInteger) responseStatusCode {
    return self.scode;
}

- (NSString *)responseString{
    return self.repString;
}
@end
