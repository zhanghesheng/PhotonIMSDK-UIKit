//
//  UINavigation+FixSpace.m
//  UINavigation-FixSpace
//
//  Created by Bruce on 2019/7/5.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "UINavigation+FixSpace.h"
#import "PhotonMacros.h"
#import <UIKit/UIKit.h>

#ifndef deviceVersion
#define deviceVersion [[[UIDevice currentDevice] systemVersion] floatValue]
#endif

static BOOL photon_disableFixSpace = NO;

@implementation UIImagePickerController (FixSpace)
+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self photon_swizzleInstanceMethodWithOriginSel:@selector(viewWillAppear:)
                                     swizzledSel:@selector(photon_viewWillAppear:)];
        
        [self photon_swizzleInstanceMethodWithOriginSel:@selector(viewWillDisappear:)
                                     swizzledSel:@selector(photon_viewWillDisappear:)];
    });
}


-(void)photon_viewWillAppear:(BOOL)animated {
    photon_disableFixSpace = YES;
    [self photon_viewWillAppear:animated];
}

-(void)photon_viewWillDisappear:(BOOL)animated{
    photon_disableFixSpace = NO;
    [self photon_viewWillDisappear:animated];
}

@end

@implementation UINavigationBar (FixSpace)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self photon_swizzleInstanceMethodWithOriginSel:@selector(layoutSubviews)
                                     swizzledSel:@selector(photon_layoutSubviews)];
    });
}

-(void)photon_layoutSubviews{
    [self photon_layoutSubviews];
    
    if (deviceVersion >= 11 && !photon_disableFixSpace) {//需要调节
        self.layoutMargins = UIEdgeInsetsZero;
        CGFloat space = photon_defaultFixSpace;
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass(subview.class) containsString:@"ContentView"]) {
                subview.layoutMargins = UIEdgeInsetsMake(0, space, 0, space);//可修正iOS11之后的偏移
                break;
            }
        }
    }
}

@end

@implementation UINavigationItem (FixSpace)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self photon_swizzleInstanceMethodWithOriginSel:@selector(setLeftBarButtonItem:)
                                     swizzledSel:@selector(photon_setLeftBarButtonItem:)];
        
        [self photon_swizzleInstanceMethodWithOriginSel:@selector(setLeftBarButtonItems:)
                                     swizzledSel:@selector(photon_setLeftBarButtonItems:)];
        
        [self photon_swizzleInstanceMethodWithOriginSel:@selector(setRightBarButtonItem:)
                                     swizzledSel:@selector(photon_setRightBarButtonItem:)];
        
        [self photon_swizzleInstanceMethodWithOriginSel:@selector(setRightBarButtonItems:)
                                     swizzledSel:@selector(photon_setRightBarButtonItems:)];
    });
    
}

-(void)photon_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    if (deviceVersion >= 11) {
        [self photon_setLeftBarButtonItem:leftBarButtonItem];
    } else {
        if (!photon_disableFixSpace && leftBarButtonItem) {//存在按钮且需要调节
            [self setLeftBarButtonItems:@[leftBarButtonItem]];
        } else {//不存在按钮,或者不需要调节
            [self photon_setLeftBarButtonItem:leftBarButtonItem];
        }
    }
}

-(void)photon_setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems {
    if (leftBarButtonItems.count) {
        NSMutableArray *items = [NSMutableArray arrayWithObject:[self fixedSpaceWithWidth:photon_defaultFixSpace-20]];//可修正iOS11之前的偏移
        [items addObjectsFromArray:leftBarButtonItems];
        [self photon_setLeftBarButtonItems:items];
    } else {
        [self photon_setLeftBarButtonItems:leftBarButtonItems];
    }
}

-(void)photon_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem{
    if (deviceVersion >= 11) {
        [self photon_setRightBarButtonItem:rightBarButtonItem];
    } else {
        if (!photon_disableFixSpace && rightBarButtonItem) {//存在按钮且需要调节
            [self setRightBarButtonItems:@[rightBarButtonItem]];
        } else {//不存在按钮,或者不需要调节
            [self photon_setRightBarButtonItem:rightBarButtonItem];
        }
    }
}

-(void)photon_setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems{
    if (rightBarButtonItems.count) {
        NSMutableArray *items = [NSMutableArray arrayWithObject:[self fixedSpaceWithWidth:photon_defaultFixSpace-20]];//可修正iOS11之前的偏移
        [items addObjectsFromArray:rightBarButtonItems];
        [self photon_setRightBarButtonItems:items];
    } else {
        [self photon_setRightBarButtonItems:rightBarButtonItems];
    }
}

-(UIBarButtonItem *)fixedSpaceWithWidth:(CGFloat)width {
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                               target:nil
                                                                               action:nil];
    fixedSpace.width = width;
    return fixedSpace;
}

@end
