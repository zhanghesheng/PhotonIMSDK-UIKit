//
//  PhotonGroupContactCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/9/23.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonGroupContactCell.h"
#import "PhotonGroupContactItem.h"

@interface PhotonGroupContactCell()
@property (nonatomic,strong)UIButton   *enterGroupBtn;
@end

@implementation PhotonGroupContactCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
      
    }
    return self;
}
- (void)setObject:(id)object{
    [super setObject:object];
    if (!self.item) {
        return;
    }
    PhotonGroupContactItem *item = (PhotonGroupContactItem *)object;
    if (!item.isInGroup) {
        [self.contentView addSubview:self.enterGroupBtn];
        [self.enterGroupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView).mas_offset(-15);
            make.centerY.mas_equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(80, 33));
        }];
    }else{
        [self.enterGroupBtn removeFromSuperview];
    }
}

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    PhotonGroupContactItem *item = (PhotonGroupContactItem *)object;
    return item.itemHeight;
}


- (UIButton *)enterGroupBtn{
    if (!_enterGroupBtn) {
        _enterGroupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_enterGroupBtn addTarget:self action:@selector(enterGroup:) forControlEvents:UIControlEventTouchUpInside];
        [_enterGroupBtn setBackgroundColor:[UIColor colorWithHex:0x02A33D] forState:UIControlStateNormal];
        [_enterGroupBtn setTitle:@"加入群组" forState:UIControlStateNormal];
        [_enterGroupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _enterGroupBtn.clipsToBounds = YES;
        _enterGroupBtn.layer.cornerRadius = 5;
    }
    return _enterGroupBtn;
}

- (void)enterGroup:(UIButton *)sender{
    PhotonGroupContactItem *item = (PhotonGroupContactItem *)self.item;
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellEnterGroup:item:)]) {
        [self.delegate cellEnterGroup:self item:item];
        
    }
}
+ (NSString *)cellIdentifier{
    return @"PhotonGroupContactCell";
}
@end
