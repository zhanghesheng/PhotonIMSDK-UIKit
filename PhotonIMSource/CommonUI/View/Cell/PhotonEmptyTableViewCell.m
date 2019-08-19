//
//  PhotonEmptyTableViewCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/8.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonEmptyTableViewCell.h"
#import "PhotonEmptyTableItem.h"
@implementation PhotonEmptyTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.lineLayer.hidden = YES;
    }
    return self;
}
- (void)setObject:(id)object{
    [super setObject:object];
    PhotonEmptyTableItem *item = (PhotonEmptyTableItem *)object;
    self.contentView.backgroundColor = item.backgroudColor;
    self.backgroundColor = item.backgroudColor;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    PhotonEmptyTableItem *item = (PhotonEmptyTableItem *)object;
    return item.itemHeight;
}
+ (NSString *)cellIdentifier{
    return @"PhotonEmptyTableViewCell";
}
@end
