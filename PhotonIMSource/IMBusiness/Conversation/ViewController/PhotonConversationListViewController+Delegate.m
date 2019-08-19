//
//  PhotonConversationListViewController+Delegate.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/27.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonConversationListViewController+Delegate.h"
#import "PhotonMessageCenter.h"
#import "PhotonConversationItem.h"
#import "PhotonConversationBaseCell.h"
#import "PhotonChatViewController.h"
#import "PhotonFriendDetailViewController.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
@implementation PhotonConversationListViewController (Delegate)
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
        PhotonConversationItem *item = [self.model.items objectAtIndex:indexPath.row];
        [self.model.items removeObjectAtIndex:indexPath.row];
        self.dataSource.items = self.model.items;
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
        [[PhotonMessageCenter sharedCenter] deleteConversation:item.userInfo clearChatMessage:YES];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PhotonConversationItem *item = [[self.model.items objectAtIndex:indexPath.row] isNil];
    if (!item) {
        return;
    }
    PhotonChatViewController *chatvc = [[PhotonChatViewController alloc] initWithConversation:item.userInfo];
    [chatvc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:chatvc animated:YES];
    [[PhotonMessageCenter sharedCenter] clearConversationUnReadCount:item.userInfo];
}
@end
#pragma clang diagnostic pop
