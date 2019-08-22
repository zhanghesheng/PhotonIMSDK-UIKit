//
//  PhotonUtil.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/26.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonUtil.h"
#import "PhotonMacros.h"
#import <SVProgressHUD/SVProgressHUD.h>
@implementation PhotonUtil

+ (NSString *)getCookie{
    if ([[PhotonContent userDetailInfo].sessionID isNotEmpty]) {
        NSString *cookie = [NSString stringWithFormat:@"sessionId=%@",[PhotonContent userDetailInfo].sessionID];
        return cookie;
    }
    return @"";
}
+ (BOOL)createDirectoryIfExit:(NSString *)dPath{
    if (![self jugdeFileExit:dPath]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:dPath withIntermediateDirectories:YES attributes:nil error:&error];
        if(error){
            return NO;
        }
         return YES;
    }
    return YES;
}

+ (BOOL)jugdeFileExit:(NSString *)path{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}
+ (NSString *)getDownLoadFilePath:(NSString *)fileName{
    NSString *path = [NSString stringWithFormat:@"%@/User/%@/PhotonIM/Local/", [NSFileManager documentsPath], [PhotonContent userDetailInfo].userID];
    if (![self createDirectoryIfExit:path]) {
        return nil;
    }
    return [path stringByAppendingPathComponent:fileName];
}


#pragma mark - # Alert
+ (void)showAlertWithTitle:(nullable NSString *)title
{
    [self showAlertWithTitle:title message:nil];
}

+ (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message
{
    [self showAlertWithTitle:title message:message cancelButtonTitle:nil];
}

+ (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString *)cancelButtonTitle
{
    [self showAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle actionHandler:nil];
}

+ (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString *)cancelButtonTitle actionHandler:(nullable void (^)(NSInteger buttonIndex))actionHandler
{
    [self showAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil actionHandler:actionHandler];
}

+ (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelButtonTitle:(nullable NSString *)cancelButtonTitle otherButtonTitles:(nullable NSArray *)otherButtonTitles actionHandler:(void (^)(NSInteger buttonIndex))actionHandler
{
    cancelButtonTitle = cancelButtonTitle ? cancelButtonTitle : @"取消";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(alertController) weakController = alertController;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSInteger index = [weakController.actions indexOfObject:action];
        if (actionHandler) {
            actionHandler(index);
        }
    }];
    [alertController addAction:cancelAction];
    
    for (NSString *title in otherButtonTitles) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (actionHandler) {
                NSInteger index = [weakController.actions indexOfObject:action];
                actionHandler(index);
            }
        }];
        [alertController addAction:action];
    }
    
    UIViewController *curVC = [(UIWindow *)[UIApplication sharedApplication].keyWindow visibleViewController];
    [curVC presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - # HUD Loading ----
+ (void)showLoading:(nullable NSString *)hintText
{
    [SVProgressHUD showWithStatus:nil];
}

+ (void)hiddenLoading
{
    [self hiddenLoadingWithCompletion:^{
        
    }];
}

+ (void)hiddenLoadingWithDelay:(NSTimeInterval)delay
{
    [self hiddenLoadingWithDelay:delay completion:^{
        
    }];
}

+ (void)hiddenLoadingWithCompletion:(nullable void (^)(void))completion
{
    [SVProgressHUD dismissWithCompletion:completion];
}

+ (void)hiddenLoadingWithDelay:(NSTimeInterval)delay completion:(nullable void (^)(void))completion
{
    [SVProgressHUD dismissWithDelay:delay completion:completion];
}

+ (void)showSuccessHint:(nullable NSString *)hintText
{
    [SVProgressHUD showSuccessWithStatus:hintText];
}

+ (void)showErrorHint:(nullable NSString *)hintText
{
    [SVProgressHUD showErrorWithStatus:hintText];
}

+ (void)showInfoHint:(nullable NSString *)hintText
{
    [SVProgressHUD showInfoWithStatus:hintText];
}

+ (BOOL)isShowLoading
{
    return [SVProgressHUD isVisible];
}


// 处理时间显示的逻辑
static NSTimeInterval lastDateInterval = 0;
+ (BOOL)itemNeedShowTime:(NSDate *)date{
    NSTimeInterval timeStamp = date.timeIntervalSince1970;
    NSTimeInterval duration = 0;
    if (timeStamp > lastDateInterval) {
        duration = timeStamp - lastDateInterval;
    }else{
        duration = lastDateInterval - timeStamp;
    }
    if (lastDateInterval == 0 || duration > 5.0 * 60) {
        lastDateInterval = date.timeIntervalSince1970;
        return YES;
    }
    return NO;
}

+ (void)resetLastShowTimestamp{
    lastDateInterval = 0;
}


+ (NSDate *)getLocalDate:(NSTimeInterval)timeStamp{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return localeDate;
}


+ (id)noNilString:(NSString *)str{
    if (!str || str.length == 0) {
        return @"";
    }
    return str;
}

+ (void)runMainThread:(dispatch_block_t)block{
    if ([NSThread isMainThread]) {
        block();
    }else{
        dispatch_async(dispatch_get_main_queue(), block);
    }
    
}
@end
