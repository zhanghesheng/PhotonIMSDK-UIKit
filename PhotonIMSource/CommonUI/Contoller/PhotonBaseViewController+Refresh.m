//
//  PhotonBaseViewController+Refresh.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/9.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseViewController+Refresh.h"
#import <MJRefresh/MJRefresh.h>
@interface PhotonBaseViewController(Refresh)

@end

@implementation PhotonBaseViewController(Refresh)

- (void)addRefreshHeader{
    __weak typeof(self)weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 加载刷新操作
        [weakSelf loadDataItems];
    }];
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    [self.tableView setMj_header:header];
}

- (void)beginRefreshing{
    [self.tableView.mj_header beginRefreshing];
}

- (void)endRefreshing{
    [self.tableView.mj_header endRefreshing];
}

- (void)removeRefreshHeader{
    [self.tableView setMj_header:nil];
}


- (void)addLoadMoreFooter
{
    __weak typeof(self)weakSelf = self;
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        //加载更多操作
        [weakSelf loadDataItems];
    }];
    [footer setTitle:@"正在加载..." forState:MJRefreshStateRefreshing];
    [footer setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
    [self.tableView setMj_footer:footer];
}

- (void)beginLoadMore
{
    [self.tableView.mj_footer beginRefreshing];
}

- (void)endLoadMore
{
    [self.tableView.mj_footer endRefreshing];
}

- (void)showNoMoreFooter
{
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
}

- (void)showNoMoreFooterWithTitle:(NSString *)title
{
    MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)self.tableView.mj_footer;
    [footer setTitle:title forState:MJRefreshStateNoMoreData];
    [self showNoMoreFooter];
}

- (void)removeLoadMoreFooter
{
    [self.tableView setMj_footer:nil];
}

@end
