//
//  PhotonDownLoadFileManager.h
//  PhotonIM
//
//  Created by Bruce on 2019/7/4.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotonDownLoadFileOperation.h"
NS_ASSUME_NONNULL_BEGIN
@interface PhotonDownLoadFileManager : NSObject
@property (nonatomic,strong)NSNumber *queueCount;
@property (nonatomic,strong, readonly)NSOperationQueue *downloadQueue;
+ (instancetype)defaultManager;


// 开始文件的下载
- (void)downloadFileWithReceipt:(nullable PhotonDownloadFileReceipt *)fileReceipt
                   progress:(nullable PhotonDownloadFileOperationProgressBlock)downloadProgressBlock
                destination:(nullable PhotonDownloadFileOperationFailureDesitination)destination
                    success:(nullable PhotonDownloadFileOperationCompletionBlock)success;
// 取消所有下载操作
- (void)cancelAllDownLoad;

// 取消等待的某个队列
- (void)stopOperationWith:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
