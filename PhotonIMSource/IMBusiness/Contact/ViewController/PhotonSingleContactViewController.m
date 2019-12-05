//
//  PhotonContactViewController.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonSingleContactViewController.h"
#import "PhotonBaseViewController+Refresh.h"
#import "PhotonSingleContactModel.h"
#import "PhotonContacDataSource.h"
#import "PhotonFriendDetailViewController.h"
@interface PhotonSingleContactViewController ()
@end

@implementation PhotonSingleContactViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.model = [[PhotonSingleContactModel alloc] init];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addRefreshHeader];
    self.title = @"附近在线的人";
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self loadDataItems];
}

- (void)loadDataItems{
    __weak typeof(self)weakSlef = self;
    [self.model loadItems:nil finish:^(NSDictionary * _Nullable dict) {
        [weakSlef removeNoDataView];
        [weakSlef p_loadDataItems];
        [weakSlef endRefreshing];
    } failure:^(PhotonErrorDescription * _Nullable error) {
        [PhotonUtil showAlertWithTitle:@"加载好友列表失败" message:error.errorMessage];
        [weakSlef p_loadDataItems];
        [weakSlef loadNoDataView];
        [weakSlef endRefreshing];
    }];
}
- (void)p_loadDataItems{
    PhotonContacDataSource *dataSource = [[PhotonContacDataSource alloc] initWithItems:self.model.items];
    self.dataSource = dataSource;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PhotonBaseContactItem *item = self.model.items[indexPath.row];
    PhotonFriendDetailViewController *detailVCL = [[PhotonFriendDetailViewController alloc] initWithFriend:item.userInfo];
    [detailVCL setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:detailVCL animated:YES];
}
@end
