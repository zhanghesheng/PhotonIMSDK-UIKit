//
//  PhotonMenuView.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/24.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PhontonMenuItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,PhotonMenuType){
    PhotonMenuTypeCopy,
    PhotonMenuTypeWithdraw,
    PhotonMenuTypeDelete,
    PhotonMenuTypeTransmit
};

@protocol PhotonMenuViewDelegate <NSObject>
- (void)didSelectedItemWithType:(PhotonMenuType)Type obj:(id)obj;
@end

@interface PhotonMenuView : UIView
@property(nonatomic, weak, nullable)id<PhotonMenuViewDelegate> delegate;
@property(nonatomic, strong, nullable)id obj;
@property(nonatomic, assign)BOOL isShow;
- (void)showMenuInSuperView:(UIView *)view rect:(CGRect)rect animation:(BOOL)animation;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
