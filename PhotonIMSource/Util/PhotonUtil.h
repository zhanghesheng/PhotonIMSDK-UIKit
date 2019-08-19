//
//  PhotonUtil.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/26.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface PhotonUtil : NSObject

#pragma mark ----------- cookie Manager -----------
+ (NSString *)getCookie;

#pragma mark ----------- File Manager -----------


+ (BOOL)jugdeFileExit:(NSString *)path;


+ (BOOL)createDirectoryIfExit:(NSString *)dPath;

#pragma mark ----------- Alert -----------
+ (void)showAlertWithTitle:(nullable NSString *)title;
+ (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message;
+ (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString *)cancelButtonTitle;
+ (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString *)cancelButtonTitle actionHandler:(nullable void (^)(NSInteger buttonIndex))actionHandler;
+ (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSArray *)otherButtonTitles actionHandler:(nullable void (^)(NSInteger buttonIndex))actionHandler;

#pragma mark ----------- HUD Loding -----------
+ (void)showLoading:(nullable NSString *)title;
+ (void)hiddenLoading;
+ (void)hiddenLoadingWithDelay:(NSTimeInterval)delay;
+ (void)hiddenLoadingWithCompletion:(nullable void (^)(void))completion;
+ (void)hiddenLoadingWithDelay:(NSTimeInterval)delay completion:(nullable void (^)(void))completion;

+ (void)showSuccessHint:(nullable NSString *)hintText;
+ (void)showErrorHint:(nullable NSString *)hintText;
+ (void)showInfoHint:(nullable NSString *)hintText;

+ (BOOL)isShowLoading;


#pragma mark -------- 处理聊天页面消息时间展示的规则 -----
+ (BOOL)itemNeedShowTime:(NSDate *)date;

+ (void)resetLastShowTimestamp;

#pragma mark ------ Date ------
// 通过时间戳获取本地的Date
+ (NSDate *)getLocalDate:(NSTimeInterval)timeStamp;


/**
 如果字符为nil，返回@""

 @param str <#str description#>
 @return <#return value description#>
 */
+ (id)noNilString:(NSString *)str;


/**
 在主线程执行

 @param block <#block description#>
 */
+ (void)runMainThread:(dispatch_block_t)block;
@end

NS_ASSUME_NONNULL_END
