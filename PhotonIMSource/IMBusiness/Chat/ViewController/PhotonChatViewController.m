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
#import "PhotonMessageSettingViewController.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
@interface PhotonChatViewController ()
@property(nonatomic, strong, nullable)PhotonChatModel *model;
@property(nonatomic,strong,nullable)PhotonChatPanelManager *panelManager;
@property(nonatomic,strong,nullable)PhotonCharBar *chatBar;
@property(nonatomic,strong,nullable)PhotonMenuView *menuView;

@property(nonatomic, strong, nullable)PhotonIMConversation *conversation;

@property (nonatomic, strong, nullable)MFDispatchSource  *uiDispatchSource;
@property (nonatomic, strong, nullable)MFDispatchSource  *dataDispatchSource;

@property (nonatomic, assign)BOOL isFirstPage;
@end

@implementation PhotonChatViewController
- (instancetype)initWithConversation:(nullable PhotonIMConversation *)conversation{
    self = [self init];
    if (self) {
        _conversation = conversation;
        _panelManager = [[PhotonChatPanelManager alloc] initWithIdentifier:conversation.chatWith];
        _panelManager.delegate = self;
        
        _uiDispatchSource = [MFDispatchSource sourceWithDelegate:self type:refreshType_UI dataQueue:dispatch_get_main_queue()];
        _dataDispatchSource = [MFDispatchSource sourceWithDelegate:self type:refreshType_Data dataQueue:dispatch_get_main_queue()];
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[PhotonMessageCenter sharedCenter] removeObserver:self];
    [self.tableView removeObserver:self forKeyPath:@"bounds"];
    [PhotonUtil resetLastShowTimestamp];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.items = [NSMutableArray array];
        // 添加接收消息的监听
        [[PhotonMessageCenter sharedCenter] addObserver:self];
       
        [self.tableView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}


- (void)firstLoadMessages{
    [self loadDataItems];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addRightBarItem];
    self.title = _conversation.FName;
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
    [self firstLoadMessages];
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
    PhotonMessageSettingViewController *msgSetting = [[PhotonMessageSettingViewController alloc] initWithConversation:self.conversation];
    [self.navigationController pushViewController:msgSetting animated:YES];
}
- (void)tapGesture:(id)gesture{
     [_panelManager dismissKeyboard];
     [self.menuView dismiss];
}

- (void)viewDidDisappear:(BOOL)animated{
    [_panelManager dismissKeyboard];
   
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[PhotonAudioPlayer sharedAudioPlayer] stopPlayingAudio];
    
    //清空未读数
     [[PhotonMessageCenter sharedCenter] clearConversationUnReadCount:self.conversation];
}
// 加载数据
- (void)loadDataItems{
    [self.dataDispatchSource addSemaphore];
}

- (void)p_loadDataItems{
    PhotonWeakSelf(self);
    BOOL isEmpty = (self.model.items.count == 0);
    [self.model loadMoreMeesages:self.conversation.chatType chatWith:self.conversation.chatWith beforeAuthor:YES asc:YES finish:^(NSDictionary * _Nullable pa) {
        if (!isEmpty) {
            weakself.enableWithoutScrollToTop = YES;
        }else{
            weakself.enableWithoutScrollToTop = NO;
        }
        if(isEmpty){
            [weakself.uiDispatchSource addSemaphore];
        }else{
             [weakself p_reloadData];
        }
       
    }];
}

- (void)reloadData{
    [self.uiDispatchSource addSemaphore];
  
}

- (void)p_reloadData{
    if (!self.model.items.count) {
        return;
    }
    // 刷新数据
    PhotonChatDataSource *dataSource = [[PhotonChatDataSource alloc] initWithItems:self.model.items];
    dataSource.delegate = self;
    self.dataSource = dataSource;
    [self endRefreshing];
}

#pragma mark ----- getter --------
- (PhotonChatModel *)model{
    if (!_model) {
        _model = [[PhotonChatModel alloc] init];
    }
    return _model;
}
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
    [self.tableView scrollToBottomWithAnimation:animation];
}
#pragma mark --- 刷新数据 ------
- (void)refreshUI{
    [UIView animateWithDuration:0 animations:^{
        [self p_reloadData];
    } completion:^(BOOL finished) {
        [self scrollToBottomWithAnimation:self.isFirstPage];
        self.isFirstPage = YES;
    }];
}

- (void)refreshData{
    [self p_loadDataItems];
}
@end
#pragma clang diagnostic pop
