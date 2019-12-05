//
//  PhotonGroupTitleTableViewCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/9/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonGroupTitleTableViewCell.h"
#import "PhotonGroupTitleTableItem.h"
@interface PhotonGroupTitleTableViewCell()
@property (nonatomic, strong, nullable) UILabel  *titleLabel;
@property (nonatomic, strong, nullable) UILabel  *subTitleLabel;
@property(nonatomic, copy, nullable)UIImageView *icon;
@end
@implementation PhotonGroupTitleTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.icon];
        [self.contentView addSubview:self.subTitleLabel];
        self.lineLayer.hidden = YES;
    }
    return self;
}
- (void)setObject:(id)object{
    [super setObject:object];
    if(!self.item){
        return;
    }
    PhotonGroupTitleTableItem *item = (PhotonGroupTitleTableItem *)object;
    self.titleLabel.text = item.title;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).mas_equalTo(10);
        make.bottom.mas_equalTo(self.contentView).mas_equalTo(-10);
        make.left.mas_equalTo(self.contentView).mas_equalTo(14);
        make.right.mas_equalTo(self.contentView).mas_equalTo(-200);
    }];
    
    
    [self.icon setImage:[UIImage imageNamed:item.icon]];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).mas_offset(-10);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(22);
    }];
    
    self.subTitleLabel.text = item.detail;
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).mas_equalTo(10);
        make.bottom.mas_equalTo(self.contentView).mas_equalTo(-10);
        make.left.mas_equalTo(self.titleLabel.mas_right).mas_equalTo(10);
        make.right.mas_equalTo(self.icon.mas_left).mas_equalTo(-10);
    }];
    
}
#pragma mark ------ Getter --------
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16.0];
        _titleLabel.textColor = [UIColor colorWithHex:0x666666];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}
- (UILabel *)subTitleLabel{
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.font = [UIFont systemFontOfSize:16.0];
        _subTitleLabel.textColor = [UIColor colorWithHex:0x666666];
        _subTitleLabel.backgroundColor = [UIColor clearColor];
        _subTitleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _subTitleLabel;
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


+ (NSString *)cellIdentifier{
    return @"PhotonTitleTableViewCell";
}
+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    PhotonTitleTableItem *item = (PhotonTitleTableItem *)object;
    return item.itemHeight;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


@end
