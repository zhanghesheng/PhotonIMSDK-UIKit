//
//  PhotonNotifycationConstant.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/28.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const PhotonFileUploadStartNotification; // 文件上传开始

extern NSString * const PhotonFileUploadSuccessNotification;// 文件上传成功的通知

extern NSString * const PhotonFileUploadProgressNotification;// 文件上传进程的通知

extern NSString * const PhotonFileUploadFailureNotification;// 文件上传失败通知


void PhotonNotify(NSString *notificationName, id obj, NSDictionary *userInfoDictionary);

void PhotonRemoveObserver(id observer);

void PhotonAddObserver(NSString *notificationName, id observer, SEL observerSelector, id obj);
