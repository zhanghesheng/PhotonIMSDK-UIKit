//
//  PhotonUploadFileInfo.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface PhotonUploadFileInfo : NSObject<NSCoding>
@property (nonatomic, copy,nullable) NSString *fileURLString;
@property (nonatomic, strong,nullable) NSData *sourceData;
@property (nonatomic, copy,nullable) NSString *name;
@property (nonatomic, copy,nullable) NSString *fileName;
@property (nonatomic, copy,nullable) NSString *mimeType;
@end

NS_ASSUME_NONNULL_END
