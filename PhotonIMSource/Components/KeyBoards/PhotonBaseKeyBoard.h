//
//  PhotonBaseKeyBoard.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PhotonMacros.h"
NS_ASSUME_NONNULL_BEGIN
@protocol PhotonBaseKeyBoardProtocol <NSObject>

@required;
- (CGFloat)keyboardHeight;

@end
@protocol PhotonBaseKeyBoardDelegate <NSObject>

@optional
- (void)chatKeyboardWillShow:(id)keyboard animated:(BOOL)animated;

- (void)chatKeyboardDidShow:(id)keyboard animated:(BOOL)animated;

- (void)chatKeyboardWillDismiss:(id)keyboard animated:(BOOL)animated;

- (void)chatKeyboardDidDismiss:(id)keyboard animated:(BOOL)animated;

- (void)chatKeyboard:(id)keyboard didChangeHeight:(CGFloat)height;

@end

@interface PhotonBaseKeyBoard : UIView<PhotonBaseKeyBoardProtocol>

/// 是否正在展示
@property (nonatomic, assign, readonly) BOOL isShow;

/// 键盘事件回调
@property (nonatomic, weak) id<PhotonBaseKeyBoardDelegate> keyboardDelegate;

/**
 *  显示键盘(在keyWindow上)
 *
 *  @param animation 是否显示动画
 */
- (void)showWithAnimation:(BOOL)animation;

/**
 *  显示键盘
 *
 *  @param view      父view
 *  @param animation 是否显示动画
 */
- (void)showInView:(UIView *)view withAnimation:(BOOL)animation;

/**
 *  键盘消失
 *
 *  @param animation 是否显示消失动画
 */
- (void)dismissWithAnimation:(BOOL)animation;

/**
 *  重置键盘
 */
- (void)reset;

@end

NS_ASSUME_NONNULL_END
