//
//  PhotonPersonCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/2.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonPersonCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
@implementation PhotonPersonItem
- (CGFloat)itemHeight{
    return 52.0;
}
- (UIColor *)valueColor{
    return [UIColor blackColor];
}
@end

@interface PhotonPersonCell()
@property (nonatomic,strong,nullable)UILabel *titleLabel;
@property (nonatomic,strong,nullable)UILabel *contentLabel;
@property (nonatomic,strong,nullable)UIImageView *iconView;
@property (nonatomic,strong,nullable)UIImageView *avatarView;

@property (nonatomic,strong,nullable)UIButton *btn;
@end

@implementation PhotonPersonCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.iconView];
        
    }
    return self;
}

- (void)setObject:(id)object{
    [super setObject:object];
    PhotonPersonItem *item = (PhotonPersonItem *)object;
    self.titleLabel.text = item.key;
    if (item.type == PhotonPersonItemTypeBTN) {
        [self.contentView addSubview:self.btn];
        [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(self.contentView);
        }];
        return;
    }
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
    
    if (item.shorArrow) {
        [self.iconView setImage:[UIImage imageNamed:@"right_arrow"]];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(7, 14.5));
            make.centerY.mas_equalTo(self.contentView);
            make.right.mas_equalTo(self.contentView).offset(-17);
        }];
    }else{
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(0, 0));
            make.right.mas_equalTo(self.contentView).offset(0);
        }];
    }
    
    if (item.type == PhotonPersonItemTypeAvatar) {
        if ([item.value isNotEmpty]) {
            [self.avatarView sd_setImageWithURL:[NSURL URLWithString:item.value]];
            [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.iconView.mas_left).offset(-11);
                make.centerY.mas_equalTo(self.contentView);
                make.width.mas_equalTo(45);
                make.height.mas_equalTo(45);
            }];
        }
    }else{
        self.contentLabel.text = item.value;
        self.contentLabel.textColor = item.valueColor;
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.iconView.mas_left).offset(-11);
            make.centerY.mas_equalTo(self.contentView);
            make.left.mas_equalTo(self.titleLabel.mas_right);
            make.height.mas_equalTo(40);
        }];
    }
    
    
}

#pragma mark ----- Getter ---------
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = self.contentView.backgroundColor;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0];
        _titleLabel.textColor = [UIColor colorWithHex:0x000000];
    }
    return _titleLabel;
}

- (UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = self.contentView.backgroundColor;
        _contentLabel.textAlignment = NSTextAlignmentRight;
        _contentLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0];
        _contentLabel.textColor = [UIColor colorWithHex:0x000000];
    }
    return _contentLabel;
}

- (UIImageView *)avatarView{
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.backgroundColor = [UIColor clearColor];
    }
    return _avatarView;
}

- (UIImageView *)iconView{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.backgroundColor = [UIColor clearColor];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _iconView;
}
- (UIButton *)btn{
    if (!_btn) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn setTitle:@"退出登录" forState:UIControlStateNormal];
        _btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0];
        [_btn setTitleColor:[UIColor colorWithHex:0xFF0000] forState:UIControlStateNormal];
        [_btn setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btn addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn;
}

- (void)logout:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(logout:)]) {
        [self.delegate logout:self];
    }
}
+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    PhotonPersonItem *item = (PhotonPersonItem *)object;
    return item.itemHeight;
}
+ (NSString *)cellIdentifier{
    return @"PhotonPersonCell";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
