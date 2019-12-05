//
//  PhotonChatViewController.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonChatViewController.h"
#import <MMFoundation/MMFoundation.h>
#import "PhotonBaseViewController+Refresh.h"
#import "PhotonMessageCenter.h"
#import "PhotonSingleSettingViewController.h"
#import "PhotonGroupSettingViewController.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
@interface PhotonChatViewController ()
@property(nonatomic,strong,nullable)PhotonChatPanelManager *panelManager;
@property(nonatomic,strong,nullable)PhotonCharBar *chatBar;
@property(nonatomic,strong,nullable)PhotonMenuView *menuView;

@property(nonatomic, strong, nullable)PhotonIMConversation *conversation;

@property (nonatomic, strong, nullable)MFDispatchSource  *dataDispatchSource;

@property (nonatomic, assign)BOOL isFirstPage;
@property (nonatomic, strong,nullable)UIView  *testUIView;
// 内容
@property (nonatomic, strong,nullable)UITextField  *contentFiled;
// 间隔放松的时间
@property (nonatomic, strong,nullable)UITextField  *intervalFiled;
// 间隔放松的时间
@property (nonatomic, strong,nullable)UITextField  *countFiled;
//发送按钮
@property (nonatomic, strong,nullable)UIButton  *autoSendMessage;
//发送按钮
@property (nonatomic, strong,nullable)UIButton  *stopSendMessage;
//发送按钮
@property (nonatomic, copy,nullable)NSString  *content;
// login内容
@property (nonatomic, strong,nullable)UILabel  *authFiled;
@property (nonatomic, assign)NSTimeInterval  interval;
@property (atomic, assign)BOOL  isStop;
@property (nonatomic, assign)NSInteger authSucceedCount;
@property (nonatomic, assign)NSInteger authFaileddCount;
@property (atomic, assign)BOOL scrollTop;
@end

@implementation PhotonChatViewController
- (instancetype)initWithConversation:(nullable PhotonIMConversation *)conversation{
    self = [self init];
    if (self) {
        _conversation = conversation;
        _panelManager = [[PhotonChatPanelManager alloc] initWithIdentifier:conversation.chatWith];
        _panelManager.delegate = self;
        
        _dataDispatchSource = [MFDispatchSource sourceWithDelegate:self type:refreshType_Data dataQueue:dispatch_queue_create("com.cosmos.PhotonIM.chatdata", DISPATCH_QUEUE_SERIAL)];
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[PhotonMessageCenter sharedCenter] removeObserver:self];
    [self.tableView removeObserver:self forKeyPath:@"bounds"];
    [PhotonUtil resetLastShowTimestamp];
    [_dataDispatchSource clearDelegateAndCancel];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.model = [[PhotonChatModel alloc] init];
        self.items = [NSMutableArray array];
        [self.tableView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _authSucceedCount = 0;
    _authFaileddCount = 0;
    [self addRightBarItem];
    self.title = _conversation.FName;
    self.isStop = YES;
    [self.view setBackgroundColor:[UIColor colorWithHex:0XF3F3F3]];
    [self.tableView setBackgroundColor:[UIColor colorWithHex:0XF3F3F3]];
    
    [self addRefreshHeader];
    [_panelManager addChatPanelWithSuperView:self.view];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).mas_offset(0);
        make.bottom.mas_equalTo(self.chatBar.mas_top).mas_equalTo(0);
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.tableView addGestureRecognizer:tap];
    
    [self startLoadData];
    
    [self addTextUI];
    // 添加接收消息的监听
    [[PhotonMessageCenter sharedCenter] addObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)addRightBarItem{
    UIImage *image = [[UIImage imageNamed:@"nav_more"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(more)];
    self.navigationItem.rightBarButtonItem = back;
}

- (void)more{
    if (self.conversation.chatType == PhotonIMChatTypeSingle) {
        PhotonSingleSettingViewController *msgSetting = [[PhotonSingleSettingViewController alloc] initWithConversation:self.conversation];
        [self.navigationController pushViewController:msgSetting animated:YES];
    }else if (self.conversation.chatType == PhotonIMChatTypeGroup){
        PhotonGroupSettingViewController *msgSetting = [[PhotonGroupSettingViewController alloc] initWithGroupID:self.conversation];
        [self.navigationController pushViewController:msgSetting animated:YES];
    }
   
}
- (void)tapGesture:(id)gesture{
     [_panelManager dismissKeyboard];
     [self.menuView dismiss];
}

- (void)viewDidDisappear:(BOOL)animated{
    [_panelManager dismissKeyboard];
    self.isStop = YES;
   
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[PhotonAudioPlayer sharedAudioPlayer] stopPlayingAudio];
    
    //清空未读数
     [[PhotonMessageCenter sharedCenter] clearConversationUnReadCount:self.conversation];
}
// 加载数据
- (void)loadDataItems{
    [self p_loadDataItems];
}

- (void)p_loadDataItems{
    PhotonWeakSelf(self);
    BOOL isEmpty = (self.model.items.count == 0);
    [(PhotonChatModel *)self.model loadMoreMeesages:self.conversation.chatType chatWith:self.conversation.chatWith beforeAuthor:YES asc:YES finish:^(NSDictionary * _Nullable pa) {
        if (!isEmpty) {
            weakself.enableWithoutScrollToTop = YES;
        }else{
            weakself.enableWithoutScrollToTop = NO;
        }
        if(isEmpty){
            [weakself reloadData];
        }else{
             [weakself p_reloadData];
        }
       
    }];
}


- (void)p_reloadData{
    [self endRefreshing];
    PhotonChatDataSource *dataSource = [[PhotonChatDataSource alloc] initWithItems:self.model.items];
    dataSource.delegate = self;
    self.dataSource = dataSource;
}

#pragma mark ----- getter --------
- (PhotonCharBar *)chatBar{
    return [_panelManager chatBar];
}

- (PhotonMenuView *)menuView{
    if (!_menuView) {
        _menuView = [[PhotonMenuView alloc] init];
    }
    return _menuView;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self.tableView && [keyPath isEqualToString:@"bounds"]) {
        CGRect oldBounds, newBounds;
        [change[@"old"] getValue:&oldBounds];
        [change[@"new"] getValue:&newBounds];
        CGFloat t = oldBounds.size.height - newBounds.size.height;
        if (t > 0 && fabs(self.tableView.contentOffset.y + t + newBounds.size.height - self.tableView.contentSize.height) < 1.0) {
            [self scrollToBottomWithAnimation:NO];
        }
    }
}

#pragma mark ----- PhotonChatPanelDelegate -------
- (void)scrollToBottomWithAnimation:(BOOL)animation{
    PhotonWeakSelf(self);
    [PhotonUtil runMainThread:^{
        [weakself.tableView scrollToBottomWithAnimation:animation];
    }];
    
}
#pragma mark --- 刷新数据 ------
- (void)refreshTableView{
    [UIView animateWithDuration:0 animations:^{
        [self p_reloadData];
    } completion:^(BOOL finished) {
        [self scrollToBottomWithAnimation:self.isFirstPage];
        self.isFirstPage = YES;
    }];
}




#pragma mark ------ demo uitextView ----

- (void)addTextUI{
    return;
    [self.view addSubview:self.testUIView];
    [self.testUIView addSubview:self.contentFiled];
    [self.testUIView addSubview:self.countFiled];
    [self.testUIView addSubview:self.intervalFiled];
    [self.testUIView addSubview:self.autoSendMessage];
    [self.testUIView addSubview:self.totleSendCountLable];
    [self.testUIView addSubview:self.sendSucceedCountLable];
    [self.testUIView addSubview:self.sendFailedCountLable];
    [self.testUIView addSubview:self.totalTimeLable];
    [self.testUIView addSubview:self.authFiled];
    
    [self.testUIView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.top.mas_equalTo(90);
        make.bottom.mas_equalTo(-90);
        make.width.mas_equalTo(200);
    }];
    
    [self.contentFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
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

    [self.autoSendMessage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.top.mas_equalTo(self.intervalFiled.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(40);
    }];
    
    [self.totleSendCountLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.top.mas_equalTo(self.autoSendMessage.mas_bottom).mas_offset(5);
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
        make.height.mas_equalTo(20);
    }];
    
    [self.authFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.top.mas_equalTo(self.totalTimeLable.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(40);
    }];
}

- (UIView *)testUIView{
    if (!_testUIView) {
        _testUIView= [[UIView alloc] init];
        _testUIView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uigesture)];
        gesture.numberOfTapsRequired = 1;
        [_testUIView addGestureRecognizer:gesture];
    }
    return _testUIView;
}
- (UITextField *)contentFiled{
    if (!_contentFiled) {
        _contentFiled = [[UITextField alloc] init];
        _contentFiled.keyboardType = UIKeyboardTypeDefault;
         _contentFiled.text = @"测试";
        _contentFiled.backgroundColor = [UIColor grayColor];
    }
    return _contentFiled;
}

- (UITextField *)intervalFiled{
    if (!_intervalFiled) {
        _intervalFiled = [[UITextField alloc] init];
        _intervalFiled.keyboardType = UIKeyboardTypeNumberPad;
        _intervalFiled.text = @"1000";
        _intervalFiled.backgroundColor = [UIColor grayColor];
    }
    return _intervalFiled;
}

- (UITextField *)countFiled{
    if (!_countFiled) {
        _countFiled = [[UITextField alloc] init];
        _countFiled.keyboardType = UIKeyboardTypeNumberPad;
         _countFiled.text = @"100";
        _countFiled.backgroundColor = [UIColor grayColor];
    }
    return _countFiled;
}

- (UILabel *)totleSendCountLable{
    if (!_totleSendCountLable) {
        _totleSendCountLable = [[UILabel alloc] init];
        _totleSendCountLable.numberOfLines = 2;
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
        _totalTimeLable.font = [UIFont systemFontOfSize:12];
        _totalTimeLable.textColor = [UIColor whiteColor];
        _totalTimeLable.backgroundColor = [UIColor grayColor];
    }
    return _totalTimeLable;
}

- (UILabel *)authFiled{
    if (!_authFiled) {
        _authFiled = [[UILabel alloc] init];
        _authFiled.numberOfLines = 2;
        _authFiled.font = [UIFont systemFontOfSize:12];
        _authFiled.textColor = [UIColor whiteColor];
        _authFiled.backgroundColor = [UIColor grayColor];
    }
    return _authFiled;
}

- (UIButton *)autoSendMessage{
    if (!_autoSendMessage) {
        _autoSendMessage = [UIButton buttonWithType:UIButtonTypeCustom];
        [_autoSendMessage setTitle:@"开始" forState:UIControlStateNormal];
        _autoSendMessage.backgroundColor = [UIColor grayColor];
        [_autoSendMessage addTarget:self action:@selector(autoSendMessage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _autoSendMessage;
}

-(void)setTotleSendCount:(NSInteger)totleSendCount{
    _totleSendCount = totleSendCount;
     self.totleSendCountLable.text = [NSString stringWithFormat:@"发送数：%@",@(_totleSendCount)];
}

- (void)setSendSucceedCount:(NSInteger)sendSucceedCount{
    _sendSucceedCount = sendSucceedCount;
     self.sendSucceedCountLable.text = [NSString stringWithFormat:@"发送成功数：%@",@(_sendSucceedCount)];
}

- (void)setSendFailedCount:(NSInteger)sendFailedCount{
    _sendFailedCount = sendFailedCount;
    self.sendFailedCountLable.text = [NSString stringWithFormat:@"发送失败数：%@",@(_sendFailedCount)];
}

- (void)autoSendMessage:(UIButton *)sender{
    if(!self.isStop){
        self.isStop = YES;
        [sender setTitle:@"开始" forState:UIControlStateNormal];
       
        return;
    }
    [sender setTitle:@"停止" forState:UIControlStateNormal];
    self.sendSucceedCount = 0;
    self.sendFailedCount = 0;
    self.totleSendCount = 0;
    self.isStop = NO;
    self.content = self.contentFiled.text;
    self.count = [self.countFiled.text integerValue];
    self.interval = [self.intervalFiled.text integerValue]/1000.0;
    self.startTime = [[NSDate date] timeIntervalSince1970] * 1000.0;
    PhotonWeakSelf(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int index =  0;
        while (index < weakself.count && !weakself.isStop) {
            index ++;
            [NSThread sleepForTimeInterval:weakself.interval];
            [weakself sendTextMessage:[NSString stringWithFormat:@"%@-%@",self.content,@(index)] atItems:@[] type:0];
        }
    });
}

- (void)imClientLogin:(nonnull id)client loginStatus:(PhotonIMLoginStatus)loginstatus {
    BOOL change = NO;
    switch (loginstatus) {
        case PhotonIMLoginStatusLoginSucceed:
            self.authSucceedCount ++;
            change = YES;
            break;
        case PhotonIMLoginStatusLoginFailed:
            self.authFaileddCount ++;
            change = YES;
            break;
        case PhotonIMLoginStatusUnknow:
            self.authFaileddCount ++;
            change = YES;
            break;
                      
        default:
            break;
    }
    __weak typeof(self)weakself = self;
    [PhotonUtil runMainThread:^{
        if (change) {
            weakself.authFiled.text = [NSString stringWithFormat:@"authSucceedCount = %@ authFaileddCount =%@",@(weakself.authSucceedCount),@(weakself.authFaileddCount)];
        }
    }];
   
}


- (void)uigesture{
    [self.countFiled resignFirstResponder];
    [self.contentFiled resignFirstResponder];
    [self.intervalFiled resignFirstResponder];
}
@end
#pragma clang diagnostic pop
