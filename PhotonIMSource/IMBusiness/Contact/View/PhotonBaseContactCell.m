//
//  PhotonContactCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/27.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseContactCell.h"
#import "PhotonBaseContactItem.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface PhotonBaseContactCell()
@property(nonatomic, copy, nullable)UIImageView *avatarView;
@property(nonatomic, copy, nullable)UILabel *nickLabel;
@property(nonatomic, copy, nullable)UIImageView *icon;
@end
@implementation PhotonBaseContactCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.nickLabel];
        [self.contentView addSubview:self.icon];
    }
    return self;
}
- (void)setObject:(id)object{
    [super setObject:object];
    if (!self.item) {
        return;
    }
    PhotonBaseContactItem *item = (PhotonBaseContactItem *)object;
    NSURL *avatarURL = nil;
    if ([item.contactAvatar isNotEmpty]) {
        avatarURL = [NSURL URLWithString:item.contactAvatar];
    }
    [self.avatarView sd_setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:item.contactAvatar]];
    self.nickLabel.text = item.contactName;
    if ([item.contactIcon isNotEmpty]) {
        [self.contentView addSubview:self.icon];
        [self.icon setImage:[UIImage imageNamed:item.contactIcon]];
        [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView).mas_offset(-18);
            make.centerY.mas_equalTo(self.contentView);
            make.width.mas_equalTo(22);
        }];
    }
    [self p_layoutViews];
}

- (void)p_layoutViews{
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(20);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    [self.nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatarView.mas_right).mas_offset(11);
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView.mas_right).mas_offset(-5);
    }];
}

#pragma mark --------- Getter -------
- (UIImageView *)avatarView{
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.backgroundColor = [UIColor clearColor];
        _avatarView.clipsToBounds = YES;
        _avatarView.layer.cornerRadius = 5.0;
    }
    return _avatarView;
}

- (UILabel *)nickLabel{
    if (!_nickLabel) {
        _nickLabel = [[UILabel alloc] init];
        _nickLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0];
        _nickLabel.numberOfLines = 0;
    }
    return _nickLabel;
}

- (UIImageView *)icon{
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
        _icon.backgroundColor = [UIColor clearColor];
        _icon.userInteractionEnabled = NO;
    }
    return _icon;
}


+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    PhotonBaseContactItem *item = (PhotonBaseContactItem *)object;
    return item.itemHeight;
}

+ (NSString *)cellIdentifier{
    return @"PhotonContactCell";
}
@end
