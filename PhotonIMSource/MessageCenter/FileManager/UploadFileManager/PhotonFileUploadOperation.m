//
//  PhotonFileUploadOperation.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/28.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonFileUploadOperation.h"
@interface PhotonFileUploadOperation()
@property (nonatomic, strong) PhotonNetworkService *netService;
@property (nonatomic, strong) NSString *queryString;
@property (nonatomic, strong) NSDictionary *paramter;
@property (nonatomic, strong) NSArray *fileItems;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

@property (nonatomic, copy) NSString *filePath;

/**
 *  进度回调block
 */
@property (nonatomic,copy)void (^progressBlock)(NSProgress *);

/**
 *  完成回调block
 */
@property (nonatomic,copy)void (^completeBlock)(NSDictionary *);

/**
 *  失败回调block
 */
@property (nonatomic,copy)void (^failureBlock)(PhotonErrorDescription *);

@property (nonatomic, assign)CGFloat uplaodErrorCount;

//@property (nonatomic , strong) DeepBaseModel *baseModel;
@end
@implementation PhotonFileUploadOperation
- (instancetype)initUploadRequestMethodWithMutiFile:(NSString *)queryString
                                           paramter:(nonnull NSDictionary *)paramter
                                          fromFiles:(NSArray *)fileItems
                                           progress:(void(^)(NSProgress *))progress
                                         completion:(void (^)(NSDictionary *))completion
                                            failure:(void (^)(PhotonErrorDescription *))failure{
    self = [super init];
    if (self) {
        self.progressBlock = progress;
        self.completeBlock = completion;
        self.failureBlock = failure;
        self.queryString = queryString;
        self.paramter = paramter;
        self.fileItems = fileItems;
        PhotonUploadFileInfo *fileInfo = (PhotonUploadFileInfo *)[fileItems firstObject];
        self.filePath = fileInfo.fileURLString;
    }
    
    return self;
    
}
- (void)start{
    @autoreleasepool {
        if (self.isCancelled) {
            [self exit];
            return;
        }
        self.uplaodErrorCount = 0;
        self.executing = YES;
        self.finished = NO;
        [self upload];
    }
}
- (void)exit{
    self.finished =  YES;
    self.executing = NO;
}
- (void)upload{
    /*开始上传文件*/
    PhotonWeakSelf(self)
    
    NSDictionary *userInfo = @{@"filePath":self.filePath?self.filePath:@""};
    
    PhotonNotify(PhotonFileUploadStartNotification, nil, userInfo);// 开始上传的通知
    [self.netService uploadRequestMethodWithMutiFile:self.queryString paramter:self.paramter fromFiles:self.fileItems progress:^(NSProgress * _Nonnull progress) {
        if (weakself.progressBlock) {
            weakself.progressBlock(progress);
        }
    } completion:^(NSDictionary * _Nonnull dict) {
        if (weakself.completeBlock) {
            weakself.completeBlock(dict);
        }
        [weakself exit];
    } failure:^(PhotonErrorDescription * _Nonnull error) {
        if (weakself.uplaodErrorCount == 2) {// 失败两次结束上传
            PhotonNotify(PhotonFileUploadFailureNotification, nil, userInfo);// 上传失败
            weakself.failureBlock(error);
            [weakself exit];
        }else{
            self.uplaodErrorCount ++;
            [weakself upload];
        }
        
    }];
    
}

- (void)suspend{
    [self.netService requestSuspend];
}

- (void)resume{
    [self.netService requestResume];
}

- (void)cancle{
    [self.netService requestCancle];
    [super cancel];
}
- (PhotonNetworkService *)netService{
    if (!_netService) {
        _netService = [[PhotonNetworkService alloc]init];
        _netService.baseUrl = PHOTON_BASE_URL;
    }
    return _netService;
}
- (BOOL)isConcurrent
{
    return NO;
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
- (void)dealloc{
    PhotonRemoveObserver(self);
}
@end
