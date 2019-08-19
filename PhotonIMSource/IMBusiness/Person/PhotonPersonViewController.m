//
//  PhonePersonViewController.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonPersonViewController.h"
#import "PhotonPersonCell.h"
#import "PhotonEmptyTableItem.h"
#import "PhotonMessageCenter.h"
@interface PhotonPersonDataSource ()
@end

@implementation PhotonPersonDataSource
- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object{
    if ([object isKindOfClass:[PhotonPersonItem class]]) {
        return [PhotonPersonCell class];
    }
    return [super tableView:tableView cellClassForObject:object];
}
@end
@interface PhotonPersonViewController()<PhotonPersonCellDelegate>

@end
@implementation PhotonPersonViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self.tabBarItem setTitle:@"我"];
        [self.tabBarItem setImage:[UIImage imageNamed:@"me"]];
        [self.tabBarItem setSelectedImage:[UIImage imageNamed:@"me_onclick@"]];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我";
    [self.view setBackgroundColor:[UIColor colorWithHex:0xF3F3F3]];
    self.tableView.backgroundColor = [UIColor colorWithHex:0xF3F3F3];
    self.tableView.scrollEnabled = NO;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    PhotonUser *user = [PhotonContent userDetailInfo];
    PhotonPersonItem *personItem = [[PhotonPersonItem alloc] init];
    personItem.key = @"头像";
    personItem.value = user.avatarURL;
    personItem.shorArrow = YES;
    personItem.type = PhotonPersonItemTypeAvatar;
    
    PhotonPersonItem *personItem1 = [[PhotonPersonItem alloc] init];
    personItem1.key = @"账号";
    personItem1.value = user.userID;
    personItem1.type = PhotonPersonItemTypeAccount;
    
    PhotonPersonItem *personItem2 = [[PhotonPersonItem alloc] init];
    personItem2.key = @"昵称";
    personItem2.value = [user.nickName isNotEmpty]?user.nickName:@"未设置";
    personItem2.type = PhotonPersonItemTypeNick;
    personItem2.valueColor = [UIColor colorWithHex:0x5D5C6F];
    
    
    PhotonPersonItem *personItem4 = [[PhotonPersonItem alloc] init];
    personItem4.type = PhotonPersonItemTypeBTN;
    
    
    PhotonEmptyTableItem *emptyitem = [[PhotonEmptyTableItem alloc] init];
    emptyitem.itemHeight = 11.5;
    [self.items addObject:emptyitem];
    
    [self.items addObject:personItem];
    [self.items addObject:personItem1];
    [self.items addObject:personItem2];
    
    [self.items addObject:emptyitem];
    
    [self.items addObject:personItem4];
    PhotonPersonDataSource *dataSource = [[PhotonPersonDataSource alloc] initWithItems:self.items];
    self.dataSource = dataSource;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:[PhotonPersonCell class]]) {
        PhotonPersonCell *tempCell = (PhotonPersonCell *)cell;
        tempCell.delegate = self;
    }
}
- (void)logout:(id)cell{
    [[PhotonMessageCenter sharedCenter]  logout];
}

@end
