//
//  PotonTableViewDataSource.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PotonTableViewDataSource.h"
#import <objc/runtime.h>
#import "PhotonTableViewCell.h"
#import "PhotonNetTableViewCell.h"
#import "PhotonNetTableItem.h"
#import "PhotonEmptyTableItem.h"
#import "PhotonEmptyTableViewCell.h"
#import "PhotonTitleTableItem.h"
#import "PhotonTitleTableViewCell.h"
@implementation PotonTableViewDataSource
- (id)tableView:(UITableView *)tableView objectForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _items.count) {
        return [_items objectAtIndex:indexPath.row];
        
    } else {
        return nil;
    }
}

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object {
    if ([object isKindOfClass:[PhotonNetTableItem class]]) {
        return [PhotonNetTableViewCell class];
    }else if ([object isKindOfClass:[PhotonEmptyTableItem class]]){
        return [PhotonEmptyTableViewCell class];
    }else if ([object isKindOfClass:[PhotonTitleTableItem class]]){
        return [PhotonTitleTableViewCell class];
    }
    return [PhotonTableViewCell class];
}

- (NSIndexPath *)tableView:(UITableView *)tableView indexPathForObject:(id)object {
    return nil;
}

- (void)tableView:(UITableView *)tableView cell:(UITableViewCell *)cell
willAppearAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
    
    Class cellClass = [self tableView:tableView cellClassForObject:object];
    NSString *identifier = [cellClass cellIdentifier];
    if (!identifier) {
        const char *className = class_getName(cellClass);
        identifier = [[NSString alloc] initWithBytesNoCopy:(char *) className
                                                    length:strlen(className)
                                                  encoding:NSASCIIStringEncoding freeWhenDone:NO];
    }
    
    UITableViewCell *cell =
    (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        NSString *nibName = nil;
        if ([cellClass isSubclassOfClass:[PhotonTableViewCell class]]) {
            nibName = [cellClass nibName];
        }
        
        if (!nibName && self.loadNibWithClassName) {
            nibName = identifier;
        }
        
        if (nibName) {
            if ([[NSBundle mainBundle] pathForResource:nibName ofType:@"nib"] != nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
                if (nib && nib.count > 0) {
                    cell = (UITableViewCell *) [nib objectAtIndex:0];
                }
            }
            else {
                cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:identifier];
            }
        } else {
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:identifier];
        }
    }
    
    if ([cell isKindOfClass:[PhotonTableViewCell class]]) {
        [(PhotonTableViewCell *) cell setObject:object];
    }
    
    [self tableView:tableView cell:cell willAppearAtIndexPath:indexPath];
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)sectionIndex {
    if (tableView.tableHeaderView) {
        if (sectionIndex == 0) {
            [tableView scrollRectToVisible:tableView.tableHeaderView.bounds animated:NO];
            return -1;
        }
    }
    
    NSString *letter = [title substringToIndex:1];
    NSInteger sectionCount = [tableView numberOfSections];
    for (NSInteger i = 0; i < sectionCount; ++i) {
        NSString *section = [tableView.dataSource tableView:tableView titleForHeaderInSection:i];
        if ([section hasPrefix:letter]) {
            return i;
        }
    }
    if (sectionIndex >= sectionCount) {
        return sectionCount - 1;
        
    } else {
        return sectionIndex;
    }
}

- (id)initWithItems:(NSArray *)items {
    self = [self init];
    if (self) {
        _items = [items mutableCopy];
    }
    
    return self;
}

- (void)dealloc {
}
@end
