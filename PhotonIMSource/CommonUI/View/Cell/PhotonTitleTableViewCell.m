//
//  PhotonTitleTableViewCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/8/1.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonTitleTableViewCell.h"
#import "PhotonTitleTableItem.h"
@interface PhotonTitleTableViewCell()
@property (nonatomic, strong, nullable) UILabel  *titleLabel;
@end

@implementation PhotonTitleTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        self.lineLayer.hidden = YES;
    }
    return self;
}
- (void)setObject:(id)object{
    [super setObject:object];
    if(!self.item){
        return;
    }
    PhotonTitleTableItem *item = (PhotonTitleTableItem *)object;
    self.titleLabel.text = item.title;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).mas_equalTo(10);
        make.bottom.mas_equalTo(self.contentView).mas_equalTo(-10);
        make.left.mas_equalTo(self.contentView).mas_equalTo(14);
        make.right.mas_equalTo(self.contentView).mas_equalTo(-14);
    }];
    
}
#pragma mark ------ Getter --------
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.textColor = [UIColor colorWithHex:0x666666];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
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
