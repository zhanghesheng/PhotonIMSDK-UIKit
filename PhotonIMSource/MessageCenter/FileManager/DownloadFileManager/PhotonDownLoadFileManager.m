//
//  PhotonDownLoadFileManager.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/4.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonDownLoadFileManager.h"
#import "PhotonDownloadFileReceipt.h"
@interface PhotonDownLoadFileManager()
/**
 *  下载队列,可以控制并发数
 */
@property (nonatomic,strong)NSOperationQueue *downloadQueue;
@end
static PhotonDownLoadFileManager *fileManager = nil;
@implementation PhotonDownLoadFileManager
+ (instancetype)defaultManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileManager = [[PhotonDownLoadFileManager alloc] init];
    });
    return fileManager;
}
- (void)downloadFileWithReceipt:(nullable PhotonDownloadFileReceipt *)fileReceipt
                       progress:(nullable PhotonDownloadFileOperationProgressBlock)downloadProgressBlock
                    destination:(nullable PhotonDownloadFileOperationFailureDesitination)destination
                        success:(nullable PhotonDownloadFileOperationCompletionBlock)success{
    
    BOOL isInOperations = NO;
    NSArray *operations = self.downloadQueue.operations;
    for(PhotonDownLoadFileOperation *operation in operations) {
        if ([operation.fileURL isEqualToString:fileReceipt.url]) {
            isInOperations = YES;
        }
    }
    if (isInOperations) {
        return;
    }
    
    PhotonDownloadFileReceipt *receipt = fileReceipt;
    
    if (receipt.state == PhotonDownloadFileStateWaiting ||
        receipt.state == PhotonDownloadFileStateDownloading) {
        return;
    }
    PhotonDownLoadFileOperation *operation = [[PhotonDownLoadFileOperation alloc] initWithReceipt:receipt];
    
    [operation setProgerss:^(NSProgress * _Nullable progress) {
        if (downloadProgressBlock) {
            downloadProgressBlock(progress);
        }
    }];
    
    [operation setCompletionWithError:^(PhotonDownloadFileReceipt * _Nullable receipt, NSError * _Nullable error) {
        if (success) {
            success(receipt,error);
        }
        
    }];
    
    [operation setDesitination:^(PhotonDownloadFileReceipt * _Nullable receipt, NSString * _Nullable location) {
        if (destination) {
             destination(receipt,location);
        }
    }];
    
    [self.downloadQueue addOperation:operation];
}

// 根据url停止某个操作
- (void)stopOperationWith:(NSString *)url{
    for (PhotonDownLoadFileOperation *operation in self.downloadQueue.operations) {
        if([url isEqualToString:operation.fileURL]){
            if (operation.isReady) {
                [operation cancel];
            }
        }
    }
}

- (void)cancelAllDownLoad{
    for (PhotonDownLoadFileOperation *operation in self.downloadQueue.operations) {
        if(operation.isExecuting){
            [operation cancelDownload];
            [operation cancel];
        }
        if (operation.isReady) {
            [operation cancel];
        }
    }
    [self.downloadQueue cancelAllOperations];
}
#pragma mark ----- 数据懒加载 ------
- (NSOperationQueue *)downloadQueue{
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc]init];
    }
    
    if(self.queueCount){
        _downloadQueue.maxConcurrentOperationCount = [self.queueCount integerValue];
    }else{
        _downloadQueue.maxConcurrentOperationCount = 3;
    }
    
    return _downloadQueue;
}


- (void)dealloc{
}
@end
