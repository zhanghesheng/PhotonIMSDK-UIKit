//
//  PhotonMenuView.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/24.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonMenuView.h"
#import "PhotonMessageCenter.h"
#import <objc/runtime.h>
#import "PhotonBaseChatItem.h"
@interface PhotonMenuView()
@property(nonatomic, strong, nullable) UIMenuController *menuController;
@end
@implementation PhotonMenuView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.menuController = [UIMenuController sharedMenuController];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHideMenuNotification:) name:UIMenuControllerDidHideMenuNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didHideMenuNotification:(id)noti{
    [self dismiss];
}

- (void)showMenuInSuperView:(UIView *)view rect:(CGRect)rect animation:(BOOL)animation{
    if (_isShow) {
        return;
    }
    _isShow = YES;
    [self setFrame:view.bounds];
    [view addSubview:self];
    
    [self setMenuItems];
    [self.menuController setTargetRect:rect inView:self];
    [self becomeFirstResponder];
    [self.menuController setMenuVisible:YES animated:animation];
}

- (void)setMenuItems{
    PhontonMenuItem *copyItem = [[PhontonMenuItem alloc] initWithTitle:@"复制" action:@selector(menuCopy:)];
    PhontonMenuItem *reDrawItem = [[PhontonMenuItem alloc] initWithTitle:@"撤回" action:@selector(menuReDraw:)];
    PhontonMenuItem *deleteItem = [[PhontonMenuItem alloc] initWithTitle:@"删除" action:@selector(menuDelete:)];
    PhontonMenuItem *transpondItem = [[PhontonMenuItem alloc] initWithTitle:@"转发" action:@selector(menuTranspond:)];
    if([self.obj isKindOfClass:[PhotonBaseChatItem class]]){
        PhotonBaseChatItem *item = (PhotonBaseChatItem *)self.obj;
        if (item.fromType == PhotonChatMessageFromSelf) {
            if ([[item userInfo] messageType] == PhotonIMMessageTypeText) {
                if ([item canWithDrawMsg] && [[item userInfo] messageStatus] != PhotonIMMessageStatusFailed) {
                     [self.menuController setMenuItems:@[copyItem,transpondItem,reDrawItem,deleteItem]];
                }else{
                     [self.menuController setMenuItems:@[copyItem,transpondItem,deleteItem]];
                }
            }else{
                if ([item canWithDrawMsg] && [[item userInfo] messageStatus] != PhotonIMMessageStatusFailed) {
                     [self.menuController setMenuItems:@[transpondItem,reDrawItem,deleteItem]];
                }else{
                     [self.menuController setMenuItems:@[transpondItem,deleteItem]];
                }
               
            }
        }else{
            if ([[item userInfo] messageType] == PhotonIMMessageTypeText){
                [self.menuController setMenuItems:@[copyItem,transpondItem,deleteItem]];
            }else{
                [self.menuController setMenuItems:@[transpondItem,deleteItem]];
            }
            
        }
        
    }
}
// 复制
- (void)menuCopy:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedItemWithType:obj:)]) {
        [self.delegate didSelectedItemWithType:PhotonMenuTypeCopy obj:self.obj];
    }
}
// 撤回
- (void)menuReDraw:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedItemWithType:obj:)]) {
        [self.delegate didSelectedItemWithType:PhotonMenuTypeWithdraw obj:self.obj];
    }
}
// 删除
- (void)menuDelete:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedItemWithType:obj:)]) {
        [self.delegate didSelectedItemWithType:PhotonMenuTypeDelete obj:self.obj];
    }
}

// 转发
- (void)menuTranspond:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedItemWithType:obj:)]) {
        [self.delegate didSelectedItemWithType:PhotonMenuTypeTransmit obj:self.obj];
    }
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(menuCopy:) || action == @selector(menuReDraw:) || action == @selector(menuDelete:)|| action == @selector(menuTranspond:)) {
        return YES;
    }
    return NO;
}
- (void)dismiss
{
    if (!_isShow) {
        return;
    }
    self.obj = nil;
    _isShow = NO;
    [self.menuController setMenuVisible:NO animated:YES];
    [self removeFromSuperview];
}
@end
