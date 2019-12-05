//
//  PhotonGroupSettingViewController.m
//  PhotonIM
//
//  Created by Bruce on 2019/9/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonGroupSettingViewController.h"
#import "PhotonMacros.h"
#import "PhotonGroupTitleTableViewCell.h"
#import "PhotonGroupTitleTableItem.h"
#import "PhotonMessageSettingItem.h"
#import "PhotonMessageSettingCell.h"
#import "PhotonEmptyTableItem.h"
#import "PhotonGroupMemberTableItem.h"
#import "PhotonGroupMemberCell.h"
#import "PhotonNetworkService.h"
#import "PhotonGroupMemberListViewController.h"
@interface PhotonGroupSettingDataSource ()
@end

@implementation PhotonGroupSettingDataSource
- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object{
    if ([object isKindOfClass:[PhotonMessageSettingItem class]]) {
        return [PhotonMessageSettingCell class];
    }else if ([object isKindOfClass:[PhotonGroupTitleTableItem class]]){
        return [PhotonGroupTitleTableViewCell class];
    }else if ([object isKindOfClass:[PhotonGroupMemberTableItem class]]){
         return [PhotonGroupMemberCell class];
    }
    return [super tableView:tableView cellClassForObject:object];
}
@end


@interface PhotonGroupSettingViewController()<PhotonMessageSettingCellDelegate>
@property (nonatomic, copy, nullable)PhotonIMConversation *conversation;
@property (nonatomic, strong, nullable)PhotonNetworkService *netService;
@end

@implementation PhotonGroupSettingViewController
- (instancetype)initWithGroupID:(PhotonIMConversation *)conversation{
    self = [super init];
    if (self) {
        _conversation = conversation;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"消息设置";
    [self.view setBackgroundColor:[UIColor colorWithHex:0xF3F3F3]];
    self.tableView.backgroundColor = [UIColor colorWithHex:0xF3F3F3];
    self.tableView.scrollEnabled = NO;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.mas_equalTo(self.view).mas_equalTo(0);
        make.bottom.mas_equalTo(self.view).mas_equalTo(-SAFEAREA_INSETS_BOTTOM);
    }];
    [self loadDataItems];
}

- (void)loadDataItems{
    PhotonWeakSelf(self);
    
}

- (void)p_loadDataItems{
    PhotonUser *user = [PhotonContent friendDetailInfo:self.conversation.chatWith];
   
    PhotonEmptyTableItem *emptyItem = [[PhotonEmptyTableItem alloc] init];
    emptyItem.itemHeight = 5;
    emptyItem.backgroudColor = [UIColor clearColor];
    [self.items addObject:emptyItem];
    
    PhotonGroupTitleTableItem *titleItem = [[PhotonGroupTitleTableItem alloc] init];
    titleItem.title = @"聊天组名称";
    titleItem.itemHeight = 70;
    titleItem.icon = @"right_arrow";;
    titleItem.detail = user.nickName?user.nickName:@"无";
    titleItem.userInfo = [PhotonContent friendDetailInfo:self.conversation.chatWith];
    [self.items addObject:titleItem];
    
    PhotonEmptyTableItem *secondEmptyItem = [[PhotonEmptyTableItem alloc] init];
    secondEmptyItem.itemHeight = 11;
    secondEmptyItem.backgroudColor = [UIColor clearColor];
    [self.items addObject:secondEmptyItem];
    
    PhotonGroupTitleTableItem *memberItem = [[PhotonGroupTitleTableItem alloc] init];
    memberItem.title = @"组成员";
    memberItem.itemHeight = 30;
    memberItem.icon = @"right_arrow";
    NSInteger count = 10;
    memberItem.detail = [NSString stringWithFormat:@"%@人",@(count)];
    memberItem.userInfo = [PhotonContent friendDetailInfo:self.conversation.chatWith];
    [self.items addObject:memberItem];
    
    PhotonGroupMemberTableItem *memberItem1 = [[PhotonGroupMemberTableItem alloc] init];
    memberItem1.memebers = @[];
    memberItem1.itemHeight = 75;
    [self.items addObject:memberItem1];
    
    [self.items addObject:secondEmptyItem];
    
    PhotonMessageSettingItem *settionItem = [[PhotonMessageSettingItem alloc] init];
    settionItem.settingName = @"消息免打扰";
    settionItem.open = _conversation.ignoreAlert;
    settionItem.type = PhotonMessageSettingTypeIgnoreAlert;
    [self.items addObject:settionItem];
    
    PhotonMessageSettingItem *stickyItem = [[PhotonMessageSettingItem alloc] init];
    stickyItem.settingName = @"置顶";
    stickyItem.open = _conversation.sticky;
    stickyItem.type = PhotonMessageSettingTypeIgnorSticky;
    [self.items addObject:stickyItem];
    
    PhotonGroupSettingDataSource *dataSource = [[PhotonGroupSettingDataSource alloc] initWithItems:self.items];
    self.dataSource = dataSource;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = self.items[indexPath.row];
    BOOL gotoMember = NO;
    if ([item isKindOfClass:[PhotonGroupTitleTableItem class]]) {
        if([[item title] isEqualToString:@"组成员"]){
            gotoMember = YES;
        }
    }else if([item isKindOfClass:[PhotonGroupMemberTableItem class]]){
        gotoMember = YES;
    }
    
    if(gotoMember){
        PhotonGroupMemberListViewController *memberCtl = [[PhotonGroupMemberListViewController alloc] initWithGid:self.conversation.chatWith];
        [self.navigationController pushViewController:memberCtl animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:[PhotonMessageSettingCell class]]) {
        PhotonMessageSettingCell *tempCell = (PhotonMessageSettingCell *)cell;
        tempCell.delegate = self;
        
    }
}

- (void)cell:(id)cell switchItem:(PhotonMessageSettingItem *)item{
    switch (item.type) {
        case PhotonMessageSettingTypeIgnoreAlert:{
            _conversation.ignoreAlert = item.open;
            [self setIgnoreAlert:item.open];
        }
            break;
        case PhotonMessageSettingTypeIgnorSticky:{
            _conversation.sticky = item.open;
            [[PhotonIMClient sharedClient] updateConversationSticky:_conversation];
        }
            break;
            
        default:
            break;
    }
}

- (void)setIgnoreAlert:(BOOL)open{
    NSMutableDictionary *paramter = [NSMutableDictionary dictionary];
    [paramter setValue:self.conversation.chatWith forKey:@"gid"];
    [paramter setValue:@(!open) forKey:@"switch"];
    PhotonWeakSelf(self);
    [self.netService commonRequestMethod:PhotonRequestMethodPost queryString:@"photonimdemo/setting/msg/setP2GRemind" paramter:paramter completion:^(NSDictionary * _Nonnull dict) {
         [[PhotonMessageCenter sharedCenter] updateConversationIgnoreAlert:weakself.conversation];
        [PhotonUtil showSuccessHint:@"设置成功!"];
    } failure:^(PhotonErrorDescription * _Nonnull error) {
        [PhotonUtil showErrorHint:@"设置失败!"];
    }];
}
- (PhotonNetworkService *)netService{
    if (!_netService) {
        _netService = [[PhotonNetworkService alloc] init];
        _netService.baseUrl = PHOTON_BASE_URL;
        
    }
    return _netService;
}
@end
