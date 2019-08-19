//
//  PhotonNetworkRequest.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotonNetworkProtocol.h"
#import "PhotonUploadFileInfo.h"
NS_ASSUME_NONNULL_BEGIN

extern NSString *const PhotonRequestMethodGet;
extern NSString *const PhotonRequestMethodPost;
extern NSString *const PhotonRequestMethodPut;
extern NSString *const PhotonRequestMethodDelete;
extern NSString *const PhotonRequestMethodHEAD;
extern NSString *const PhotonServiceMethod;

extern NSString *const PhotonRequesUpLoadData;
extern NSString *const PhotonRequesUpLoadFile;
extern NSString *const PhotonRequesUpLoadMultiFile;
@protocol PhotonNetworkRequestDelegate <NSObject>

@optional

- (void)requestFinished:(id<PhotonNetworkProtocol>)request;
- (void)requestFailed:(id<PhotonNetworkProtocol>)request;
- (NSURLRequest*) redirectRequestForRequest:(NSURLRequest*) request;

@end

typedef void (^PhotonNetworkCompletionBlock)(void);

typedef void (^PhotonNetworkLoadProgressBlock)(NSProgress * _Nonnull uploadProgress);

typedef void (^PhotonNetworkDownLoadCompletionBlock)(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath);

typedef void (^PhotonNetworkUpLoadCompletionBlock)(NSURLResponse * _Nonnull response, id  _Nullable responseObject);


@interface PhotonNetworkRequest : NSObject<PhotonNetworkProtocol>

/**
 *  请求方法，get post，put等请求
 */
@property (nonatomic, copy) NSString *requestMethod;

/**
 *  请求头部信息
 */
@property (nonatomic, strong,nullable) NSMutableDictionary *requestHeaders;

/**
 *  相应头信息
 */
@property(nonatomic, strong,nullable) NSDictionary *responseHeaders;

/**
 *  相应返回的主体数据
 */
@property(nonatomic, strong) NSData *responseData;

/**
 *  单文件上传请求的主体数据
 */
@property(nonatomic, strong) NSData *uploadBody;

/**
 *  单文件上传的文件路径
 */
@property (nonatomic, copy) NSString *fileUrlString;

/**
 *  多文件上传包含的多文件信息（QSNetworkUploadFileBVO）
 */
@property (nonatomic, strong) NSMutableArray *mutifileItems;

/**
 *  文件下载保存的路径
 */
@property (nonatomic, strong) NSURL *destinationUrl;

@property(nonatomic, strong) NSURLRequest *request;

/**
 *  请求操作失败的error信息
 */
@property(nonatomic, strong) NSError *error;

/**
 *  请求操作是否被取消，默认值是NO
 */
@property(nonatomic) BOOL isCancelled;

// 请求参数
@property (nonatomic,strong) NSMutableDictionary *parameters;


@property(nonatomic, weak) id<PhotonNetworkRequestDelegate> delegate;

+ (instancetype)initWithUrl:(NSString *)urlString andParamer:(NSDictionary *)paramter;

- (void)sendRequest;

- (void)sendDownLoad;

- (void)sendUpLoad;

- (NSUInteger) responseStatusCode;
- (NSString *)responseString;

/**
 *  一般的加载完成
 *
 *  @param aCompletionBlock <#aCompletionBlock description#>
 */
- (void)setCompletionBlock:(PhotonNetworkCompletionBlock)aCompletionBlock;

/**
 *  一般的请求加载失败
 *
 *  @param aFailedBlock <#aFailedBlock description#>
 */

- (void)setFailedBlock:(PhotonNetworkCompletionBlock)aFailedBlock;

- (void)setDownLoadCompletionBlock:(PhotonNetworkDownLoadCompletionBlock)aDownLoadCompletionBlock;


- (void)setUpLoadCompletionBlock:(PhotonNetworkUpLoadCompletionBlock)aUpLoadCompletionBlock;

/**
 *  加载进度
 *
 *  @param aLoadProgressBlock 进度获取
 */
- (void)setLoadProgressBlock:(PhotonNetworkLoadProgressBlock)aLoadProgressBlock;

/*
 添加header参数
 */
- (void)addRequestHeader:(NSString *)header value:(NSString *)value;

/*
 设置post参数
 */
- (void)setPostValue:(id <NSObject>)value forKey:(NSString *)key;

/*
 取消下载
 */
- (void)cancel;

/*
 挂载起来
*/
- (void)suspend;

/*
 重新启用
 */
- (void)resume;
@end

NS_ASSUME_NONNULL_END
