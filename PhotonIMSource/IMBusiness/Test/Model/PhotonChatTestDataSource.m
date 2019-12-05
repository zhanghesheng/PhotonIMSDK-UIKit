//
//  PhotonConversationDataSource.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/26.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonChatTestDataSource.h"
#import "PhotonChatTestItem.h"
#import "PhotonChatTestCell.h"
@implementation PhotonChatTestDataSource
- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object{
    if ([object isKindOfClass:[PhotonChatTestItem class]]) {
        return [PhotonChatTestCell class];
    }
    return [super tableView:tableView cellClassForObject:object];
}
@end
