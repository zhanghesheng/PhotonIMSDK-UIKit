//
//  PhotonImageMessageChatItem.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/22.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseChatItem.h"
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface PhotonImageMessageChatItem : PhotonBaseChatItem
@property (nonatomic, copy, nullable)NSString  *fileName;
@property (nonatomic, strong, nullable)NSString *orignURL;
@property (nonatomic, strong, nullable)NSString *thumURL;
@property (nonatomic, assign)CGFloat whRatio;
@end

NS_ASSUME_NONNULL_END
