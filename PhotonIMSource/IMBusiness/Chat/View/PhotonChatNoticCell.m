//
//  PhotonChatWithDrawViewCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/23.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonChatNoticCell.h"
#import "PhotonChatNoticItem.h"
@interface PhotonChatNoticCell()
/**
 系统提示
 */
@property (nonatomic, strong, nullable)UILabel  *noticLable;


@end

@implementation PhotonChatNoticCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithHex:0XF3F3F3];
        [self.contentView addSubview:self.noticLable];
        self.lineLayer.hidden = YES;
  
    }
    return self;
}
- (void)setObject:(id)object{
    [super setObject:object];
    if (!self.item) {
        return;
    }
    PhotonChatNoticItem *item = (PhotonChatNoticItem *)object;
    self.noticLable.text = item.notic;
    
    [self.noticLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
    }];
    
    // 已发送显示已发送文案
    if ([item.notic isNotEmpty]) {
        // 背景
        self.noticLable.text = item.notic;
        CGSize size = [self.noticLable sizeThatFits:CGSizeMake(40, 20)];
        [self.noticLable mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(29);
            make.width.mas_equalTo(size.width + 22);
        }];
    }else{
        self.noticLable.text = nil;
        [self.noticLable mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeZero);
        }];
    }
    
}
- (UILabel *)noticLable{
    if (!_noticLable) {
        _noticLable = [[UILabel alloc] init];
        [_noticLable setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:12.0]];
        [_noticLable setTextColor:[UIColor colorWithHex:0xFFFFFF]];
        [_noticLable setBackgroundColor:[UIColor colorWithHex:0x000000 alpha:0.2]];
        [_noticLable setTextAlignment:NSTextAlignmentCenter];
        [_noticLable.layer setMasksToBounds:YES];
        [_noticLable.layer setCornerRadius:5.0f];
    }
    return _noticLable;
}

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
     PhotonChatNoticItem *item = (PhotonChatNoticItem *)object;
    return item.itemHeight;
}

+ (NSString *)cellIdentifier{
    return @"PhotonChatNoticCell";
}
@end
