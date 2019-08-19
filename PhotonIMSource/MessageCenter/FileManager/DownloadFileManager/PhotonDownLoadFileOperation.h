//
//  PhotonDownLoadFileOperation.h
//  PhotonIM
//
//  Created by Bruce on 2019/7/4.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotonMacros.h"
#import "PhotonDownloadFileReceipt.h"
NS_ASSUME_NONNULL_BEGIN
/**
 *  进度回调block
 */
typedef void (^PhotonDownloadFileOperationProgressBlock)(NSProgress * _Nullable);
typedef void (^PhotonDownloadFileOperationCompletionBlock)(PhotonDownloadFileReceipt * _Nullable, NSError *_Nullable);
typedef void (^PhotonDownloadFileOperationFailureDesitination)(PhotonDownloadFileReceipt * _Nullable, NSString *_Nullable);
@interface PhotonDownLoadFileOperation : NSOperation

@property (nonatomic, copy, readonly) NSString *fileURL;/*文件下载路径*/
/*
 *初始化下载描述
 */
- (instancetype)initWithReceipt:(PhotonDownloadFileReceipt *)receipt;

/*
 *下载进度回调
 */
- (void)setProgerss:(PhotonDownloadFileOperationProgressBlock)progress;
/*
 *下载完成回调
 */
- (void)setCompletionWithError:(PhotonDownloadFileOperationCompletionBlock)completion;
/*
 *下载存储后回调
 */
- (void)setDesitination:(PhotonDownloadFileOperationFailureDesitination)desitination;

/*
 *取消下载
 */
- (void)cancelDownload;
@end

NS_ASSUME_NONNULL_END
