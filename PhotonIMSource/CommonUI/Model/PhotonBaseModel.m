//
//  PhotonBaseModel.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseModel.h"
@interface PhotonBaseModel()
@property(nonatomic, strong, nullable)PhotonNetworkService  *netService;
@end

@implementation PhotonBaseModel
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
- (void)loadItems:(nullable NSDictionary *)params finish:(void (^)(NSDictionary * _Nullable))finish failure:(void (^)(PhotonErrorDescription * _Nullable))failure{
    [self.items removeAllObjects];
}
- (void)wrappResponseddDict:(NSDictionary *)dict{
}
- (PhotonIMThreadSafeArray *)items{
    if (!_items) {
        _items = [PhotonIMThreadSafeArray array];
    }
    return _items;
}

- (PhotonNetworkService *)netService{
    if (!_netService) {
        _netService = [[PhotonNetworkService alloc] init];
        _netService.baseUrl = PHOTON_BASE_URL;
        
    }
    return _netService;
}

@end
