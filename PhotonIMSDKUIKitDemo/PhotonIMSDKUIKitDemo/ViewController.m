//
//  ViewController.m
//  PhotonIMSDKUIKitDemo
//
//  Created by Bruce on 2019/8/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "ViewController.h"
#import "PhotonChatViewController.h"
#import "PhotonConversationListViewController.h"
#import "PhotonMessageCenter.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[PhotonMessageCenter sharedCenter] login];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 100);
    [btn setTitle:@"开始聊天" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(startChat1:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(100, 250, 100, 100);
    [btn1 setTitle:@"进入会话" forState:UIControlStateNormal];
    [btn1 setBackgroundColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(startChat2:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
   
    
    
}

- (IBAction)startChat1:(id)sender {
    // 创建一个会话
    PhotonIMConversation *conversation = [[PhotonIMConversation alloc] init];
    conversation.chatType = PhotonIMChatTypeSingle;
    conversation.chatWith = @"123456";
    [[PhotonIMClient sharedClient]saveConversation:conversation];
    PhotonChatViewController *chatVCL = [[PhotonChatViewController alloc] initWithConversation:conversation];
    [self.navigationController pushViewController:chatVCL animated:YES];
}

- (IBAction)startChat2:(id)sender {
    // 创建一个会话
    PhotonConversationListViewController *chatVCL = [[PhotonConversationListViewController alloc] init];
    [self.navigationController pushViewController:chatVCL animated:YES];
}

@end
