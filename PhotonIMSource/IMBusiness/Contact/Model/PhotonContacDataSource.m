//
//  PhotonContacDataSource.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/27.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonContacDataSource.h"
#import "PhotonBaseContactItem.h"
#import "PhotonBaseContactCell.h"
#import "PhotonGroupContactItem.h"
#import "PhotonGroupContactCell.h"

#import "PhotonChatTransmitCell.h"
#import "PhotonChatTransmitItem.h"

#import "PhotonTitleTableItem.h"
#import "PhotonTitleTableViewCell.h"
@implementation PhotonContacDataSource
- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object{
    if ([object isMemberOfClass:[PhotonBaseContactItem class]]) {
        return [PhotonBaseContactCell class];
    }else if ([object isMemberOfClass:[PhotonGroupContactItem class]]){
        return [PhotonGroupContactCell class];
    }else if ([object isMemberOfClass:[PhotonChatTransmitItem class]]){
        return [PhotonChatTransmitCell class];
    }else if ([object isMemberOfClass:[PhotonTitleTableItem class]]){
        return [PhotonTitleTableViewCell class];
    }
    return [super tableView:tableView cellClassForObject:object];
}
@end
