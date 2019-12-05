//
//  PhotonConversationListViewController.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonConversationListViewController.h"
#import "PhotonConversationListViewController+Delegate.h"
#import <MMFoundation/MMFoundation.h>
#import "PhotonBaseViewController+Refresh.h"
#import "PhotonConversationDataSource.h"
#import "PhotonConversationItem.h"
#import "PhotonConversationModel.h"
#import "PhotonMessageCenter.h"
#import "PhotonNetTableItem.h"
static NSString *message_title = @"消息";
static NSString *message_connecting = @"消息(连接中...)";
static NSString *message_no_connect = @"消息(未连接)";
static NSString *message_syncing = @"消息(收取中......)";

@interface PhotonConversationListViewController ()<PhotonMessageProtocol,MFDispatchSourceDelegate,UITabBarControllerDelegate>
@property (nonatomic, strong, nullable)MFDispatchSource  *dataDispatchSource;
@property (nonatomic, assign)BOOL   isAppeared;
@property (nonatomic, assign)BOOL   needRefreshData;
@property (nonatomic, strong)PhotonIMTimer *imTimer;
@property (nonatomic, assign)NSInteger  refreshCount;
@property (nonatomic, assign)BOOL  isExcute;
@property (nonatomic, assign)NSInteger lastOprationTimeStamp;

@property (atomic, assign)BOOL isRefreshing;
@property (atomic, assign)BOOL firstLoadData;
@property (nonatomic, retain)dispatch_semaphore_t signa;
@property (nonatomic, strong)dispatch_queue_t sessionChangeQueue;
@end

@implementation PhotonConversationListViewController
- (void)dealloc
{
    [[PhotonMessageCenter sharedCenter] removeObserver:self];
    [_dataDispatchSource clearDelegateAndCancel];
}

- (void)setNavTitle:(NSString *)text{
    PhotonWeakSelf(self);
    [PhotonUtil runMainThread:^{
        NSInteger totalCount = [[PhotonMessageCenter sharedCenter] unreadMsgCount];
        if([text isEqualToString:message_title] && totalCount > 0){
            weakself.navigationItem.title = [NSString stringWithFormat:@"消息(%@)",@(totalCount)];
        }else{
            weakself.navigationItem.title = text;
        }
        
    }];
}


- (void)setTabBarBadgeValue{
     PhotonWeakSelf(self);
    [PhotonUtil runMainThread:^{
        NSInteger totalCount = [[PhotonMessageCenter sharedCenter] unreadMsgCount];
        if (totalCount > 0) {
            NSString *valueStr = [NSString stringWithFormat:@"%@",@(totalCount)];
//            if (totalCount > 99) {
//                totalCount = 99;
//                valueStr = [NSString stringWithFormat:@"%@+",@(totalCount)];
//            }
            weakself.tabBarItem.badgeValue = [NSString stringWithFormat:@"%@",valueStr];
            weakself.tabBarItem.badgeColor = [UIColor redColor];
            weakself.navigationItem.title = [NSString stringWithFormat:@"消息(%@)",valueStr];
        }else{
            weakself.tabBarItem.badgeValue = nil;
            if (![weakself.navigationItem.title containsString:@"连接"]) {
                 weakself.navigationItem.title = message_title;
            }
           
        }
    }];
}
- (instancetype)init
{
    if (self = [super init]) {
        _signa = dispatch_semaphore_create(0);
        self.model = [[PhotonConversationModel alloc] init];
         [[PhotonMessageCenter sharedCenter] addObserver:self];
        _refreshCount = 0;
        _firstLoadData = YES;
        [self.tabBarItem setTitle:@"消息"];
        self.tabBarItem.tag = 1;
        [self.tabBarItem setImage:[UIImage imageNamed:@"message"]];
        [self.tabBarItem setSelectedImage:[UIImage imageNamed:@"message_onClick"]];
        
        _sessionChangeQueue = dispatch_queue_create("com.cosmos.PhotonIM.conversationchange", DISPATCH_QUEUE_SERIAL);
        _dataDispatchSource = [MFDispatchSource sourceWithDelegate:self type:refreshType_Data dataQueue:dispatch_queue_create("com.cosmos.PhotonIM.conversationdata", DISPATCH_QUEUE_SERIAL)];

    }
    return self;
}

//判断是否跳转
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if (tabBarController.tabBar.selectedItem.tag == 1) {
        self.isAppeared = YES;
        [self.dataDispatchSource addSemaphore];
    }else{
         self.isAppeared = NO;
    }
     return YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.needRefreshData) {
        [self.dataDispatchSource addSemaphore];
        self.needRefreshData = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.isAppeared = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.isAppeared = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.delegate = self;
    [self setNavTitle:@"消息"];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self.dataDispatchSource addSemaphore];
}
- (void)addNetStatusItem{
    PhotonNetTableItem *item = [[PhotonNetTableItem alloc] init];
    item.message = @"网络断开，请检查网络配置";
    [self.model.items insertObject:item atIndex:0];
    [self reloadData];
}
- (void)removeNetStatusItem{
    id item = [self.model.items firstObject];
    if ([item isKindOfClass:[PhotonNetTableItem class]]) {
        [self.model.items removeObject:item];
    }
    [self reloadData];
}
- (void)loadDataItems{
    __weak typeof(self)weakSlef = self;
    [self.model loadItems:nil finish:^(NSDictionary * _Nullable dict) {
        [weakSlef removeNoDataView];
        [weakSlef reloadData];
        [weakSlef endRefreshing];
        weakSlef.isRefreshing = NO;
    } failure:^(PhotonErrorDescription * _Nullable error) {
        [PhotonUtil showAlertWithTitle:@"加载会话列表失败" message:error.errorMessage];
        [weakSlef reloadData];
        [weakSlef loadNoDataView];
        [weakSlef endRefreshing];
        weakSlef.isRefreshing = NO;
    }];
}
- (void)refreshTableView{
    PhotonConversationDataSource *dataSource = [[PhotonConversationDataSource alloc] initWithItems:self.model.items];
    self.dataSource = dataSource;
    if(_firstLoadData){
        dispatch_semaphore_signal(_signa);
         _firstLoadData = NO;
    }
   
}
- (void)conversationChange:(PhotonIMConversationEvent)envent chatType:(PhotonIMChatType)chatType chatWith:(NSString *)chatWith{
    __weak typeof(self)weakSelf = self;
    dispatch_async(self.sessionChangeQueue, ^{
        [weakSelf _conversationChange:envent chatType:chatType chatWith:chatWith];
    });
}
- (void)_conversationChange:(PhotonIMConversationEvent)envent chatType:(PhotonIMChatType)chatType chatWith:(NSString *)chatWith{
    if (_firstLoadData) {
        dispatch_semaphore_wait(_signa, DISPATCH_TIME_FOREVER);
    }
     PhotonIMConversation *conversation = [[PhotonMessageCenter sharedCenter] findConversation:chatType chatWith:chatWith];
    if (!conversation) {
        return;
    }
    [self setTabBarBadgeValue];
    if (!self.isAppeared) {
        self.needRefreshData  = YES;
        return;
    }
    PhotonWeakSelf(self)
    switch (envent) {
        case PhotonIMConversationEventCreate:{
            [[PhotonIMClient sharedClient] runInPhotonIMDBQueue:^{
                [weakself insertConversation:conversation];
            }];
        }
            break;
        case PhotonIMConversationEventDelete:
            break;
        case PhotonIMConversationEventUpdate:{
            [[PhotonIMClient sharedClient] runInPhotonIMDBQueue:^{
                [weakself updateConversation:conversation chatType:chatType chatWith:chatWith];
            }];
        }
            break;
        default:
            break;
    }
}

- (void)insertConversation:(PhotonIMConversation *)conversation{
    if (!conversation) {
        return;
    }
    PhotonConversationItem *temp = [[PhotonConversationItem alloc] init];
    PhotonUser *user = [PhotonContent friendDetailInfo:conversation.chatWith];
    conversation.FAvatarPath = user.avatarURL;
    conversation.FName = user.nickName;
    temp.userInfo = conversation;
    [self.model.items insertObject:temp atIndex:0];
    [self reloadData];
}

- (void)updateConversation:(PhotonIMConversation *)conversation chatType:(PhotonIMChatType)chatType chatWith:(NSString *)chatWith{
    PhotonConversationItem *temp = nil;
    NSInteger index = -1;
    BOOL isToTop = NO;
    for (PhotonConversationItem *item in self.model.items) {
        PhotonIMConversation *conver = [item userInfo];
        if ([[conver chatWith] isEqualToString:chatWith] && ([conver chatType] == chatType)) {
            PhotonUser *user = [PhotonContent friendDetailInfo:conversation.chatWith];
            conversation.FAvatarPath = user.avatarURL;
            conversation.FName = user.nickName;
            temp = item;
            temp.userInfo = conversation;
            index = [self.model.items indexOfObject:item];
            isToTop = (conversation.lastTimeStamp > conver.lastTimeStamp) && (index > 0);
            break;
        }
    }
    if (temp && isToTop) {
        [self.model.items removeObjectAtIndex:index];
        [self.model.items insertObject:temp atIndex:0];
        [self reloadData];
        return;
    }
    if (temp && index == 0) {
        [self updateItem:temp];
    }
}



- (void)readyRefreshConversations{
    if (_isRefreshing) {
        return;
    }
    _isRefreshing = YES;
    [self startRefreshConversations];
}

- (void)startRefreshConversations{
    [self loadDataItems];
}


- (void)networkChange:(PhotonIMNetworkStatus)networkStatus{
    if (networkStatus == PhotonIMNetworkStatusNone) {
        [self setNavTitle:message_no_connect];
    }
}

- (void)imClientLogin:(id)client loginStatus:(PhotonIMLoginStatus)loginstatus{
    switch (loginstatus) {
        case PhotonIMLoginStatusConnecting:// 连接中
            [self setNavTitle:message_connecting];
            break;
        case PhotonIMLoginStatusConnected:// 连接成功
            break;
        case PhotonIMLoginStatusLoginSucceed:// 登录成功
             [self setNavTitle:message_title];
            break;
        case PhotonIMLoginStatusConnectFailed:// 连接失败
             [self setNavTitle:message_no_connect];
            break;
        default:
            break;
    }
}

- (BOOL)imClientSync:(id)client syncStatus:(PhotonIMSyncStatus)status{
    switch (status) {
        case PhotonIMSyncStatusSyncStart:{
            [self setNavTitle:message_syncing];
        }
            break;
        case PhotonIMSyncStatusSyncEnd:
           [self setTabBarBadgeValue];
           [self setNavTitle:message_title];
            break;
        case PhotonIMSyncStatusSyncTimeout:
            break;
        default:
            break;
    }
    PhotonLog(@"imClientSync:(nonnull id)client syncStatus:(PhotonIMSyncStatus)status 1");
    return YES;
}

#pragma mark --- 刷新数据 ------
- (void)refreshData{
    [self readyRefreshConversations];
}
@end
