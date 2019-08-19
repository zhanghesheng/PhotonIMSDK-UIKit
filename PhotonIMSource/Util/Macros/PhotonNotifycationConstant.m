//
//  PhotonNotifycationConstant.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/28.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonNotifycationConstant.h"


/**
 *  上传开始
 */
NSString * const PhotonFileUploadStartNotification = @"DeepFileUploadStartNotification";
/**
 *  上传成功
 */
NSString * const PhotonFileUploadSuccessNotification = @"DeepFileUploadSuccessNotification";

/**
 *  文件上传进程
 */
NSString * const PhotonFileUploadProgressNotification = @"DeepFileUploadProgressNotification";

/**
 *  文件上传失败
 */
NSString * const PhotonFileUploadFailureNotification = @"DeepFileUploadFailureNotification";




#define notify(_notificationName, _obj, _userInfoDictionary)

void PhotonNotify(NSString *notificationName, id obj, NSDictionary *userInfoDictionary) {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:notificationName
     object:obj
     userInfo:userInfoDictionary];
}

void PhotonAddObserver(NSString *notificationName, id observer, SEL observerSelector, id obj) {
    
    [[NSNotificationCenter defaultCenter]
     addObserver:observer
     selector:observerSelector
     name:notificationName
     object:obj];
}

void PhotonRemoveObserver(id observer) {
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}
