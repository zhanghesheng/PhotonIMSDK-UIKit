//
//  PhoneBadgeView.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhoneBadgeView.h"

@interface PhoneBadgeView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end
@implementation PhoneBadgeView
+ (CGSize)badgeSizeWithValue:(NSString *)value
{
    return [self badgeSizeWithValue:value font:[UIFont systemFontOfSize:12]];
}

+ (CGSize)badgeSizeWithValue:(NSString *)value font:(UIFont *)font
{
    return [self badgeSizeWithValue:value font:font maxHeight:18 minHeight:10];
}

+ (CGSize)badgeSizeWithValue:(NSString *)value font:(UIFont *)font maxHeight:(CGFloat)maxHeight minHeight:(CGFloat)minHeight
{
    if (!value) {
        return CGSizeZero;
    }
    if ([value isEqualToString:@""]) {
        return CGSizeMake(minHeight, minHeight);
    }
    
    CGSize size = [value sizeWithAttributes:@{NSFontAttributeName : font}];
    CGFloat width = size.width > maxHeight ?  size.width + maxHeight * 0.8 : maxHeight;
    if (value.length >= 2) {
        width += 9;
    }
    return CGSizeMake(width, maxHeight);
}

#pragma mark - # Init
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.layer setMasksToBounds:YES];
        [self addSubview:self.titleLabel];
        
        // 默认属性设置
        [self setBackgroundColor:[UIColor redColor]];
        [self setTitleColor:[UIColor whiteColor]];
        [self setTitleFont:[UIFont systemFontOfSize:12]];
        [self setMaxHeight:18.0];
        [self setMinHeight:10.0];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 更新圆角大小
    [self.layer setCornerRadius:self.frame.size.height / 2.0];
    // 更新titleLabel坐标和大小
    if (self.badgeValue == nil) {
        [self.titleLabel setFrame:CGRectZero];
        return;
    }
    else if ([self.badgeValue isEqualToString:@""]) {
        [self.titleLabel setFrame:CGRectMake(0, 0, self.minHeight, self.minHeight)];
    }
    else {
        CGFloat height = [self.titleLabel sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)].height;
        [self.titleLabel setFrame:CGRectMake(0, 0, self.frame.size.width - (self.frame.size.height * 0.3) * 2, height)];
    }
    
    [self.titleLabel setCenter:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)];
}

#pragma mark - # Public Methods
- (void)setBadgeValue:(id)badgeValue
{
    _badgeValue = badgeValue;
    [self.titleLabel setText:badgeValue];
    [self.titleLabel sizeToFit];
    
    [self p_resetFrame];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    [self.titleLabel setFont:titleFont];
    
    [self p_resetFrame];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    [self.titleLabel setTextColor:titleColor];
}

- (void)setMaxHeight:(CGFloat)maxHeight
{
    _maxHeight = maxHeight;
    
    [self p_resetFrame];
}

- (void)setMinHeight:(CGFloat)minHeight
{
    _minHeight = minHeight;
    
    [self p_resetFrame];
}

#pragma mark - # Private Methods
- (void)p_resetFrame
{
    CGSize size = [PhoneBadgeView badgeSizeWithValue:self.badgeValue font:self.titleFont maxHeight:self.maxHeight minHeight:self.minHeight];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height)];
    [self setNeedsDisplay];
}

#pragma mark - # Getters
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
    }
    return _titleLabel;
}
@end
