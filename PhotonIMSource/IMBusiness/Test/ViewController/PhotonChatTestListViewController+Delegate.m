//
//  PhotonConversationListViewController+Delegate.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/27.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonChatTestListViewController+Delegate.h"
#import "PhotonMessageCenter.h"
#import "PhotonChatTestItem.h"
#import "PhotonChatTestBaseCell.h"
#import "PhotonChatViewController.h"
#import "PhotonFriendDetailViewController.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
@implementation PhotonChatTestListViewController (Delegate)
#pragma mark --------- UITableViewDelegate -----
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self)weakSelf = self;
    UITableViewRowAction *delAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                         title:@"删除"
                                                                       handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                                           [weakSelf p_deleteCellWithIndexPath:indexPath];
                                                                              [tableView setEditing:NO animated:YES];
                                                                       }];
    return @[delAction];
}

- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)){
    __weak typeof(self)weakSelf = self;
    if (@available(iOS 11.0, *)) {
        UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
             [weakSelf p_deleteCellWithIndexPath:indexPath];
             [tableView setEditing:NO animated:YES];
        }];
        deleteRowAction.backgroundColor = [UIColor redColor];
    
        UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
        config.performsFirstActionWithFullSwipe = false;
        return config;
    }else{
        return nil;
    }
    return nil;
}



- (void)p_deleteCellWithIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.model.items.count) {
        PhotonChatTestItem *item = [self.model.items objectAtIndex:indexPath.row];
        [self.model.items removeObjectAtIndex:indexPath.row];
        self.dataSource.items = self.model.items;
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
        [[PhotonMessageCenter sharedCenter] deleteConversation:item.userInfo clearChatMessage:YES];
    }
    
}


@end
#pragma clang diagnostic pop
