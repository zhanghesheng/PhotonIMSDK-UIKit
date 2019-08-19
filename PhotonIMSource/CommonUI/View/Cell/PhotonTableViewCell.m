//
//  PhotonTableViewCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonTableViewCell.h"
#import "PhotonMacros.h"
@implementation PhotonTableViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (void)initView {
    CALayer *layer1 = [CALayer layer];
    [self.contentView.layer addSublayer:layer1];
    layer1.backgroundColor = [UIColor colorWithHex:0xCECECE].CGColor;
    self.lineLayer = layer1;
}
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    return DEFAULT_TABLE_CELL_HRIGHT;
}

- (void)dealloc {
}


#pragma mark TBTableViewCell


- (id)object {
    return _item;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initView];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initView];
        
    }
    return self;
}

- (void)setObject:(id)object {
    if (_item != object) {
        _item = object;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [CATransaction begin];
    [CATransaction setValue:(id) kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    CGFloat h = BORDER_WIDTH_1PX;
    
    self.lineLayer.frame = CGRectMake(0,
                                      self.frame.size.height - h,
                                      self.frame.size.width, h);
    [CATransaction commit];
}
+ (NSString *)cellIdentifier{
    return @"PhotonTableViewCell";
}
@end
