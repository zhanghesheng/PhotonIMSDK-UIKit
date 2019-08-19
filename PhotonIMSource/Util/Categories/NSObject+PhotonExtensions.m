//
//  NSObject+Extentions.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/28.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "NSObject+PhotonExtensions.h"
#import <objc/runtime.h>
char * const kPhotonProtectCrashProtectorName = "kPhotonProtectCrashProtectorName";

void ProtectCrashProtected(id self, SEL sel) {
}
@implementation NSObject (PhotonExtensions)
- (id)isNil{
    if(self == [NSNull null]){
        return nil;
    }
    return self;
}

+ (BOOL)photon_swizzle:(Class)originalClass Method:(SEL)originalSelector withMethod:(SEL)swizzledSelector
{
    if (!(originalClass && originalSelector && swizzledSelector)) {
        return NO;
    }
    
    Class class = [self class];
    
    IMP newMetohIMP = class_getMethodImplementation(class, swizzledSelector);
    // 原方法
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    
    class_addMethod(originalClass, swizzledSelector, newMetohIMP, method_getTypeEncoding(originalMethod));
    
    Method swizzledMethod = class_getInstanceMethod(originalClass, swizzledSelector);
    
    // 要交换的方法
    method_exchangeImplementations(originalMethod, swizzledMethod);
    
    return YES;
}

+ (void)photon_swizzleClassMethodWithOriginSel:(SEL)oriSel swizzledSel:(SEL)swiSel {
    Class cls = object_getClass(self);
    
    Method originAddObserverMethod = class_getClassMethod(cls, oriSel);
    Method swizzledAddObserverMethod = class_getClassMethod(cls, swiSel);
    
    [self swizzleMethodWithOriginSel:oriSel oriMethod:originAddObserverMethod swizzledSel:swiSel swizzledMethod:swizzledAddObserverMethod class:cls];
}

+ (void)photon_swizzleInstanceMethodWithOriginSel:(SEL)oriSel swizzledSel:(SEL)swiSel {
    Method originAddObserverMethod = class_getInstanceMethod(self, oriSel);
    Method swizzledAddObserverMethod = class_getInstanceMethod(self, swiSel);
    
    [self swizzleMethodWithOriginSel:oriSel oriMethod:originAddObserverMethod swizzledSel:swiSel swizzledMethod:swizzledAddObserverMethod class:self];
}

+ (void)swizzleMethodWithOriginSel:(SEL)oriSel
                         oriMethod:(Method)oriMethod
                       swizzledSel:(SEL)swizzledSel
                    swizzledMethod:(Method)swizzledMethod
                             class:(Class)cls {
    BOOL didAddMethod = class_addMethod(cls, oriSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSel, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, swizzledMethod);
    }
}

+ (Class)photon_addMethodToStubClass:(SEL)aSelector {
    Class ProtectCrashProtector = objc_getClass(kPhotonProtectCrashProtectorName);
    
    if (!ProtectCrashProtector) {
        ProtectCrashProtector = objc_allocateClassPair([NSObject class], kPhotonProtectCrashProtectorName, sizeof([NSObject class]));
        objc_registerClassPair(ProtectCrashProtector);
    }
    
    class_addMethod(ProtectCrashProtector, aSelector, (IMP)ProtectCrashProtected, "v@:");
    return ProtectCrashProtector;
}

- (BOOL)photon_isMethodOverride:(Class)cls selector:(SEL)sel {
    IMP clsIMP = class_getMethodImplementation(cls, sel);
    IMP superClsIMP = class_getMethodImplementation([cls superclass], sel);
    
    return clsIMP != superClsIMP;
}

@end
