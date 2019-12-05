//
//  PhotonBaseViewController.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/21.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseViewController.h"
#import "PhotonTableViewCell.h"
#import "PhotonIMDispatchSource.h"
@interface PhotonBaseViewController (){
    void *IsOnPhotonLoadDataQueueKey;
}
@property (nonatomic, strong, nullable) UIView   *noDataView;
@property (nonatomic, assign) CGPoint contentOffsetForRestore;
@property (nonatomic, strong, nullable)PhotonIMDispatchSource *reloadDataRefreshUISource;
@property (nonatomic, strong, nullable)PhotonIMDispatchSource *updateDataRefreshUISource;
@property (nonatomic, strong, nullable)PhotonIMDispatchSource *addDataRefreshUISource;
@property (nonatomic, strong, nullable)PhotonIMDispatchSource *loadDataSource;

@property (nonatomic, strong, nullable)dispatch_queue_t dataQueue;
@end

@implementation PhotonBaseViewController
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _tableViewStyle = UITableViewStylePlain;
        _tableView = [[PhotonBaseUITableView alloc] initWithFrame:CGRectZero style:_tableViewStyle];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _updateDataRefreshUISource = [[PhotonIMDispatchSource alloc] initWithEventQueue:dispatch_get_main_queue() eventBlack:[self updateCellEventBlock]];
        _addDataRefreshUISource = [[PhotonIMDispatchSource alloc] initWithEventQueue:dispatch_get_main_queue() eventBlack:[self addCellEventBlock]];
        _reloadDataRefreshUISource = [[PhotonIMDispatchSource alloc] initWithEventQueue:dispatch_get_main_queue() eventBlack:[self reloadCellEventBlock]];
        
        _loadDataSource = [[PhotonIMDispatchSource alloc] initWithEventQueue:self.dataQueue eventBlack:[self reloadDataEventBlock]];
        
        _tableViewStyle = UITableViewStylePlain;
        _tableView = [[PhotonBaseUITableView alloc] initWithFrame:CGRectZero style:_tableViewStyle];
    }
    return self;
}


- (void)dealloc
{
    [_updateDataRefreshUISource clearDelegateAndCancel];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (dispatch_queue_t)dataQueue{
    if (!_dataQueue) {
          NSString *queuenName = [NSString stringWithFormat:@"com.cosmos.PhotonIM.%@.loadDataqueue",NSStringFromClass([self class])];
             _dataQueue = dispatch_queue_create(queuenName.UTF8String, DISPATCH_QUEUE_SERIAL);
        IsOnPhotonLoadDataQueueKey = &IsOnPhotonLoadDataQueueKey;
        void *nonNullUnusedPointer = (__bridge void *)self;
        dispatch_queue_set_specific(_dataQueue, IsOnPhotonLoadDataQueueKey, nonNullUnusedPointer, NULL);
    }
    return _dataQueue;
}

- (BOOL)currentQueuePhotonLoadDataQueue
{
    if (dispatch_get_specific(IsOnPhotonLoadDataQueueKey)){
        return YES;
    }
    else {
        return NO;
    }
}

- (void)runPhotonLoadDataQueue:(dispatch_block_t)block{
    if ([self currentQueuePhotonLoadDataQueue]) {
        block();
    }else{
        dispatch_async(self.dataQueue,block);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    [self.view addSubview:self.tableView];
    self.items = [NSMutableArray arrayWithCapacity:1];
}


- (void)backPre{
    [self.navigationController popViewControllerAnimated:YES];
}

- (PhotonIMDispatchSourceEventBlock)reloadDataEventBlock{
    __weak typeof(self)weakSlef = self;
    PhotonIMDispatchSourceEventBlock eventBlock = ^(id userInfo){
         [weakSlef loadDataItems];
    };
    return eventBlock;
}
- (void)startLoadData{
    __weak typeof(self)weakSelf = self;
    [self runPhotonLoadDataQueue:^{
        [weakSelf.loadDataSource addEventSource:nil];
    }];
}
- (void)loadDataItems{
    
}

- (void)reloadData{
    __weak typeof(self)weakSelf = self;
    [self runPhotonLoadDataQueue:^{
        [weakSelf.reloadDataRefreshUISource addEventSource:nil];
    }];
}
- (PhotonIMDispatchSourceEventBlock)reloadCellEventBlock{
    __weak typeof(self)weakSlef = self;
    PhotonIMDispatchSourceEventBlock eventBlock = ^(id userInfo){
         [weakSlef refreshTableView];
    };
    return eventBlock;
}

- (void)refreshTableView{
    
}
- (void)addItem:(PhotonBaseTableItem *)item{
    __weak typeof(self)weakSelf = self;
       [self runPhotonLoadDataQueue:^{
           [weakSelf.addDataRefreshUISource addEventSource:item];
       }];
}
- (PhotonIMDispatchSourceEventBlock)addCellEventBlock{
    __weak typeof(self)weakSlef = self;
    PhotonIMDispatchSourceEventBlock eventBlock = ^(id userInfo){
        if (userInfo) {
           [weakSlef _addItem:userInfo];
        }
    };
    return eventBlock;
}
- (void)_addItem:(PhotonBaseTableItem *)item{
    NSInteger index = self.model.items.count;
    [self.model.items addObject:item];
    if(!self.dataSource || self.dataSource.items == 0){
        return;
    }
    [self.dataSource.items addObject:item];
    [self insert:@[@(index)] animated:YES];
}

- (void)updateItem:(PhotonBaseTableItem *)item{
    __weak typeof(self)weakSelf = self;
     [self runPhotonLoadDataQueue:^{
         [weakSelf.updateDataRefreshUISource addEventSource:@[item]];
     }];
}

- (PhotonIMDispatchSourceEventBlock)updateCellEventBlock{
    __weak typeof(self)weakSlef = self;
    PhotonIMDispatchSourceEventBlock eventBlock = ^(id userInfo){
        if (userInfo) {
           [weakSlef _updateItem:userInfo];
        }
    };
    return eventBlock;
}
- (void)_updateItem:(NSArray<PhotonBaseTableItem *> *)items{
    NSInteger index = -1;
    NSMutableArray< NSIndexPath *> *indexPaths = [NSMutableArray array];
    for (PhotonBaseTableItem * item in items) {
          if ([self.model.items containsObject:item]) {
              index = [self.dataSource.items indexOfObject:item];
          }
          if (index < 0) {
              continue;
          }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [indexPaths addObject:indexPath];
    }
    [self update:indexPaths];
}

- (void)removeItem:(PhotonBaseTableItem *)item{
    PhotonWeakSelf(self)
    [PhotonUtil runMainThread:^{
        [weakself _removeItem:item];
    }];
}
- (void)_removeItem:(PhotonBaseTableItem *)item{
    NSInteger index = -1;
    if ([self.dataSource.items containsObject:item]) {
        index = [self.dataSource.items indexOfObject:item];
    }
    if (index < 0) {
        return;
    }
    [self.dataSource.items removeObjectAtIndex:index];
    [self remove:@[[NSIndexPath indexPathForRow:index inSection:0]]];
}

- (void)insert:(NSArray<NSNumber *> *)indexPaths animated:(BOOL)animated
{
    if (!indexPaths.count)
    {
        return;
    }

    NSMutableArray *addIndexPathes = [NSMutableArray array];
    [indexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[obj integerValue] inSection:0];
        [addIndexPathes addObject:indexPath];
    }];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:addIndexPathes withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:addIndexPathes.lastObject atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)remove:(NSArray<NSIndexPath *> *)indexPaths
{
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    NSInteger row = [self.tableView numberOfRowsInSection:0] - 1;
    if (row > 0)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


- (void)update:(NSArray<NSIndexPath *> *)indexPaths
{
    PhotonTableViewCell *cell = (PhotonTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPaths.lastObject];
    if (cell) {
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        CGFloat scrollOffsetY = self.tableView.contentOffset.y;
        [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, scrollOffsetY) animated:NO];
    }
}

- (void)loadNoDataView{
    if (!_noDataView) {
        _noDataView = [[UIView alloc] init];
        _noDataView.userInteractionEnabled = NO;
    }
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nomessage"]];
    icon.backgroundColor = [UIColor clearColor];
    icon.userInteractionEnabled = NO;
    [_noDataView addSubview:icon];
    
    UILabel *tip = [[UILabel alloc] init];
    tip.textColor = [UIColor colorWithHex:0xCECECE];
    tip.userInteractionEnabled = NO;
    tip.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    tip.textAlignment = NSTextAlignmentCenter;
    tip.text = @"暂无消息";
    
    [_noDataView addSubview:icon];
    [_noDataView addSubview:tip];
    [self.view addSubview:_noDataView];
    
    [_noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(300, 300));
    }];
    
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.noDataView);
    }];
    
    [tip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(20);
        make.top.mas_equalTo(icon.mas_bottom);
    }];
    
}
- (void)removeNoDataView{
    [self.noDataView removeFromSuperview];
}
- (void)setDataSource:(id<PotonTableViewDataSourceProtocol>)dataSource{
    if (dataSource != _dataSource) {
        _dataSource = dataSource;
        _tableView.dataSource = nil;
    }
    
    _tableView.dataSource = _dataSource;
    if (self.enableWithoutScrollToTop) {
        [_tableView reloadDataWithoutScrollToTop];
    }else{
        [_tableView reloadData];
    }
    
}

#pragma mark UITableViewDataDelegate
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView.dataSource isKindOfClass:[PotonTableViewDataSource class]]) {
        id <PotonTableViewDataSourceProtocol> dataSource = (id <PotonTableViewDataSourceProtocol>) tableView.dataSource;
        id object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
        Class cls = [dataSource tableView:tableView cellClassForObject:object];
        CGFloat height = [cls tableView:tableView rowHeightForObject:object];
        return height;
    }
    return DEFAULT_TABLE_CELL_HRIGHT;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView.dataSource isKindOfClass:[PotonTableViewDataSource class]]) {
        id <PotonTableViewDataSourceProtocol> dataSource = (id <PotonTableViewDataSourceProtocol>) tableView.dataSource;
        id object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
        Class cls = [dataSource tableView:tableView cellClassForObject:object];
        CGFloat height = [cls tableView:tableView rowHeightForObject:object];
        return height;
    }
    
    return DEFAULT_TABLE_CELL_HRIGHT;
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
