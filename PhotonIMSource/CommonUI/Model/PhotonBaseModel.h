//
//  PhotonBaseModel.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotonNetworkService.h"
#import <PhotonIMSDK/PhotonIMSDK.h>

NS_ASSUME_NONNULL_BEGIN


@protocol PhotonBaseModelDelegate <NSObject>

@end

@interface PhotonBaseModel : NSObject
@property(nonatomic, strong, readonly, nullable)PhotonNetworkService  *netService;
@property(nonatomic, strong,nullable) PhotonIMThreadSafeArray *items;
@property(nonatomic, weak) id <PhotonBaseModelDelegate> delegate;

// 分页的加载的使用
@property(nonatomic, assign) NSInteger pageSize;
@property(nonatomic, assign) NSInteger pageNumber;
@property(nonatomic, assign) BOOL hasNext;
@property(nonatomic, assign) BOOL loading;

- (void)loadItems:(nullable NSDictionary *)params
       finish:(void (^)(NSDictionary * _Nullable))finish
          failure:(void (^)(PhotonErrorDescription * _Nullable))failure;

- (void)wrappResponseddDict:(NSDictionary *)dict;

- (NSArray *)insertItem:(id)item;



@end

NS_ASSUME_NONNULL_END
