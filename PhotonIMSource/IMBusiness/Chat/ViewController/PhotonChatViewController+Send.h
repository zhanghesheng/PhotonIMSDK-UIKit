//
//  PhotonChatViewController+Send.h
//  PhotonIM
//
//  Created by Bruce on 2019/7/11.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotonChatViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface PhotonChatViewController (Send)
- (void)resendMessage:(PhotonBaseChatItem *)item;
@end

NS_ASSUME_NONNULL_END
