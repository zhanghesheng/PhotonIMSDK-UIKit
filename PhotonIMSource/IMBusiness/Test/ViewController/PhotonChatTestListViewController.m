//
//  PhotonConversationListViewController.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonChatTestListViewController.h"
#import "PhotonChatTestListViewController+Delegate.h"
#import <MMFoundation/MMFoundation.h>
#import "PhotonBaseViewController+Refresh.h"
#import "PhotonChatTestDataSource.h"
#import "PhotonChatTestItem.h"
#import "PhotonChatTestModel.h"
#import "PhotonMessageCenter.h"
#import "PhotonNetTableItem.h"
#import "PhotonSafeMutableDictionary.h"
#import "PhotonChatData.h"
static NSString *message_title = @"消息";
static NSString *message_connecting = @"消息(连接中...)";
static NSString *message_no_connect = @"消息(未连接)";
static NSString *message_syncing = @"消息(收取中......)";

@interface PhotonChatTestListViewController ()<PhotonMessageProtocol,MFDispatchSourceDelegate,UITabBarDelegate,UITabBarControllerDelegate>
@property (nonatomic, strong, nullable)MFDispatchSource  *dataDispatchSource;
@property (nonatomic, assign)BOOL   isAppeared;
@property (nonatomic, assign)BOOL   needRefreshData;
@property (nonatomic, strong)PhotonIMTimer *imTimer;
@property (nonatomic, assign)NSInteger  refreshCount;
@property (nonatomic, assign)BOOL  isExcute;
@property (nonatomic, assign)NSInteger lastOprationTimeStamp;
@property (nonatomic, strong)PhotonSafeMutableDictionary *chatDataCache;

@property (atomic, assign)BOOL isRefreshing;
@property (atomic, assign)BOOL firstLoadData;
@property (atomic, retain)dispatch_semaphore_t signa;
@property (nonatomic, strong)dispatch_queue_t conversationChangeQueue;

@property (nonatomic, strong) UIView  *headerContentView;
@property (nonatomic, strong) UILabel *authSuccessedCountLable;
@property (nonatomic, strong) UILabel *authFailedCountLable;
//@property (nonatomic, strong) UIButton *addConversation;
@property (nonatomic, assign)int authSuccessedCount;
@property (nonatomic, assign)int authFailedCount;

@property (nonatomic, strong)PhotonIMConversation *currentConversation;

// 内容
@property (nonatomic, strong,nullable)UITextField  *contentFiled;
// 间隔放松的时间
@property (nonatomic, strong,nullable)UITextField  *intervalFiled;
// 间隔放松的时间
@property (nonatomic, strong,nullable)UITextField  *countFiled;
// login内容
@property (nonatomic, strong,nullable)UILabel  *authFiled;
@property (nonatomic, strong,nullable)UIView  *testUIView;
@property(nonatomic, strong)UILabel  *totleSendCountLable;
@property(nonatomic, strong)UILabel  *sendSucceedCountLable;
@property(nonatomic, strong)UILabel  *sendFailedCountLable;
@property(nonatomic, strong)UILabel  *totalTimeLable;
@property(nonatomic, strong)UILabel  *titleLable;
@end

@implementation PhotonChatTestListViewController
- (void)dealloc
{
    [[PhotonMessageCenter sharedCenter] removeObserver:self];
    [_dataDispatchSource clearDelegateAndCancel];
}
- (instancetype)init
{
    if (self = [super init]) {
        _signa = dispatch_semaphore_create(0);
        self.model = [[PhotonChatTestModel alloc] init];
         [[PhotonMessageCenter sharedCenter] addObserver:self];
        _refreshCount = 0;
        _firstLoadData = YES;
        _authFailedCount = 0;
        _authSuccessedCount = 0;
        self.navigationItem.title =@"测试";
        self.tabBarItem.tag = 4;
        [self.tabBarItem setTitle:@"测试"];
        [self.tabBarItem setImage:[UIImage imageNamed:@"message"]];
        [self.tabBarItem setSelectedImage:[UIImage imageNamed:@"message_onClick"]];
        _dataDispatchSource = [MFDispatchSource sourceWithDelegate:self type:refreshType_Data dataQueue:dispatch_queue_create("com.cosmos.PhotonIM.conversationdata", DISPATCH_QUEUE_SERIAL)];
        
    }
    return self;
}

- (dispatch_queue_t)conversationChangeQueue{
    if (!_conversationChangeQueue) {
         _conversationChangeQueue = dispatch_queue_create("com.cosmos.PhotonIM.test_conversationchange", DISPATCH_QUEUE_SERIAL);
    }
    return _conversationChangeQueue;
}

- (PhotonSafeMutableDictionary *)chatDataCache{
    if (!_chatDataCache) {
        _chatDataCache = [[PhotonSafeMutableDictionary alloc] init];
    }
    return _chatDataCache;
}

- (void)createHeaderContentView{
    _headerContentView = [[UIView alloc] init];
    _headerContentView.backgroundColor = [UIColor colorWithHex:0xffb549];
    [self.view addSubview:_headerContentView];
    CGFloat navigationBarAndStatusBarHeight = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
    [_headerContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self.view).mas_offset(0);
        make.top.mas_equalTo(self.view).mas_offset(navigationBarAndStatusBarHeight);
        make.height.mas_equalTo(60);
    }];
    UILabel *testLable = [[UILabel alloc] init];
    testLable.text = @"本轮测试";
    testLable.textColor = [UIColor blackColor];
    testLable.font = [UIFont systemFontOfSize:15];
    testLable.textAlignment = NSTextAlignmentLeft;
    [_headerContentView addSubview:testLable];
    [testLable mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.and.right.mas_equalTo(self.view).mas_offset(10);
           make.top.mas_equalTo(self.headerContentView).mas_offset(2);
           make.height.mas_equalTo(20);
    }];
    
    UILabel *authSuccessedLable = [[UILabel alloc] init];
    authSuccessedLable.text = @"auth成功数:";
    authSuccessedLable.textColor = [UIColor grayColor];
    authSuccessedLable.font = [UIFont systemFontOfSize:13];
    authSuccessedLable.textAlignment = NSTextAlignmentLeft;
    [_headerContentView addSubview:authSuccessedLable];
    [authSuccessedLable mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.mas_equalTo(self.view).mas_offset(10);
           make.top.mas_equalTo(testLable.mas_bottom).mas_offset(2);
           make.width.mas_equalTo(90);
           make.height.mas_equalTo(15);
    }];
    
    _authSuccessedCountLable = [[UILabel alloc] init];
    _authSuccessedCountLable.text = [@(_authSuccessedCount) stringValue];
    _authSuccessedCountLable.textColor = [UIColor blackColor];
    _authSuccessedCountLable.font = [UIFont systemFontOfSize:13];
    _authSuccessedCountLable.textAlignment = NSTextAlignmentLeft;
    [_headerContentView addSubview:_authSuccessedCountLable];
    [_authSuccessedCountLable mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.mas_equalTo(authSuccessedLable.mas_right).mas_offset(5);
           make.right.mas_equalTo(self.view).mas_offset(-60);
           make.centerY.mas_equalTo(authSuccessedLable.mas_centerY).mas_offset(2);
           make.height.mas_equalTo(15);
    }];
    
    UILabel *authFailedLable = [[UILabel alloc] init];
    authFailedLable.text = @"auth失败数:";
    authFailedLable.textColor = [UIColor grayColor];
    authFailedLable.font = [UIFont systemFontOfSize:13];
    authFailedLable.textAlignment = NSTextAlignmentLeft;
    [_headerContentView addSubview:authFailedLable];
    [authFailedLable mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.mas_equalTo(self.view).mas_offset(10);
           make.top.mas_equalTo(authSuccessedLable.mas_bottom).mas_offset(0);
           make.width.mas_equalTo(90);
           make.height.mas_equalTo(15);
    }];
    
    _authFailedCountLable = [[UILabel alloc] init];
    _authFailedCountLable.text = [@(_authFailedCount) stringValue];
    _authFailedCountLable.textColor = [UIColor blackColor];
    _authFailedCountLable.font = [UIFont systemFontOfSize:13];
    _authFailedCountLable.textAlignment = NSTextAlignmentLeft;
    [_headerContentView addSubview:_authFailedCountLable];
    [_authFailedCountLable mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.mas_equalTo(authFailedLable.mas_right).mas_offset(5);
           make.right.mas_equalTo(self.view).mas_offset(-60);
           make.centerY.mas_equalTo(authFailedLable.mas_centerY).mas_offset(0);
           make.height.mas_equalTo(15);
    }];
    
    UIButton *clearBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [clearBtn setTitle:@"清空" forState:UIControlStateNormal];
    [clearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clearBtn setBackgroundColor:[UIColor colorWithHex:0x41b6e6] forState:UIControlStateNormal];
    [clearBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    clearBtn.layer.cornerRadius = 3;
    [clearBtn addTarget:self action:@selector(clearAuthCount:) forControlEvents:UIControlEventTouchUpInside];
    [_headerContentView addSubview:clearBtn];
    [clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           make.right.mas_equalTo(self.view).mas_offset(-10);
           make.centerY.mas_equalTo(self.headerContentView).mas_offset(0);
           make.height.mas_equalTo(25);
           make.width.mas_equalTo(50);
    }];
    
    
}
- (void)clearAuthCount:(id)sender{
    _authSuccessedCount = 0;
    _authFailedCount = 0;
    _authSuccessedCountLable.text = @"0";
    _authFailedCountLable.text = @"0";
}
- (void)addConversation:(id)sender{
}

//判断是否跳转
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if ([tabBarController.tabBar.selectedItem.title isEqualToString:@"测试"]) {
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
    [self createHeaderContentView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self.view).mas_offset(0);
        make.bottom.mas_equalTo(self.view).mas_offset(0);
        make.top.mas_equalTo(self.headerContentView.mas_bottom).mas_offset(0);
    }];
    [self.dataDispatchSource addSemaphore];
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
    PhotonChatTestDataSource *dataSource = [[PhotonChatTestDataSource alloc] initWithItems:self.model.items];
    self.dataSource = dataSource;
    if(_firstLoadData){
        dispatch_semaphore_signal(_signa);
        _firstLoadData = NO;
    }
    
}
- (void)conversationChange:(PhotonIMConversationEvent)envent chatType:(PhotonIMChatType)chatType chatWith:(NSString *)chatWith{
    __weak typeof(self)weakSelf = self;
    dispatch_async(self.conversationChangeQueue, ^{
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
    if (!self.isAppeared) {
        self.needRefreshData  = YES;
        return;
    }
    switch (envent) {
        case PhotonIMConversationEventCreate:{
             [self.dataDispatchSource addSemaphore];
        }
            break;
        case PhotonIMConversationEventDelete:
            break;
        case PhotonIMConversationEventUpdate:{
            [self updateConversation:conversation chatType:chatType chatWith:chatWith];
        }
            break;
        default:
            break;
    }
}
- (void)imClientLogin:(id)client loginStatus:(PhotonIMLoginStatus)loginstatus{
    PhotonWeakSelf(self)
    [PhotonUtil runMainThread:^{
        [weakself _imClientLogin:client loginStatus:loginstatus];
    }];
}
- (void)_imClientLogin:(id)client loginStatus:(PhotonIMLoginStatus)loginstatus{
    switch (loginstatus) {
        case PhotonIMLoginStatusLogining:{
            
        }
            break;
        case PhotonIMLoginStatusLoginSucceed:{
            _authSuccessedCount++;
            self.authSuccessedCountLable.text = [NSString stringWithFormat:@"%@",@(_authSuccessedCount)];
        }
                  
            break;
        case PhotonIMLoginStatusLoginFailed:{
            _authFailedCount++;
            self.authFailedCountLable.text = [NSString stringWithFormat:@"%@",@(_authFailedCount)];
        }
            break;
            
        default:
            break;
    }
}

- (void)updateConversation:(PhotonIMConversation *)conversation chatType:(PhotonIMChatType)chatType chatWith:(NSString *)chatWith{
    PhotonChatTestItem *temp = nil;
    NSInteger index = -1;
    BOOL isToTop = NO;
    for (PhotonChatTestItem *item in self.model.items) {
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
    if (temp) {
        [self updateItem:temp];
    }
}


- (void)startRefreshConversations{
    if (_isRefreshing) {
           return;
       }
       _isRefreshing = YES;
    [self loadDataItems];
}

- (void)refreshData{
    [self startRefreshConversations];
}

#pragma mark --- 刷新数据 ------

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:[PhotonChatTestCell class]]) {
        PhotonChatTestCell *tempCell = (PhotonChatTestCell *)cell;
        tempCell.delegate = self;
    }
    
}

- (PhotonChatData *)chatData:(PhotonIMConversation *)conversation{
    NSString *key = [NSString stringWithFormat:@"%@_%@",@(conversation.chatType),conversation.chatWith];
    PhotonChatData *chatData = [self.chatDataCache objectForKey:key defaultValue:nil];
    return chatData;
}

- (void)setChatData:(PhotonChatData *)chatData conversation:(PhotonIMConversation *)conversation{
    NSString *key = [NSString stringWithFormat:@"%@_%@",@(conversation.chatType),conversation.chatWith];
    if (!chatData) {
        [self.chatDataCache removeObjectForKey:key];
        return;
    }
    [self.chatDataCache setObject:chatData forKey:key];
}
- (void)chatStart:(PhotonChatTestItem *)item{
    PhotonIMConversation *conversation = item.userInfo;
    PhotonChatData *chatData = [self chatData:conversation];
    if (chatData.toStart) {
        return;
    }
    chatData.toStart = YES;
    [self _chatStart:item];
}
- (void)_chatStart:(PhotonChatTestItem *)item{
      PhotonIMConversation *conversation = item.userInfo;
    PhotonWeakSelf(self);
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          PhotonChatData *chatData = [weakself chatData:conversation];
          if (!chatData && !chatData.toStart) {
              return;
          }
           NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970] * 1000.0;
          int index =  0;
          while (index < chatData.totalMsgCount && chatData.toStart) {
              chatData.sendedMessageCount ++;
              index ++;
              [NSThread sleepForTimeInterval:chatData.msgInterval/1000.0];
              NSString *sendText = [NSString stringWithFormat:@"%@-%@",chatData.sendContent,@(index)];
              [[PhotonMessageCenter sharedCenter] sendTex:sendText conversation:conversation completion:^(BOOL succeed, PhotonIMError * _Nullable error) {
                   if (succeed) {
                       chatData.sendedSuccessedCount ++;
                    }else{
                        chatData.sendedFailedCount ++;
                    }
                  if ( chatData.sendedSuccessedCount + chatData.sendedFailedCount == chatData.totalMsgCount) {
                      chatData.toStart = NO;
                  }
                  if (!chatData.toStart){
                      NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970] * 1000.0;
                      int duration = endTime - startTime;
                      chatData.totalTime = duration;
                      chatData.toStart = NO;
                      item.isStartChat = NO;
                      [weakself updateItem:item];
                     }
                     
                  if ([conversation.chatWith isEqualToString:weakself.currentConversation.chatWith]) {
                      [weakself setTestContent:chatData];
                  }
              }];
          }
      });
}

- (void)stopChat:(PhotonIMConversation *)caversation{
    PhotonChatData *chatData = [self chatData:caversation];
    chatData.toStart = NO;
}



- (void)startChatCell:(PhotonTableViewCell *)cell startChat:(PhotonChatTestItem *)chatItem{
    if (chatItem.isStartChat) {
        [self clearChatCell:nil clearData:chatItem];
        [self chatStart:chatItem];
    }else{
        [self stopChat:chatItem.userInfo];
    }
}

- (void)clearChatCell:(nullable PhotonTableViewCell *)cell clearData:(PhotonChatTestItem *)chatItem{
    PhotonChatData *chatData = [self chatData:chatItem.userInfo];
    [chatData resetRecord];
    [self setChatData:chatData conversation:chatItem.userInfo];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.model.items.count) {
        PhotonChatTestItem *item = [[self.model.items objectAtIndex:indexPath.row] isNil];
        if (!item) {
            return;
        }
        _currentConversation = [item userInfo];
    }
     [[[UIApplication sharedApplication] keyWindow] addSubview:self.testUIView];
    [self addTextUI:_currentConversation];
    
}


- (void)addTextUI:(PhotonIMConversation *)conversation{
    [self.testUIView addSubview:self.contentFiled];
    [self.testUIView addSubview:self.countFiled];
    [self.testUIView addSubview:self.intervalFiled];
    [self.testUIView addSubview:self.totleSendCountLable];
    [self.testUIView addSubview:self.sendSucceedCountLable];
    [self.testUIView addSubview:self.sendFailedCountLable];
    [self.testUIView addSubview:self.totalTimeLable];
    [self.testUIView addSubview:self.authFiled];
    
    UILabel *title = [[UILabel alloc] init];
    _titleLable = title;
    title.numberOfLines = 1;
    title.text = @"";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:12];
    title.textColor = [UIColor whiteColor];
    title.backgroundColor = [UIColor grayColor];
    [self.testUIView addSubview:title];
    
    [self.testUIView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(90);
        make.bottom.mas_equalTo(-90);
    }];
    
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.and.right.mas_equalTo(0);
           make.top.mas_equalTo(0);
           make.height.mas_equalTo(20);
       }];
    
    [self.contentFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.top.mas_equalTo(title.mas_bottom).offset(2);
        make.height.mas_equalTo(40);
    }];
    
    [self.countFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.top.mas_equalTo(self.contentFiled.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(40);
    }];
    
    [self.intervalFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.top.mas_equalTo(self.countFiled.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(40);
    }];

    
    [self.totleSendCountLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.top.mas_equalTo(self.intervalFiled.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(40);
    }];
    [self.sendSucceedCountLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.top.mas_equalTo(self.totleSendCountLable.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(40);
    }];
    
    [self.sendFailedCountLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.top.mas_equalTo(self.sendSucceedCountLable.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(40);
    }];
    
    [self.totalTimeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.top.mas_equalTo(self.sendFailedCountLable.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(40);
    }];
    
    
    UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [setBtn setTitle:@"设置" forState:UIControlStateNormal];
    [setBtn setBackgroundColor:  [UIColor colorWithHex:0x41b6e6] forState:UIControlStateNormal];
    [setBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
     setBtn.layer.cornerRadius = 3;
    [setBtn addTarget:self action:@selector(setContent:) forControlEvents:UIControlEventTouchUpInside];
     [self.testUIView addSubview:setBtn];
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setBackgroundColor:  [UIColor colorWithHex:0x41b6e6] forState:UIControlStateNormal];
    [cancleBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
     cancleBtn.layer.cornerRadius = 3;
    [cancleBtn addTarget:self action:@selector(cancle:) forControlEvents:UIControlEventTouchUpInside];
    [self.testUIView addSubview:cancleBtn];
    
    [setBtn mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.mas_equalTo(self.testUIView).offset(20);
         make.top.mas_equalTo(self.totalTimeLable.mas_bottom).mas_offset(5);
         make.height.mas_equalTo(30);
         make.width.mas_equalTo(50);
    }];
    
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
         make.right.mas_equalTo(self.testUIView).offset(-20);
         make.top.mas_equalTo(self.totalTimeLable.mas_bottom).mas_offset(5);
         make.height.mas_equalTo(30);
         make.width.mas_equalTo(50);
    }];
    
    PhotonChatData *data = [self chatData:conversation];
    [self setTestContent:data];
}

- (void)setContent:(id)sender{
     PhotonChatData *data = [self chatData:self.currentConversation];
    if (!data) {
        data = [[PhotonChatData alloc] init];
    }
    data.sendContent = self.contentFiled.text;
    data.msgInterval = [self.intervalFiled.text intValue];
    data.totalMsgCount = [self.countFiled.text intValue];
    [self setChatData:data conversation:self.currentConversation];
    [self cancle:nil];
}

- (void)cancle:(id)sender{
    [self.testUIView removeFromSuperview];
    self.currentConversation = nil;
    self.contentFiled.text = @"测试内容";
    self.intervalFiled.text = nil;
    self.countFiled.text = nil;
}

- (void)setTestContent:(PhotonChatData *)chatData{
    self.titleLable.text = self.currentConversation.FName;
    if(!chatData){
        self.contentFiled.text = @"测试内容";
        self.intervalFiled.text = nil;
        self.countFiled.text =  nil;
        self.totleSendCountLable.text = [NSString stringWithFormat:@"已发送总条数:"];
        self.sendSucceedCountLable.text = [NSString stringWithFormat:@"发送成功条数:"];
        self.sendFailedCountLable.text = [NSString stringWithFormat:@"发送失败条数:"];
        self.totalTimeLable.text = [NSString stringWithFormat:@"总耗时:"];
        return;
    }
    
    self.contentFiled.text = [chatData sendContent];
    self.intervalFiled.text = [NSString stringWithFormat:@"%@",@([chatData msgInterval])];
    self.countFiled.text =  [NSString stringWithFormat:@"%@",@([chatData totalMsgCount])];
    self.totleSendCountLable.text = [NSString stringWithFormat:@"已发送总条数:%@",@([chatData sendedMessageCount])];
    self.sendSucceedCountLable.text = [NSString stringWithFormat:@"发送成功条数:%@",@([chatData sendedSuccessedCount])];
    self.sendFailedCountLable.text = [NSString stringWithFormat:@"发送失败条数:%@",@([chatData sendedFailedCount])];
    self.totalTimeLable.text = [NSString stringWithFormat:@"总耗时:%@",@([chatData totalTime])];
}

- (UIView *)testUIView{
    if (!_testUIView) {
        _testUIView= [[UIView alloc] init];
        _testUIView.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uigesture)];
        gesture.numberOfTapsRequired = 1;
        [_testUIView addGestureRecognizer:gesture];
    }
    return _testUIView;
}
- (void)uigesture{
    [self.countFiled resignFirstResponder];
    [self.contentFiled resignFirstResponder];
    [self.intervalFiled resignFirstResponder];
}
- (UITextField *)contentFiled{
    if (!_contentFiled) {
        _contentFiled = [[UITextField alloc] init];
        _contentFiled.keyboardType = UIKeyboardTypeDefault;
         _contentFiled.text = @"测试内容";
        _contentFiled.backgroundColor = [UIColor grayColor];
    }
    return _contentFiled;
}

- (UITextField *)intervalFiled{
    if (!_intervalFiled) {
        _intervalFiled = [[UITextField alloc] init];
        _intervalFiled.keyboardType = UIKeyboardTypeNumberPad;
        _intervalFiled.placeholder = @"时间间隔";
        _intervalFiled.backgroundColor = [UIColor grayColor];
    }
    return _intervalFiled;
}

- (UITextField *)countFiled{
    if (!_countFiled) {
        _countFiled = [[UITextField alloc] init];
        _countFiled.keyboardType = UIKeyboardTypeNumberPad;
        _countFiled.placeholder = @"发送总条数";
        _countFiled.backgroundColor = [UIColor grayColor];
    }
    return _countFiled;
}

- (UILabel *)totleSendCountLable{
    if (!_totleSendCountLable) {
        _totleSendCountLable = [[UILabel alloc] init];
        _totleSendCountLable.numberOfLines = 2;
        _totleSendCountLable.text = @"已发送总条数:";
        _totleSendCountLable.font = [UIFont systemFontOfSize:12];
        _totleSendCountLable.textColor = [UIColor whiteColor];
        _totleSendCountLable.backgroundColor = [UIColor grayColor];
    }
    return _totleSendCountLable;
}
- (UILabel *)sendSucceedCountLable{
    if (!_sendSucceedCountLable) {
        _sendSucceedCountLable = [[UILabel alloc] init];
        _sendSucceedCountLable.numberOfLines = 2;
        _sendSucceedCountLable.text = @"发送成功条数:";
         _sendSucceedCountLable.font = [UIFont systemFontOfSize:12];
        _sendSucceedCountLable.textColor = [UIColor whiteColor];
        _sendSucceedCountLable.backgroundColor = [UIColor grayColor];
    }
    return _sendSucceedCountLable;
}
- (UILabel *)sendFailedCountLable{
    if (!_sendFailedCountLable) {
        _sendFailedCountLable = [[UILabel alloc] init];
        _sendFailedCountLable.numberOfLines = 2;
        _sendFailedCountLable.text = @"发送失败条数:";
         _sendFailedCountLable.font = [UIFont systemFontOfSize:12];
        _sendFailedCountLable.textColor = [UIColor whiteColor];
        _sendFailedCountLable.backgroundColor = [UIColor grayColor];
    }
    return _sendFailedCountLable;
}

- (UILabel *)totalTimeLable{
    if (!_totalTimeLable) {
        _totalTimeLable = [[UILabel alloc] init];
        _totalTimeLable.numberOfLines = 2;
        _totalTimeLable.text = @"总耗时:";
        _totalTimeLable.font = [UIFont systemFontOfSize:12];
        _totalTimeLable.textColor = [UIColor whiteColor];
        _totalTimeLable.backgroundColor = [UIColor grayColor];
    }
    return _totalTimeLable;
}

@end
