//
//  PhotonConversationDataSource.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/26.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonConversationDataSource.h"
#import "PhotonConversationItem.h"
#import "PhotonConversationCell.h"
@implementation PhotonConversationDataSource
- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object{
    if ([object isKindOfClass:[PhotonConversationItem class]]) {
        return [PhotonConversationCell class];
    }
    return [super tableView:tableView cellClassForObject:object];
}
@end
