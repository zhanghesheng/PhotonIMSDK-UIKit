//
//  PhotonChatTransmitListViewController.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/31.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonChatTransmitListViewController.h"
#import "PhotonMessageCenter.h"
#import "PhotonChatTransmitModel.h"
#import "PhotonEmptyTableItem.h"
#import "PhotonContactItem.h"
#import "PhotonContactCell.h"
#import "PhotonChatTransmitCell.h"
#import "PhotonChatTransmitItem.h"
@interface PhotonChatTransmitListDataSource ()
@end

@implementation PhotonChatTransmitListDataSource
- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object{
    if ([object isKindOfClass:[PhotonChatTransmitItem class]]){
        return [PhotonChatTransmitCell class];
    }
    return [super tableView:tableView cellClassForObject:object];
}
@end
@interface PhotonChatTransmitListViewController ()<PhotonChatTransmitCellDelegate>
@property (nonatomic, strong, nullable)PhotonChatTransmitModel *model;
@property (nonatomic, strong, nullable)UILabel   *tipLable;
@property (nonatomic, strong, nullable)UIButton  *okBtn;
@property (nonatomic, strong, nullable)NSMutableArray *selectedChats;
@property (nonatomic, strong, nullable)PhotonIMMessage *message;
@property (nonatomic, copy)ChatTransmitBlock chatBlock;
@end

@implementation PhotonChatTransmitListViewController
- (instancetype)initWithMessage:(PhotonIMMessage *)message block:(nullable ChatTransmitBlock)chatBlock{
    self = [super init];
    if (self) {
        _message = message;
        _chatBlock = [chatBlock copy];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"选择联系人";
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
    [self.model loadItems:nil finish:^(NSDictionary * _Nullable dict) {
        [weakself loadData];
    } failure:^(PhotonErrorDescription * _Nullable error) {
        
    }];
   
}
- (void)loadData{
    PhotonChatTransmitListDataSource *dataSource = [[PhotonChatTransmitListDataSource alloc] initWithItems:self.model.items];
    self.dataSource = dataSource;
}
- (PhotonChatTransmitModel *)model{
    if (!_model) {
        _model = [[PhotonChatTransmitModel alloc] init];
    }
    return _model;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell isKindOfClass:[PhotonChatTransmitCell class]]) {
        PhotonChatTransmitCell *tempCell = (PhotonChatTransmitCell *)cell;
        tempCell.delegate = self;
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
    for (PhotonIMConversation *conversation in self.selectedChats) {
        if([self.message.chatWith isEqualToString:conversation.chatWith]){// 当前会话的消息转发到了当前的会话
            if (self.chatBlock) {
                self.chatBlock(self.message);
            }
        }
        [[PhotonMessageCenter sharedCenter] transmitMessage:self.message conversation:conversation completion:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableArray *)selectedChats{
    if (!_selectedChats) {
        _selectedChats = [NSMutableArray array];
    }
    return _selectedChats;
}

#pragma mark ---- getter ----
@end
