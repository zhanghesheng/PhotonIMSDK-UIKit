//
//  PhotonGroupMemberCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/9/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonGroupMemberCell.h"
#import "PhotonGroupMemberTableItem.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface PhotonGroupMemberCell()
@property (nonatomic, strong, nullable)UIView  *memberView;
@property(nonatomic, copy, nullable)UIImageView *avatar;
@property(nonatomic, copy, nullable)UILabel *nameLable;
@end
@implementation PhotonGroupMemberCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    if (self) {
        [self.contentView addSubview:self.memberView];
        [self.memberView addSubview:self.avatar];
        [self.memberView addSubview:self.nameLable];
        self.lineLayer.hidden = YES;
    
    }
    return self;
}
- (void)setObject:(id)object{
    [super setObject:object];
    if(!self.item){
        return;
    }
    
    PhotonGroupMemberTableItem *item = (PhotonGroupMemberTableItem *)object;
    int index = 0;
    CGFloat offset = 10;
    CGFloat padding = 10;
    for (PhotonUser *member in item.memebers) {
        if(index > 0){
            padding = 5;
        }
        if (index > 0) {
            offset = padding + 50 + offset;
        }
        if (offset >= self.contentView.width) {
            break;
        }
       UIView *memberView = [[UIView alloc] init];
       memberView.backgroundColor = self.contentView.backgroundColor;
       [self.contentView addSubview:memberView];
        
        [memberView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50, item.itemHeight - 5));
            make.centerY.mas_equalTo(self.contentView);
            make.left.mas_equalTo(offset);
        }];
        
        UIImageView *avatar = [[UIImageView alloc] init];
        avatar.backgroundColor = [UIColor clearColor];
        avatar.clipsToBounds = YES;
        avatar.layer.cornerRadius = 2;
        [avatar sd_setImageWithURL:[NSURL URLWithString:member.avatarURL]];
        [memberView addSubview:avatar];
    
        UILabel *nameLable = [[UILabel alloc] init];
        nameLable.backgroundColor = [UIColor clearColor];
        nameLable.textAlignment = NSTextAlignmentCenter;
        nameLable.text = member.nickName;
        nameLable.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0f];
        nameLable.textColor = [UIColor colorWithHex:0x6F6C70];
        [memberView addSubview:nameLable];
        
        [avatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50, 50));
            make.centerX.mas_equalTo(memberView);
            make.top.mas_equalTo(memberView).offset(0);
        }];
        
        [nameLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50, 20));
            make.centerX.mas_equalTo(memberView);
            make.top.mas_equalTo(avatar.mas_bottom).offset(0);
        }];
        
    
        
        index++;
    }
    
}
#pragma mark ------ Getter --------
- (UIView *)memberView{
    if (_memberView) {
        _memberView = [[UIView alloc] init];
        _memberView.backgroundColor = [UIColor clearColor];
    }
    return _memberView;
}

- (UIImageView *)avatar{
    if (_avatar) {
        _avatar = [[UIImageView alloc] init];
        _avatar.backgroundColor = [UIColor clearColor];
        _avatar.clipsToBounds = YES;
        _avatar.layer.cornerRadius = 2;
    }
    return _avatar;
}
- (UILabel *)nameLable{
    if (_nameLable) {
        _nameLable = [[UILabel alloc] init];
        _nameLable.backgroundColor = [UIColor clearColor];
        _nameLable.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLable;
}

+ (NSString *)cellIdentifier{
    return @"PhotonGroupMemberCell";
}
+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    PhotonGroupMemberTableItem *item = (PhotonGroupMemberTableItem *)object;
    return item.itemHeight;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


@end
