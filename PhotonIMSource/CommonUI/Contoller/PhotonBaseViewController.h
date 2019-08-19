//
//  PhotonBaseViewController.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PotonTableViewDataSource.h"
#import "PhotonBaseUITableView.h"
NS_ASSUME_NONNULL_BEGIN

@interface PhotonBaseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong, nullable) PhotonBaseUITableView *tableView;
@property (nonatomic, assign) BOOL enableWithoutScrollToTop;
@property (nonatomic, strong, nullable) id<PotonTableViewDataSourceProtocol> dataSource;
@property(nonatomic, strong,nullable) NSMutableArray *items;
@property(nonatomic,assign) UITableViewStyle tableViewStyle;
- (void)loadDataItems;
- (void)reloadData;

- (void)loadNoDataView;
- (void)removeNoDataView;
@end

NS_ASSUME_NONNULL_END
