//
//  PhotonContactCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/27.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonContactCell.h"
#import "PhotonContactItem.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface PhotonContactCell()
@property(nonatomic, copy, nullable)UIImageView *avatarView;
@property(nonatomic, copy, nullable)UILabel *nickLabel;
@end
@implementation PhotonContactCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.nickLabel];
    }
    return self;
}
- (void)setObject:(id)object{
    [super setObject:object];
    if (!self.item) {
        return;
    }
    PhotonContactItem *item = (PhotonContactItem *)object;
    NSURL *avatarURL = nil;
    if ([item.fIcon isNotEmpty]) {
        avatarURL = [NSURL URLWithString:item.fIcon];
    }
    [self.avatarView sd_setImageWithURL:avatarURL];
    self.nickLabel.text = item.fNickName;
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


+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    PhotonContactItem *item = (PhotonContactItem *)object;
    return item.itemHeight;
}

+ (NSString *)cellIdentifier{
    return @"PhotonContactCell";
}
@end
