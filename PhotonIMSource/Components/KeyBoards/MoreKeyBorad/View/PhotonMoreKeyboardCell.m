//
//  PhotonMoreKeyboardCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonMoreKeyboardCell.h"
#import "PhotonMacros.h"

@interface PhotonMoreKeyboardCell()
@property (nonatomic, strong) UIButton *iconButton;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation PhotonMoreKeyboardCell
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.iconButton];
        [self.contentView addSubview:self.titleLabel];
        [self p_addMasonry];
    }
    return self;
}

- (void)setItem:(PhotonMoreKeyboardItem *)item
{
    _item = item;
    if (item == nil) {
        [self.titleLabel setHidden:YES];
        [self.iconButton setHidden:YES];
        [self setUserInteractionEnabled:NO];
        return;
    }
    [self setUserInteractionEnabled:YES];
    [self.titleLabel setHidden:NO];
    [self.iconButton setHidden:NO];
    [self.titleLabel setText:item.title];
    [self.iconButton setImage:[UIImage imageNamed:item.imagePath] forState:UIControlStateNormal];
}

#pragma mark - Event Response -
- (void)iconButtonDown:(UIButton *)sender
{
    self.clickBlock(self.item);
}

#pragma mark - Private Methods -
- (void)p_addMasonry
{
    [self.iconButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.centerX.mas_equalTo(self.contentView);
        make.width.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.iconButton.mas_width);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView);
    }];
}

#pragma mark - Getter -
- (UIButton *)iconButton
{
    if (_iconButton == nil) {
        _iconButton = [[UIButton alloc] init];
        [_iconButton.layer setMasksToBounds:YES];
        [_iconButton.layer setCornerRadius:5.0f];
        [_iconButton.layer setBorderWidth:0];
        [_iconButton.layer setBorderColor:[UIColor colorWithHex:0XFFFFFF].CGColor];
        [_iconButton setBackgroundColor:[UIColor colorWithHex:0XFFFFFF] forState:UIControlStateNormal];
        [_iconButton addTarget:self action:@selector(iconButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _iconButton;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:10.0f]];
        [_titleLabel setTextColor:[UIColor grayColor]];
    }
    return _titleLabel;
}
@end
