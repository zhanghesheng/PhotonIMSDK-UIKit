//
//  PhoneBadgeView.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhoneBadgeView : UIView
@property (nonatomic, strong ,nullable) NSString *badgeValue;

@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, assign) CGFloat maxHeight;

@property (nonatomic, assign) CGFloat minHeight;


+ (CGSize)badgeSizeWithValue:(NSString *)value;

+ (CGSize)badgeSizeWithValue:(NSString *)value font:(UIFont *)font;

+ (CGSize)badgeSizeWithValue:(NSString *)value font:(UIFont *)font maxHeight:(CGFloat)maxHeight minHeight:(CGFloat)minHeight;
@end

NS_ASSUME_NONNULL_END
