//
//  PhotonGroupContactViewController.m
//  PhotonIM
//
//  Created by Bruce on 2019/9/23.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonGroupContactViewController.h"
#import "PhotonBaseViewController+Refresh.h"
#import "PhotonGroupContactModel.h"
#import "PhotonContacDataSource.h"
#import "PhotonGroupContactItem.h"
#import "PhotonGroupContactCell.h"
#import "PhotonChatViewController.h"

@interface PhotonGroupContactViewController ()<PhotonGroupContactCellDelegate>
@property (nonatomic, strong, nullable)PhotonGroupContactModel *model;
@end

@implementation PhotonGroupContactViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.model = [[PhotonGroupContactModel alloc] init];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addRefreshHeader];
    self.title = @"附近的群组";
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
        [PhotonUtil showAlertWithTitle:@"加载群组列表失败" message:error.errorMessage];
        [weakSlef p_loadDataItems];
        [weakSlef loadNoDataView];
        [weakSlef endRefreshing];
    }];
}
- (void)p_loadDataItems{
    PhotonContacDataSource *dataSource = [[PhotonContacDataSource alloc] initWithItems:self.model.items];
    self.dataSource = dataSource;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:[PhotonGroupContactCell class]]) {
        PhotonGroupContactCell *tempCell = (PhotonGroupContactCell *)cell;
        tempCell.delegate = self;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.model.items.count) {
        PhotonGroupContactItem *temp_Item = (PhotonGroupContactItem *)[self.model.items objectAtIndex:indexPath.row];
        if (temp_Item.isInGroup) {
            PhotonIMConversation *conversation = [[PhotonIMConversation alloc] initWithChatType:PhotonIMChatTypeGroup chatWith:temp_Item.contactID];
            conversation.FName = temp_Item.contactName;
            
            PhotonChatViewController *chatCtl = [[PhotonChatViewController alloc] initWithConversation:conversation];
            [self.navigationController pushViewController:chatCtl animated:YES];
            
        }
    }
}

- (void)refreshCellAfterEnterGroup:(NSIndexPath *)indexPath{
    if (indexPath.row < self.model.items.count) {
        PhotonGroupContactItem *temp_Item = (PhotonGroupContactItem *)[self.model.items objectAtIndex:indexPath.row];
        temp_Item.isInGroup = YES;
        [self.model.items replaceObjectAtIndex:indexPath.row withObject:temp_Item];
        [PhotonUtil runMainThread:^{
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    
}

- (void)cellEnterGroup:(PhotonGroupContactCell *)cell item:(id)item{
    PhotonGroupContactItem *temp_Item = (PhotonGroupContactItem *)item;
    if (!temp_Item || self.model.items.count == 0) {
        return;
    }
    NSInteger index = [self.model.items indexOfObject:item];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    PhotonWeakSelf(self);
    if (!temp_Item.isInGroup) {
        [self.model enterGroup:temp_Item.contactID finish:^(NSDictionary * _Nullable dict) {
            [weakself refreshCellAfterEnterGroup:indexPath];
        } failure:^(PhotonErrorDescription * _Nullable erro) {
            
        }];
    }
}

@end
