//
//  PhotonGroupMemberListViewController.m
//  PhotonIM
//
//  Created by Bruce on 2019/9/24.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonAtMemberListViewController.h"
#import "PhotonMessageCenter.h"
#import "PhotonContacDataSource.h"
#import "PhotonGroupMemberListModel.h"
#import "PhotonEmptyTableItem.h"
#import "PhotonBaseContactItem.h"
#import "PhotonBaseContactCell.h"
#import "PhotonChatTransmitCell.h"
#import "PhotonChatTransmitItem.h"
#import "PhotonTitleTableItem.h"
#import "PhotonCharBar.h"
@interface PhotonAtMemberListViewController ()<PhotonChatTransmitCellDelegate>
@property (nonatomic, copy, nullable)NSString *gid;
@property (nonatomic, strong, nullable)UILabel   *tipLable;
@property (nonatomic, strong, nullable)UIButton  *okBtn;
@property (nonatomic, strong, nullable)NSMutableArray *selectedChats;
@property (nonatomic, strong, nullable)PhotonIMMessage *message;

@property (nonatomic, copy, nullable)PhotonAtMemberListBlock result;
@end

@implementation PhotonAtMemberListViewController
- (instancetype)initWithGid:(NSString *)gid result:(PhotonAtMemberListBlock)result{
    self = [super init];
    if (self) {
        self.model = [[PhotonGroupMemberListModel alloc] init];
        _gid = gid;
        _result = [result copy];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"选择提醒的人";
    [self.view setBackgroundColor:[UIColor colorWithHex:0xF3F3F3]];
    self.tableView.backgroundColor = [UIColor colorWithHex:0xF3F3F3];
    
    _tipLable = [[UILabel alloc] init];
    _tipLable.textColor = [UIColor colorWithHex:0x4B4B4B];
    _tipLable.backgroundColor = [UIColor clearColor];
    _tipLable.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.0f];
    self.tipLable.text = [NSString stringWithFormat:@"已选择：%@个",@(0)];
    [self.view addSubview:_tipLable];
    
    [_tipLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).mas_offset(-SAFEAREA_INSETS_BOTTOM - 10);
        make.left.mas_equalTo(self.view).mas_offset(19);
        make.right.mas_equalTo(self.view).mas_offset(-150);
    }];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.okBtn = okBtn;
    [okBtn setTitle:@"确定" forState:UIControlStateNormal];
    okBtn.userInteractionEnabled = YES;
    [okBtn setBackgroundColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [okBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15]];
    [okBtn addTarget:self action:@selector(okAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okBtn];
    
    [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).mas_offset(-SAFEAREA_INSETS_BOTTOM - 10);
        make.right.mas_equalTo(self.view).mas_offset(-11);
        make.size.mas_equalTo(CGSizeMake(68.0, 32.5));
    }];
    
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.mas_equalTo(self.view).mas_equalTo(0);
        make.bottom.mas_equalTo(okBtn.mas_top).mas_equalTo(- 13);
    }];
    [self loadDataItems];
}

- (void)loadDataItems{
    
    PhotonWeakSelf(self);
    if (![self.gid isNotEmpty]) {
        return;
    }
    ((PhotonGroupMemberListModel *)self.model).gid = self.gid;
  
    [self.model loadItems:nil finish:^(NSDictionary * _Nullable dict) {
        [weakself loadData];
    } failure:^(PhotonErrorDescription * _Nullable error) {
         [weakself loadData];
    }];
    
}
- (void)loadData{
    if(self.model.items.count > 0){
        PhotonTitleTableItem *allItem = [[PhotonTitleTableItem alloc]init];
        allItem.title = [NSString stringWithFormat:@"所有人(%@)",@(self.model.items.count)];
        allItem.itemHeight = 70.0;
        [self.model.items insertObject:allItem atIndex:0];
    }
        
    PhotonContacDataSource *dataSource = [[PhotonContacDataSource alloc] initWithItems:self.model.items];
    self.dataSource = dataSource;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:[PhotonChatTransmitCell class]]) {
        PhotonChatTransmitCell *tempCell = (PhotonChatTransmitCell *)cell;
        tempCell.delegate = self;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.model.items.count) {
        id item = [self.model.items objectAtIndex:indexPath.row];
        if ([item isKindOfClass:[PhotonTitleTableItem class]]) {
            if (self.result) {
                NSMutableArray *resultItems = [NSMutableArray arrayWithCapacity:1];
                PhotonChatAtInfo *atInfo = [[PhotonChatAtInfo alloc] init];
                atInfo.userid = @"";
                atInfo.nickName = @"@所有人 ";
                atInfo.atType = AtTypeAtAll;
                [resultItems addObject:atInfo];
                if (self.result) {
                    self.result(2, [resultItems copy]);
                }
            }
             [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(void)cell:(id)cell selectedItem:(id)item{
    if ([item isKindOfClass:[PhotonChatTransmitItem class]]) {
        PhotonChatTransmitItem *tempItem = (PhotonChatTransmitItem *)item;
        if (tempItem.selected) {
            if(![self.selectedChats containsObject:tempItem.userInfo]){
                [self.selectedChats addObject:tempItem.userInfo];
            }
        }else{
            if([self.selectedChats containsObject:tempItem.userInfo]){
                [self.selectedChats removeObject:tempItem.userInfo];
            }
        }
    }
    if(self.selectedChats.count){
        self.okBtn.userInteractionEnabled = YES;
        [self.okBtn setBackgroundColor:[UIColor colorWithHex:0x02A33D] forState:UIControlStateNormal];
    }else{
        self.okBtn.userInteractionEnabled = NO;
        [self.okBtn setBackgroundColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    self.tipLable.text = [NSString stringWithFormat:@"已选择：%@个",@(self.selectedChats.count)];
}

- (void)okAction:(UIButton *)sender{
    if (self.selectedChats.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    NSMutableArray *resultItems = [NSMutableArray arrayWithCapacity:self.selectedChats.count];
    NSInteger index = 0;
    for (PhotonUser *user in self.selectedChats) {
        NSString *userID = user.userID;
        NSString *nickName = nil;
        nickName = [NSString stringWithFormat:@"@%@ ",user.nickName];
        PhotonChatAtInfo *atInfo = [[PhotonChatAtInfo alloc] init];
        atInfo.userid = userID;
        atInfo.nickName = nickName;
        atInfo.atType = AtTypeAtMember;
        [resultItems addObject:atInfo];
        index ++;
    }
    if (self.result) {
        self.result(1, [resultItems copy]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableArray *)selectedChats{
    if (!_selectedChats) {
        _selectedChats = [NSMutableArray array];
    }
    return _selectedChats;
}
@end
