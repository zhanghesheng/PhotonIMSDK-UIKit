//
//  PhotonFileUploadManager.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/28.
//  Copyright © 2019 Bruce. All rights reserved.
// 文件上传管理

#import "PhotonFileUploadManager.h"
@interface PhotonFileUploadManager()
@property (nonatomic, strong) NSMutableDictionary *uploadCache;
/**
 *  下载队列,可以控制并发数
 */
@property (nonatomic,strong)NSOperationQueue *uploadQueue;

@end
@implementation PhotonFileUploadManager
+ (instancetype)defaultManager{
    static dispatch_once_t onceToken;
    static PhotonFileUploadManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (void)uploadRequestMethodWithMutiFile:(NSString *)queryString
                               paramter:(nullable NSDictionary *)paramter
                              fromFiles:(NSArray *)fileItems
                          progressBlock:(void(^)(NSProgress *))progressBlock
                             completion:(void (^)(NSDictionary *))completion
                                failure:(void (^)(PhotonErrorDescription *))failure{
    
    if (fileItems.count == 0) {
        return;
    }
    PhotonFileUploadOperation *uploadOperation = [[PhotonFileUploadOperation  alloc]initUploadRequestMethodWithMutiFile:queryString paramter:paramter fromFiles:fileItems progress:^(NSProgress *  progress) {
        progressBlock(progress);
    } completion:^(NSDictionary * _Nonnull dict) {
        completion(dict);
    } failure:^(PhotonErrorDescription * _Nonnull error) {
        failure(error);
    }];
    [self.uploadQueue addOperation:uploadOperation];
}

- (NSOperationQueue *)uploadQueue{
    if (!_uploadQueue) {
        _uploadQueue = [[NSOperationQueue alloc]init];
    }
    _uploadQueue.maxConcurrentOperationCount = 3;
    return _uploadQueue;
}

#pragma mark -数据懒加载
- (NSMutableDictionary *)uploadCache{
    if (_uploadCache == nil) {
        _uploadCache = [NSMutableDictionary dictionary];
    }
    return _uploadCache;
}

@end
