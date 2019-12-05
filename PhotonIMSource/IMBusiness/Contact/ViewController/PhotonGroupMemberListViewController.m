//
//  PhotonGroupMemberListViewController.m
//  PhotonIM
//
//  Created by Bruce on 2019/9/26.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonGroupMemberListViewController.h"
#import "PhotonContacDataSource.h"
#import "PhotonGroupMemberListModel.h"
#import "PhotonEmptyTableItem.h"
@interface PhotonGroupMemberListViewController ()
@property (nonatomic, copy, nullable)NSString *gid;

@end

@implementation PhotonGroupMemberListViewController

- (instancetype)initWithGid:(NSString *)gid{
    self = [super init];
    if (self) {
        _gid = gid;
        self.model = [[PhotonGroupMemberListModel alloc] init];
        ((PhotonGroupMemberListModel *)self.model).showSelectBtn = NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"组成员";
    [self.view setBackgroundColor:[UIColor colorWithHex:0xF3F3F3]];
    self.tableView.backgroundColor = [UIColor colorWithHex:0xF3F3F3];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.and.bottom.mas_equalTo(self.view).mas_equalTo(0);
    }];
    [self loadDataItems];
}

- (void)loadDataItems{
    
    PhotonWeakSelf(self);
    if (![self.gid isNotEmpty]) {
        return;
    }
    ((PhotonGroupMemberListModel *)self.model).gid = self.gid;
    
    [self.model loadItems:nil finish:^(NSDictionary * _Nullable dict) {
        [weakself loadData];
    } failure:^(PhotonErrorDescription * _Nullable error) {
         [weakself loadData];
    }];
    
}
- (void)loadData{
    if (self.model.items.count > 0) {
        PhotonEmptyTableItem *emptyItem = [[PhotonEmptyTableItem alloc] init];
        emptyItem.itemHeight = 10;
        emptyItem.backgroudColor = [UIColor clearColor];
        [self.model.items insertObject:emptyItem atIndex:0];
    }
    PhotonContacDataSource *dataSource = [[PhotonContacDataSource alloc] initWithItems:self.model.items];
    self.dataSource = dataSource;
}
@end
