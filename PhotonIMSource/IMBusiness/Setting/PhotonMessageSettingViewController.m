//
//  PhotonMessageSettingViewController.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/31.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonMessageSettingViewController.h"
#import "PhotonMessageSettingItem.h"
#import "PhotonMessageSettingCell.h"
#import "PhotonNetworkService.h"
#import "PhotonContactItem.h"
#import "PhotonContactCell.h"
#import "PhotonEmptyTableItem.h"
@interface PhotonMessageSettingDataSource ()
@end

@implementation PhotonMessageSettingDataSource
- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object{
    if ([object isKindOfClass:[PhotonMessageSettingItem class]]) {
        return [PhotonMessageSettingCell class];
    }else if ([object isKindOfClass:[PhotonContactItem class]]){
        return [PhotonContactCell class];
    }
    return [super tableView:tableView cellClassForObject:object];
}
@end
@interface PhotonMessageSettingViewController ()<UITableViewDelegate,PhotonMessageSettingCellDelegate>
@property (nonatomic, weak, nullable)PhotonIMConversation *conversation;
@property (nonatomic, strong, nullable)PhotonNetworkService *netService;
@end

@implementation PhotonMessageSettingViewController

- (instancetype)initWithConversation:(PhotonIMConversation *)conversation{
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
    PhotonEmptyTableItem *emptyItem = [[PhotonEmptyTableItem alloc] init];
    emptyItem.itemHeight = 11;
    emptyItem.backgroudColor = [UIColor clearColor];
    [self.items addObject:emptyItem];
    
    PhotonContactItem *contactItem = [[PhotonContactItem alloc] init];
    contactItem.fNickName = self.conversation.FName?self.conversation.FName:self.conversation.chatWith;
    contactItem.fIcon = self.conversation.FAvatarPath;
    contactItem.itemHeight = 63;
    contactItem.userInfo = [PhotonContent friendDetailInfo:self.conversation.chatWith];
    [self.items addObject:contactItem];
    
    [self.items addObject:emptyItem];
    
    PhotonMessageSettingItem *settionItem = [[PhotonMessageSettingItem alloc] init];
    settionItem.settingName = @"消息免打扰";
    settionItem.open = _conversation.ignoreAlert;
    settionItem.type = PhotonMessageSettingTypeIgnoreAlert;
    [self.items addObject:settionItem];
    
    PhotonMessageSettingDataSource *dataSource = [[PhotonMessageSettingDataSource alloc] initWithItems:self.items];
    self.dataSource = dataSource;
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
            [[PhotonMessageCenter sharedCenter] updateConversationIgnoreAlert:_conversation];
        }
            break;
        case PhotonMessageSettingTypeIgnorSticky:{
            _conversation.sticky = item.open;
        }
            break;
            
        default:
            break;
    }
}

- (void)setIgnoreAlert:(BOOL)open{
    NSMutableDictionary *paramter = [NSMutableDictionary dictionary];
    [paramter setValue:self.conversation.chatWith forKey:@"remoteid"];
    [paramter setValue:@(open) forKey:@"switch"];
    [self.netService commonRequestMethod:PhotonRequestMethodPost queryString:@"photonimdemo/setting/msg/setP2pRemind" paramter:paramter completion:^(NSDictionary * _Nonnull dict) {
    } failure:^(PhotonErrorDescription * _Nonnull error) {
        [PhotonUtil showErrorHint:@"勿扰模式保存失败!"];
    }];
}
- (PhotonNetworkService *)netService{
    if (!_netService) {
        _netService = [[PhotonNetworkService alloc] init];
        _netService.baseUrl = PHOTON_BASE_URL;
        
    }
    return _netService;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
