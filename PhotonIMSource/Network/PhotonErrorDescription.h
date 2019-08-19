//
//  PhotonErrorDescription.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotonErrorDescription : NSObject
@property (nonatomic) NSInteger errorCode;
@property (nonatomic, copy, nullable) NSString *errorMessage;
@property (nonatomic, copy, nullable) NSString *urlString;
@property (nonatomic, copy, nullable) NSString *tag;
@property (nonatomic, strong, nullable) NSObject *userInfo;
@property (nonatomic) BOOL isCancelled;
@end

NS_ASSUME_NONNULL_END
