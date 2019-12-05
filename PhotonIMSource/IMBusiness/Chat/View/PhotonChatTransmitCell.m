//
//  PhotonChatTransmitCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/31.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonChatTransmitCell.h"
#import "PhotonChatTransmitItem.h"
@interface PhotonChatTransmitCell()
@property (nonatomic, strong, nullable) UIButton *selectBtn;

@property (nonatomic, strong, nullable) UIImage *selectedImage;

@property (nonatomic, strong, nullable) UIImage *unSelectedImage;
@end
@implementation PhotonChatTransmitCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _selectedImage = [UIImage imageNamed:@"radiobutton_on"];
        _unSelectedImage = [UIImage imageNamed:@"radiobutton"];
    }
    return self;
}
- (void)setObject:(id)object{
    [super setObject:object];
    if (!self.item) {
        return;
    }
    PhotonChatTransmitItem *item = (PhotonChatTransmitItem *)object;
    if (!item.showSelectBtn) {
        [self.selectBtn removeFromSuperview];
    }else{
        [self.contentView addSubview:self.selectBtn];
        if (item.selected) {
            [self.selectBtn setImage:_selectedImage forState:UIControlStateNormal];
        }else{
            [self.selectBtn setImage:_unSelectedImage forState:UIControlStateNormal];
        }
        [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.right.mas_equalTo(self.contentView).mas_offset(-15.0);
            make.size.mas_equalTo(CGSizeMake(item.itemHeight, item.itemHeight));
        }];
    }

}

#pragma mark --------- Getter -------
- (UIButton *)selectBtn{
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_selectBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
        _selectBtn.backgroundColor = [UIColor clearColor];
    }
    return _selectBtn;
}
- (void)selectAction:(UIButton *)sender{
    PhotonChatTransmitItem *item = (PhotonChatTransmitItem *)self.item;
    item.selected = !item.selected;
    if ( item.selected) {
        [self.selectBtn setImage:_selectedImage forState:UIControlStateNormal];
    }else{
        [self.selectBtn setImage:_unSelectedImage forState:UIControlStateNormal];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:selectedItem:)]) {
        [self.delegate cell:self selectedItem:item];
    }
}


+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    PhotonBaseContactItem *item = (PhotonBaseContactItem *)object;
    return item.itemHeight;
}

+ (NSString *)cellIdentifier{
    return @"PhotonContactCell";
}

@end
