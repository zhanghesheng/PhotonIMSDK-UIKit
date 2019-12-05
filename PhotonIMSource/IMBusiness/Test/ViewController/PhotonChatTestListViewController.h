//
//  PhotonConversationListViewController.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
// 回话列表页

#import <UIKit/UIKit.h>
#import "PhotonBaseViewController.h"
#import "PhotonChatTestModel.h"
#import "PhotonChatTestCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface PhotonChatTestListViewController : PhotonBaseViewController<PhotonChatTestBaseCellDelegate>
@end

NS_ASSUME_NONNULL_END
