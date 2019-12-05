//
//  PhotonMacros.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#ifndef PhotonMacros_h
#define PhotonMacros_h
#import "PhotonCommonHeader.h"
#ifdef DEBUG
#define PhotonLog(...) NSLog(__VA_ARGS__)
#else
#define PhotonLog(...)
#endif

#define     IS_IPHONEX              ([UIScreen mainScreen].bounds.size.width == 375.0f && [UIScreen mainScreen].bounds.size.height == 812.0f)

#pragma mark - # 屏幕尺寸
#define     PhotoScreenSize                 [UIScreen mainScreen].bounds.size
#define     PhotoScreenWidth                PhotoScreenSize .width
#define     PhotoScreenHeight               PhotoScreenSize .height

#pragma mark - # 常用控件高度
#define     STATUSBAR_HEIGHT            (IS_IPHONEX ? 44.0f : 20.0f)
#define     TABBAR_HEIGHT               (IS_IPHONEX ? 49.0f + 34.0f : 49.0f)
#define     NAVBAR_HEIGHT               44.0f
#define     SEARCHBAR_HEIGHT            (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0") ? 52.0f : 44.0f)
#define     BORDER_WIDTH_1PX            ([[UIScreen mainScreen] scale] > 0.0 ? 1.0 / [[UIScreen mainScreen] scale] : 1.0)
#define     NavAndStatusHight          self.navigationController.navigationBar.frame.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height

#define     SAFEAREA_INSETS     \
({   \
UIEdgeInsets edgeInsets = UIEdgeInsetsZero; \
if (@available(iOS 11.0, *)) {      \
edgeInsets = [UIApplication sharedApplication].keyWindow.safeAreaInsets;     \
}   \
edgeInsets;  \
})\

#define     SAFEAREA_INSETS_BOTTOM      (SAFEAREA_INSETS.bottom)

#pragma mark - # 设备(屏幕)类型
#define     SCRREN_IPHONE4              (PhotoScreenHeight >= 480.0f)           // 320 * 480
#define     SCRREN_IPHONE5              (PhotoScreenHeight >= 568.0f)           // 320 * 568
#define     SCRREN_IPHONE6              (PhotoScreenHeight >= 667.0f)           // 375 * 667
#define     SCRREN_IPHONE6P             (PhotoScreenHeight >= 736.0f)           // 414 * 736


#pragma mark - # 系统方法简写
/// 颜色
#define     RGBColor(r, g, b)           [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0]
#define     RGBAColor(r, g, b, a)       [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]
#define     HexColor(color)             [UIColor colorWithRed:((float)((color & 0xFF0000) >> 16))/255.0 green:((float)((color & 0xFF00) >> 8))/255.0 blue:((float)(color & 0xFF))/255.0 alpha:1.0]
#define     HexAColor(color, a)         [UIColor colorWithRed:((float)((color & 0xFF0000) >> 16))/255.0 green:((float)((color & 0xFF00) >> 8))/255.0 blue:((float)(color & 0xFF))/255.0 alpha:a]


#pragma mark - # 快捷方法
/// PushVC
#define     PushVC(vc)                  {\
[vc setHidesBottomBarWhenPushed:YES];\
[self.navigationController pushViewController:vc animated:YES];\
}


#pragma mark - # XCode
#define     XCODE_VERSION_8_LATER       __has_include(<UserNotifications/UserNotifications.h>)

#pragma mark - # 系统版本
#define     SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define     SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define     SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define     SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define     SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)



#define     HEIGHT_CHATBAR_TEXTVIEW         30.0f
#define     HEIGHT_MAX_CHATBAR_TEXTVIEW     111.5f
#define     HEIGHT_CHAT_KEYBOARD            215.0f

typedef NS_ENUM(NSInteger, PhotonChatBarStatus) {
    PhotonChatBarStatusInit,
    PhotonChatBarStatusVoice,
    PhotonChatBarStatusEmoji,
    PhotonChatBarStatusMore,
    PhotonChatBarStatusKeyboard,
};

typedef NS_ENUM(NSInteger, AtType) {
    AtTypeNoAt = 0,
    AtTypeAtMember,
    AtTypeAtAll
};

#define DEFAULT_TABLE_CELL_HRIGHT 64.0;

#pragma mark - # ENCODED_AND_DECODED
#define ENCODED_AND_DECODED() \
\
- (instancetype)initWithCoder:(NSCoder *)aDecoder\
{\
Class cls = [self class];\
while (cls != [NSObject class]) {\
BOOL bIsSelfClass = (cls == [self class]);\
unsigned int iVarCount = 0;\
unsigned int proVarCount = 0;\
unsigned int shareVarCount = 0;\
\
Ivar *ivarList = bIsSelfClass? class_copyIvarList([cls class], &iVarCount):NULL;\
objc_property_t *proVarList = bIsSelfClass?NULL:class_copyPropertyList(cls, &proVarCount);\
shareVarCount = bIsSelfClass?iVarCount:proVarCount;\
for (int i = 0; i < shareVarCount; i++) {\
const char *varName = bIsSelfClass? ivar_getName(*(ivarList + i)):property_getName(*(proVarList + i));\
NSString *key = [NSString stringWithUTF8String:varName];\
id varValue = [aDecoder decodeObjectForKey:key];\
if (varValue) {\
[self setValue:varValue forKey:key];\
}\
}\
free(ivarList);\
free(proVarList);\
cls = class_getSuperclass(cls);\
}\
return self;\
}\
- (void)encodeWithCoder:(NSCoder *)aCoder{\
Class cls = [self class];\
while (cls != [NSObject class]) {\
BOOL bIsSelfClass = (cls == [self class]);\
unsigned int iVarCount = 0;\
unsigned int proVarCount = 0;\
unsigned int shareVarCount = 0;\
\
Ivar *ivarList = bIsSelfClass? class_copyIvarList([cls class], &iVarCount):NULL;\
objc_property_t *proVarList = bIsSelfClass?NULL:class_copyPropertyList(cls, &proVarCount);\
shareVarCount = bIsSelfClass?iVarCount:proVarCount;\
for (int i = 0; i < shareVarCount; i++) {\
const char *varName = bIsSelfClass? ivar_getName(*(ivarList + i)):property_getName(*(proVarList + i));\
NSString *key = [NSString stringWithUTF8String:varName];\
id varValue = [self valueForKey:key];\
if (varValue) {\
[aCoder encodeObject:varValue forKey:key];\
}\
}\
free(ivarList);\
free(proVarList);\
cls = class_getSuperclass(cls);\
}\
}

#pragma mark - 弱引用/强引用
#define PhotonWeakSelf(type)  __weak typeof(type) weak##type = type;
#define PhotonStrongSelf(type)  __strong typeof(type) type = weak##type;

#endif
