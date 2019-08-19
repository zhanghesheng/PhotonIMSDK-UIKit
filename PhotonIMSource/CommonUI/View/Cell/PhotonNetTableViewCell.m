//
//  PhotonNetTableViewCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/5.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonNetTableViewCell.h"
#import "PhotonNetTableItem.h"
@interface PhotonNetTableViewCell()
@property (nonatomic, strong, nullable) UIImageView *iconView;
@property (nonatomic, strong, nullable) UILabel  *messageLabel;
@end
@implementation PhotonNetTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.messageLabel];
    }
    return self;
}
- (void)setObject:(id)object{
    [super setObject:object];
    if(!self.item){
        return;
    }
    PhotonNetTableItem *item = (PhotonNetTableItem *)object;
    [self.iconView setImage:[UIImage imageNamed:@"conv_exclamation_mark"]];
    self.messageLabel.text = item.message;
    
    CGSize size = [self.messageLabel sizeThatFits:CGSizeMake(self.contentView.y, 20)];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_equalTo(self.contentView.mas_left).mas_offset(-5);
    }];
}
#pragma mark ------ Getter --------
- (UIImageView *)iconView{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
    }
    return _iconView;
}

- (UILabel *)messageLabel{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:16.0];
        _messageLabel.textColor = [UIColor redColor];
    }
    return _messageLabel;
}


+ (NSString *)cellIdentifier{
    return @"PhotonNetTableViewCell";
}
+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    return 50;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
