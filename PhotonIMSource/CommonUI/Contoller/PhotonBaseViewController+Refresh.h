//
//  PhotonBaseViewController+Refresh.h
//  PhotonIM
//
//  Created by Bruce on 2019/7/9.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotonBaseViewController(Refresh)
#pragma mark ------ add refresh header --------
- (void)addRefreshHeader;
- (void)beginRefreshing;
- (void)endRefreshing;
- (void)removeRefreshHeader;

#pragma mark ------- add footer load more ------
- (void)addLoadMoreFooter;
- (void)beginLoadMore;
- (void)endLoadMore;
- (void)showNoMoreFooter;
- (void)showNoMoreFooterWithTitle:(NSString *)title;
- (void)removeLoadMoreFooter;
@end

NS_ASSUME_NONNULL_END
