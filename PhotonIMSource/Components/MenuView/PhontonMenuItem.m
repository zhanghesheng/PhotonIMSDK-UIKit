//
//  PhontonMenuItem.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/24.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhontonMenuItem.h"
#import <objc/runtime.h>
#import <objc/message.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

NSString *kMenuItemTrailer = @"ps_performMenuItem";

// Add method + swizzle.
void PhontonReplaceMethod(Class c, SEL origSEL, SEL newSEL, IMP impl);
void PhontonReplaceMethod(Class c, SEL origSEL, SEL newSEL, IMP impl) {
    Method origMethod = class_getInstanceMethod(c, origSEL);
    class_addMethod(c, newSEL, impl, method_getTypeEncoding(origMethod));
    Method newMethod = class_getInstanceMethod(c, newSEL);
    if(class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

// Checks for our custom selector.
BOOL PhontonIsMenuItemSelector(SEL selector);
BOOL PhontonIsMenuItemSelector(SEL selector) {
    return [NSStringFromSelector(selector) hasPrefix:kMenuItemTrailer];
}

@interface PhontonMenuItem()
@property(nonatomic, assign) SEL customSelector;
@end

@implementation PhontonMenuItem
+ (void)installMenuHandlerForObject:(id)object {
    @autoreleasepool {
        @synchronized(self) {
            // object can be both a class or an instance of a class.
            Class objectClass = class_isMetaClass(object_getClass(object)) ? object : [object class];
            
            // check if menu handler has been already installed.
            SEL canPerformActionSEL = @selector(phontonCanPerformAction:withSender:);
            if (!class_getInstanceMethod(objectClass, canPerformActionSEL)) {
                
                // add canBecomeFirstResponder if it is not returning YES. (or if we don't know)
                if (object == objectClass || ![object canBecomeFirstResponder]) {
                    SEL canBecomeFRSEL = @selector(phontonCanBecomeFirstResponder);
                    IMP canBecomeFRIMP = imp_implementationWithBlock((^(id _self) {
                        return YES;
                    }));
                    PhontonReplaceMethod(objectClass, @selector(canBecomeFirstResponder), canBecomeFRSEL, canBecomeFRIMP);
                }
                
                // swizzle canPerformAction:withSender: for our custom selectors.
                // Queried before the UIMenuController is shown.
                IMP canPerformActionIMP = imp_implementationWithBlock((^(id _self, SEL action, id sender) {
                    return PhontonIsMenuItemSelector(action) ? YES : ((BOOL (*)(id, SEL, SEL, id))objc_msgSend)(_self, canPerformActionSEL, action, sender);
                }));
                PhontonReplaceMethod(objectClass, @selector(canPerformAction:withSender:), canPerformActionSEL, canPerformActionIMP);
                
                // swizzle methodSignatureForSelector:.
                SEL methodSignatureSEL = @selector(phontonMethodSignatureForSelector:);
                IMP methodSignatureIMP = imp_implementationWithBlock((^(id _self, SEL selector) {
                    if (PhontonIsMenuItemSelector(selector)) {
                        return [NSMethodSignature signatureWithObjCTypes:"v@:@"]; // fake it.
                    }else {
                        return ((NSMethodSignature * (*)(id, SEL, SEL))objc_msgSend)(_self, methodSignatureSEL, selector);
                    }
                }));
                PhontonReplaceMethod(objectClass, @selector(methodSignatureForSelector:), methodSignatureSEL, methodSignatureIMP);
                
                // swizzle forwardInvocation:
                SEL forwardInvocationSEL = @selector(phontonForwardInvocation:);
                IMP forwardInvocationIMP = imp_implementationWithBlock((^(id _self, NSInvocation *invocation) {
                    if (PhontonIsMenuItemSelector([invocation selector])) {
                        for (PhontonMenuItem *menuItem in [UIMenuController sharedMenuController].menuItems) {
                            if ([menuItem isKindOfClass:[PhontonMenuItem class]] && sel_isEqual([invocation selector], menuItem.customSelector)) {
                                [menuItem performBlock]; break; // find corresponding MenuItem and forward
                            }
                        }
                    }else {
                        ((void (*)(id, SEL, NSInvocation *))objc_msgSend)(_self, forwardInvocationSEL, invocation);
                    }
                }));
                PhontonReplaceMethod(objectClass, @selector(forwardInvocation:), forwardInvocationSEL, forwardInvocationIMP);
            }
        }
    }
}

#pragma mark - NSObject

- (id)initWithTitle:(NSString *)title block:(void(^)(void))block {
    // Create a unique, still debuggable selector unique per PSMenuItem.
    NSString *strippedTitle = [[[title componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""] lowercaseString];
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    CFRelease(uuid);
    SEL customSelector = NSSelectorFromString([NSString stringWithFormat:@"%@_%@_%@:", kMenuItemTrailer, strippedTitle, uuidString]);
    
    if((self = [super initWithTitle:title action:customSelector])) {
        self.customSelector = customSelector;
        _enabled = YES;
        _block = [block copy];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

// Nils out action selector if we get disabled; auto-hides it from the UIMenuController.
- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.action = enabled ? self.customSelector : NULL;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

// Trampuline executor.
- (void)performBlock {
    if (_block) _block();
}
@end
#pragma clang diagnostic pop
