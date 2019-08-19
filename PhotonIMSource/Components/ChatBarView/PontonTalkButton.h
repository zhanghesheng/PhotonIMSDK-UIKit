//
//  PontonTalkButton.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PontonTalkButton : UIView
@property (nonatomic, strong) NSString *normalTitle;
@property (nonatomic, strong) NSString *cancelTitle;
@property (nonatomic, strong) NSString *highlightTitle;

@property (nonatomic, strong) UIColor *highlightColor;

@property (nonatomic, strong) UILabel *titleLabel;

- (void)setTouchBeginAction:(void (^)(void))touchBegin
      willTouchCancelAction:(void (^)(BOOL cancel))willTouchCancel
             touchEndAction:(void (^)(void))touchEnd
          touchCancelAction:(void (^)(void))touchCancel;
@end

NS_ASSUME_NONNULL_END
