//
//  PhotonFriendDetailViewController.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/2.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonFriendDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PhotonChatViewController.h"
@interface PhotonFriendDetailViewController ()
@property (nonatomic, strong, nullable) PhotonUser *user;
@property (nonatomic, strong, nullable) UIView *backView;
@property (nonatomic, strong, nullable) UIImageView *avatarView;
@property (nonatomic, strong, nullable) UILabel *nickNameLabel;
@property (nonatomic, strong, nullable) UILabel *userIDLabel;

@property (nonatomic, strong, nullable) UIButton *sendMsgBtn;
@end

@implementation PhotonFriendDetailViewController
- (instancetype)initWithFriend:(PhotonUser *)user{
    self = [super init];
    if (self) {
        _user = user;
    }
    return self;
}
- (instancetype)initWithUserid:(NSString *)userid{
    self = [super init];
    if (self) {
        _user = [PhotonContent friendDetailInfo:userid];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xF3F3F3];
    if ([_user.avatarURL isNotEmpty]) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:_user.avatarURL]];
    }
    if ([_user.nickName isNotEmpty]) {
        self.nickNameLabel.text = [NSString stringWithFormat:@"昵称: %@",_user.nickName];
    }else{
        self.nickNameLabel.text = [NSString stringWithFormat:@"昵称: 未设置"];
    }
    
    self.userIDLabel.text = [NSString stringWithFormat:@"账号: %@",_user.userID];
    
    [self.view addSubview:self.backView];
    [self.view addSubview:self.sendMsgBtn];
    [self.backView addSubview:self.avatarView];
    [self.backView addSubview:self.nickNameLabel];
    [self.backView addSubview:self.userIDLabel];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(NavAndStatusHight);
        make.height.mas_equalTo(100);
    }];
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(64, 64));
        make.left.mas_equalTo(self.backView).mas_offset(15);
        make.centerY.mas_equalTo(self.backView);;
    }];
    
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.avatarView.mas_right).mas_offset(15);
        make.bottom.mas_equalTo(self.avatarView.mas_centerY).offset(-2);
    }];
    
    [self.userIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.avatarView.mas_right).mas_offset(15);
        make.top.mas_equalTo(self.avatarView.mas_centerY).offset(2);
    }];
    
    
    [self.sendMsgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.left.mas_equalTo(self.view).mas_offset(0);
        make.right.mas_equalTo(self.view).mas_offset(0);
        make.top.mas_equalTo(self.backView.mas_bottom).mas_offset(12.5);
    }];
}

- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor whiteColor];
    }
    return _backView;
}

- (UIImageView *)avatarView{
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.backgroundColor = [UIColor clearColor];
        _avatarView.clipsToBounds = YES;
        _avatarView.layer.cornerRadius = 5.0;
    }
    return _avatarView;
}

- (UILabel *)nickNameLabel{
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        _nickNameLabel.textColor = [UIColor blackColor];
        _nickNameLabel.backgroundColor = [UIColor clearColor];
    }
    return _nickNameLabel;
}

- (UILabel *)userIDLabel{
    if (!_userIDLabel) {
        _userIDLabel = [[UILabel alloc] init];
        _userIDLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        _userIDLabel.textColor = [UIColor blackColor];
        _userIDLabel.backgroundColor = [UIColor clearColor];
    }
    return _userIDLabel;
}

- (UIButton *)sendMsgBtn{
    if (!_sendMsgBtn) {
        _sendMsgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendMsgBtn setTitle:@"发消息" forState:UIControlStateNormal];
        _sendMsgBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _sendMsgBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0];
        [_sendMsgBtn setTitleColor:[UIColor colorWithHex:0x00AB17] forState:UIControlStateNormal];
        [_sendMsgBtn setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendMsgBtn addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendMsgBtn;
}

- (void)sendMessage:(id)message{
    PhotonIMConversation *conversation = [[PhotonIMConversation alloc] init];
    conversation.chatWith = [_user userID];
    conversation.chatType = PhotonIMChatTypeSingle;
    conversation.FName = [_user nickName];
    conversation.FAvatarPath = [_user avatarURL];
    PhotonChatViewController *chatctl = [[PhotonChatViewController alloc] initWithConversation:conversation];
    [self.navigationController pushViewController:chatctl animated:YES];
}

@end
