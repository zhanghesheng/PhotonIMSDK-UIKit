//
//  PhotonNetworkProtocol.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#ifndef PhotonNetworkProtocol_h
#define PhotonNetworkProtocol_h
#import <Foundation/Foundation.h>
@protocol PhotonNetworkProtocol<NSObject>
- (void)setDelegate:(id)newDelegate;

- (NSUInteger)responseStatusCode;

- (NSString *)responseString;

- (void)sendRequest;

- (void)sendDownLoad;

- (void)sendUpLoad;

- (void)cancel;
- (void)suspend;
- (void)resume;
@end
#endif
