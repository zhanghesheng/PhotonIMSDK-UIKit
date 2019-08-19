//
//  PotonBaseTableViewCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PotonBaseTableViewCell.h"

@implementation PotonBaseTableViewCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    return DEFAULT_TABLE_CELL_HRIGHT;
}

+ (NSString *) nibName {
    return nil;
}

+ (NSString *) cellIdentifier {
    return nil;
}

#pragma mark UITableViewCell

- (void)prepareForReuse {
    self.object = nil;
    [super prepareForReuse];
}

- (id)object {
    return nil;
}

- (void)setObject:(id)object {
}
@end
