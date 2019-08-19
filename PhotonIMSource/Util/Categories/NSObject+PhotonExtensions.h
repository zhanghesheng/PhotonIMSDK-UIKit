//
//  NSObject+Extentions.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/28.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (PhotonExtensions)
- (id)isNil;

// 方法交换
+ (BOOL)photon_swizzle:(Class)originalClass Method:(SEL)originalSelector withMethod:(SEL)swizzledSelector;


/**
 swizzle 类方法
 
 @param oriSel 原有的方法
 @param swiSel swizzle的方法
 */
+ (void)photon_swizzleClassMethodWithOriginSel:(SEL)oriSel swizzledSel:(SEL)swiSel;

/**
 swizzle 实例方法
 
 @param oriSel 原有的方法
 @param swiSel swizzle的方法
 */
+ (void)photon_swizzleInstanceMethodWithOriginSel:(SEL)oriSel swizzledSel:(SEL)swiSel;

/**
 判断方法是否在子类里override了
 
 @param cls 传入要判断的Class
 @param sel 传入要判断的Selector
 @return 返回判断是否被重载的结果
 */
- (BOOL)photon_isMethodOverride:(Class)cls selector:(SEL)sel;

+ (Class)photon_addMethodToStubClass:(SEL)aSelector;
@end

NS_ASSUME_NONNULL_END
