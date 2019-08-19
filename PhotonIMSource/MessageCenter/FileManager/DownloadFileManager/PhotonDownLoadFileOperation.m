//
//  PhotonDownLoadFileOperation.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/4.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonDownLoadFileOperation.h"

static NSMutableDictionary *completionHandlerCache;
@interface PhotonDownLoadFileOperation()<NSURLSessionDownloadDelegate>
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (nonatomic, strong) NSURLSessionDownloadTask *downTask;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy)NSString *fileURL;
@property (nonatomic, strong,nonnull)PhotonDownloadFileReceipt *fileReceipt;
@property (nonatomic, strong)NSData *resumData;
@property (nonatomic,assign) long long int byte;
@property (nonatomic, copy)PhotonDownloadFileOperationProgressBlock progressBlock;
@property (nonatomic, copy)PhotonDownloadFileOperationCompletionBlock comBlock;
@property (nonatomic, copy)PhotonDownloadFileOperationFailureDesitination desitinationBlock;
@end
@implementation PhotonDownLoadFileOperation
#pragma mark -------- 初始化下载的session --------
- (NSURLSessionConfiguration *)defaultURLSessionConfiguration:(NSString *)fileUrl {
    // 使用fileUrl作为后台运作的id，群别队列中不同下载操作的执行
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:fileUrl];
    configuration.HTTPShouldSetCookies = YES;
    configuration.HTTPShouldUsePipelining = NO;
    configuration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    configuration.allowsCellularAccess = YES;
    configuration.timeoutIntervalForRequest = 60.0;
    
    return configuration;
}

- (NSURLSession *)backgroundSession:(NSString *)fileUrl{
    NSURLSession *session = nil;
    NSURLSessionConfiguration *configuration = [self defaultURLSessionConfiguration:fileUrl];
    session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    return session;
}
- (instancetype)initWithReceipt:(PhotonDownloadFileReceipt *)receipt{
    self = [super init];
    if (self) {
        self.session = [self backgroundSession:receipt.url];
        self.fileURL = receipt.url;
        self.fileReceipt = receipt;
        self.resumData = receipt.resumeData;
        self.fileReceipt.state = PhotonDownloadFileStateWaiting;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)downLoad{
    NSString *urlString = self.fileURL;
    urlString = self.fileURL;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    self.downTask = [self.session downloadTaskWithRequest:request];
    [self.downTask resume];
}

- (void)cancelDownload{
    [self.downTask cancel];
}
#pragma mark -----------  operation 相关 ---------
- (void)start{
    @autoreleasepool {
        if (self.isCancelled) {
            [self exit];
            return;
        }
        self.executing = YES;
        self.finished = NO;
        [self downLoad];
    }
}
- (void)exit{
    self.finished =  YES;
    self.executing = NO;
    [self.session finishTasksAndInvalidate];
}
- (BOOL)isAsynchronous
{
    return YES;
}

@synthesize executing = _executing;
@synthesize finished = _finished;

- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)cancel{
    [super cancel];
    [self exit];
}


#pragma mark -------- NSURLSessionDownloadDelegate -----------
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    self.fileReceipt.totalBytesWritten = totalBytesWritten;
    self.fileReceipt.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
    self.fileReceipt.progress.totalUnitCount = self.fileReceipt.totalBytesExpectedToWrite;
    self.fileReceipt.progress.completedUnitCount = self.fileReceipt.totalBytesWritten;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressBlock) {
            self.progressBlock(self.fileReceipt.progress);
        }
    });
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
     PhotonDownloadFileReceipt *receipt = self.fileReceipt;
    if (!receipt.filePath) {
        return;
    }
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:receipt.filePath] error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    if (self.desitinationBlock) {
        self.desitinationBlock(receipt,receipt.filePath);
    }
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    // 避免self dealloc了，导致block代码执行无效
    PhotonDownloadFileReceipt *receipt = self.fileReceipt;
    NSError *responseError = error;
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    if (responseError) {
        receipt.state = PhotonDownloadFileStateFailed;
    }else if(response.statusCode >= 400){
        responseError = [[NSError alloc]initWithDomain:@"" code:response.statusCode userInfo:nil];
        receipt.state = PhotonDownloadFileStateFailed;
    }
    else {
        receipt.state = PhotonDownloadFileStateFinished;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.comBlock) {
            self.comBlock(receipt, responseError);
        }
    });
    [self exit];
}
// 后台传输完成，处理URLSession完成事件
-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    PhotonWeakSelf(self);
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([uploadTasks count] == 0) {
            void(^completionHandler)(void) = [completionHandlerCache objectForKey:weakself.fileURL];
            if (completionHandler) {
                [completionHandlerCache removeObjectForKey:weakself.fileURL];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionHandler();
                }];
            }
        }
    }];
}


// https 证书验证问题
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    if (![challenge.protectionSpace.authenticationMethod isEqualToString:@"NSURLAuthenticationMethodServerTrust"]) return;
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
}

- (void)setDesitination:(PhotonDownloadFileOperationFailureDesitination)desitination{
    _desitinationBlock = [desitination copy];
}

- (void)setCompletionWithError:(PhotonDownloadFileOperationCompletionBlock)completion{
    _comBlock = [completion copy];
}

- (void)setProgerss:(PhotonDownloadFileOperationProgressBlock)progress{
    _progressBlock = [progress copy];
}
- (void)dealloc
{
    [self.session invalidateAndCancel];
    PhotonRemoveObserver(self);
}

- (void)applicationWillTerminate:(NSNotification *)noti{
    [self.session invalidateAndCancel];
}
- (void)applicationDidReceiveMemoryWarning:(NSNotification *)noti{
}


+ (void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        completionHandlerCache = [NSMutableDictionary dictionary];
        id app = [UIApplication sharedApplication].delegate;
        if ([app respondsToSelector:@selector(application:handleEventsForBackgroundURLSession:completionHandler:)]) {
            [self photon_swizzle:[app class] Method:@selector(application:handleEventsForBackgroundURLSession:completionHandler:) withMethod:@selector(photonApplication:handleEventsForBackgroundURLSession:completionHandler:)];
            
        }
    });
}

- (void)photonApplication:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
{
    completionHandlerCache [identifier] = completionHandler;
    [self photonApplication:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
}
@end
