//
//  PhotonNetworkService.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotonMacros.h"
#import "PhotonAPIMacros.h"
#import "PhotonNetworkWrapper.h"
NS_ASSUME_NONNULL_BEGIN

@interface PhotonNetworkService : PhotonNetworkWrapper
@property (nonatomic, copy) NSString *baseUrl;

- (void)setRequestHeader:(NSString *)value key:(NSString *)key;
/**
 *  get post put 请求
 *
 *  @param queryString 请求url
 *  @param paramter    请求参数
 *  @param completion  请求完成回调
 *  @param failure     请求失败回调
 */
- (void)commonRequestMethod:(NSString *)method
                queryString:(NSString *)queryString
                   paramter:(nullable NSDictionary *)paramter
                 completion:(void (^)(NSDictionary * _Nullable))completion
                    failure:(void (^)(PhotonErrorDescription * _Nullable))failure;

/**
 *  文件下载
 *
 *  @param queryString <#queryString description#>
 *  @param documentsDirectoryURL    documentsDirectoryURL description
 *  @param progress    <#progress description#>
 *  @param completion  <#completion description#>
 *  @param failure     <#failure description#>
 */
//下载文件
- (void)downLoadRequestMethod:(NSString *)queryString
        documentsDirectoryURL:(NSURL *)documentsDirectoryURL
                     progress:(void(^)(NSProgress *))progress
                   completion:(void (^)(NSDictionary * _Nullable))completion
                      failure:(void (^)(PhotonErrorDescription * _Nullable))failure;

/**
 *  单文件上传
 *
 *  @param queryString 请求的url
 *  @param bodyData    上传的body信息
 *  @param progress    上传进度
 *  @param completion  上传是否完成
 *  @param failure     上传失败信息
 *
 */
- (void)uploadRequestMethodWithBodyData:(NSString *)queryString
                               fromData:(NSData *)bodyData
                               progress:(void(^)(NSProgress *))progress
                             completion:(void (^)(NSDictionary *))completion
                                failure:(void (^)(PhotonErrorDescription *))failure;


- (void)uploadRequestMethodWithData:(NSString *)queryString
                           paramter:(nullable NSDictionary *)paramter
                          fromFiles:(NSArray<PhotonUploadFileInfo *> *)fileItems
                           progress:(void(^)(NSProgress *))progress
                         completion:(void (^)(NSDictionary *))completion
                            failure:(void (^)(PhotonErrorDescription *))failure;

/**
 *  单文件上传
 *
 *  @param queryString 请求的url
 *  @param paramter    上传的文件的请求
 *  @param filePath    上传的文件的路径信息
 *  @param progress    上传进度
 *  @param completion  上传完成回调
 *  @param failure     上传失败回调
 */
- (void)uploadRequestMethodWithFileURL:(NSString *)queryString
                              paramter:(NSDictionary *)paramter
                              filePath:(NSString *)filePath
                              progress:(void(^)(NSProgress *))progress
                            completion:(void (^)(NSDictionary *))completion
                               failure:(void (^)(PhotonErrorDescription *))failure;




/**
 *  多文件上传信息
 *
 *  @param queryString 请求的url
 *  @param fileItems   上传时包含的多文件信息
 *  @param progress    上传进度
 *  @param completion  上传完成回调
 *  @param failure     上传失败回调
 */
- (void)uploadRequestMethodWithMutiFile:(NSString *)queryString
                               paramter:(nonnull NSDictionary *)paramter
                              fromFiles:(NSArray *)fileItems
                               progress:(void(^)(NSProgress *))progress
                             completion:(void (^)(NSDictionary *))completion
                                failure:(void (^)(PhotonErrorDescription *))failure;



/**
 *  回复下载任务
 */
- (void)requestResume;
/**
 *  暂停下载任务
 */
- (void)requestSuspend;
/**
 *  取消下载任务
 */
- (void)requestCancle;

@end

NS_ASSUME_NONNULL_END
