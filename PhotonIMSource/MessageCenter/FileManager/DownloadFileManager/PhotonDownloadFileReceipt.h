//
//  PhotonDownloadFileReceipt.h
//  PhotonIM
//
//  Created by Bruce on 2019/7/4.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/** The download state */
typedef NS_ENUM(NSUInteger, DeepDownloadFileState) {
    PhotonDownloadFileStateNone = 0,            // 创建新的实例时所处状态
    PhotonDownloadFileStateWaiting,              // 等待中（前面还有正在下载的操作）
    PhotonDownloadFileStateDownloading,         // 下载中
    PhotonDownloadFileStatePaused,              // 暂停
    PhotonDownloadFileStateFinished,            // 完成
    PhotonDownloadFileStateFailed               // 失败
};

@interface PhotonDownloadFileReceipt : NSObject
/**
 *  传入的外部对象指针
 */
@property (nonatomic, strong, nullable) id object;
/**
 *  下载文件的url
 */
@property (nonatomic, copy, nullable) NSString *url;


/**
 *  文件保存的路径
 */
@property (nonatomic, copy, nullable) NSString *filePath;

/**
 *  文件名
 */
@property (nonatomic, copy, nullable) NSString *filename;

/**
 *  下载的状态
 */
@property (nonatomic, assign) DeepDownloadFileState state;

/**
 *  下载的进度信息
 */
@property (nonatomic, copy, nullable) NSProgress *progress;

/**
 *  总的文件写入
 */
@property (assign, nonatomic) long long totalBytesWritten;

/**
 *  剩余文件的未写入
 */
@property (assign, nonatomic) long long totalBytesExpectedToWrite;

/**
 *  断开下载后恢复下载
 */
@property (nonatomic, strong, nullable) NSData *resumeData;
- (instancetype)initWithURL:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
