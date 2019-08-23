//
//  PhotonChatPanelManager.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/20.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonChatPanelManager.h"
#import <Photos/Photos.h>
#import <Masonry/Masonry.h>
#import "PhotonMoreKeyBoard.h"
#import "PhotonEmojiKeyboard.h"
#import "PhotonAudioRecorder.h"
#import "PhotonUtil.h"
#import "PhotonRecorderIndicator.h"
#import "PhotonMessageCenter.h"
@interface PhotonChatPanelManager()<PhotonCharBarDelegate,
PhotonBaseKeyBoardDelegate,
PhotonMoreKeyBoardDelegate,
PhotonEmojiKeyboardDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
PhotonAudioRecorderDelegate>
{
    PhotonChatBarStatus lastStatus;
    PhotonChatBarStatus curStatus;
}
@property(nonatomic,strong)UIView *view;
// chatBar
@property(nonatomic,strong,nullable)PhotonCharBar *chatBar;
// 更多面板
@property(nonatomic, strong, nullable)PhotonMoreKeyBoard *moreKeyboard;

// emoji面板
@property(nonatomic, strong, nullable)PhotonEmojiKeyboard *emojiKeyboard;

// 录音设备

@property(nonatomic, strong, nullable)PhotonAudioRecorder  *audioRecorder;


@property(nonatomic, strong, nullable)PhotonRecorderIndicator *recorderIndicatorView;

@property(nonatomic, copy, nullable)NSString *identifier;
@end
@implementation PhotonChatPanelManager
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)initWithIdentifier:(NSString *)identifier{
    self = [self init];
    if (self) {
        _identifier = identifier;
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (void)addChatPanelWithSuperView:(UIView *)superView{
     _view = superView;
     [self p_initPanel];
}

- (void)dismissKeyboard
{
    if (curStatus == PhotonChatBarStatusMore) {
        [self.moreKeyboard dismissWithAnimation:YES];
        curStatus = PhotonChatBarStatusInit;
    }
    if (curStatus == PhotonChatBarStatusEmoji) {
        [self.emojiKeyboard dismissWithAnimation:YES];
        curStatus = PhotonChatBarStatusInit;
    }
    [self.chatBar resignFirstResponder];
}


#pragma mark ------- private method -----------
- (void)p_initPanel{
    [self.view addSubview:self.chatBar];
    PhotonMoreKeyboardItem *imageItem = [PhotonMoreKeyboardItem createByType:PhotonMoreKeyboardItemTypeImage
                                                                       title:@"照片"
                                                                   imagePath:@"moreKB_image"];
    PhotonMoreKeyboardItem *cameraItem = [PhotonMoreKeyboardItem createByType:PhotonMoreKeyboardItemTypeCamera
                                                                        title:@"拍摄"
                                                                    imagePath:@"moreKB_capture"];
    [self.moreKeyboard setDelegate:self];
    [self.moreKeyboard setKeyboardDelegate:self];
    [self.emojiKeyboard setDelegate:self];
    [self.emojiKeyboard setKeyboardDelegate:self];
    
    [self.moreKeyboard setChatMoreKeyboardItems:[@[imageItem,cameraItem] mutableCopy]];
    [self.emojiKeyboard setChatEmojiKeyboardItems:nil];
    
    [self addMasonry];
}

- (void)addMasonry{    
    [self.chatBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).mas_offset(-SAFEAREA_INSETS_BOTTOM);
        make.height.mas_greaterThanOrEqualTo(54.5);
    }];
    [self.view layoutIfNeeded];
}

#pragma mark ----------- Getter ----------
- (PhotonCharBar *)chatBar{
    if (!_chatBar) {
        _chatBar = [[PhotonCharBar alloc]init];
        [_chatBar setDelegate:self];
    }
    return _chatBar;
}

- (PhotonMoreKeyBoard *)moreKeyboard{
    return [PhotonMoreKeyBoard sharedKeyBoard];
}

-(PhotonEmojiKeyboard *)emojiKeyboard{
    return [PhotonEmojiKeyboard sharedKeyBoard];
}

- (PhotonAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        _audioRecorder = [[PhotonAudioRecorder alloc] init];
        _audioRecorder.delegate = self;
    }
    return _audioRecorder;
}

- (PhotonRecorderIndicator *)recorderIndicatorView{
    if (!_recorderIndicatorView) {
        _recorderIndicatorView = [[PhotonRecorderIndicator alloc] init];
    }
    return _recorderIndicatorView;
}
#pragma mark --------- keyboard noti event ---
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (curStatus != PhotonChatBarStatusKeyboard) {
        return;
    }
    if (lastStatus == PhotonChatBarStatusMore) {
        [self.moreKeyboard dismissWithAnimation:NO];
    }
    else if (lastStatus == PhotonChatBarStatusEmoji) {
        [self.emojiKeyboard dismissWithAnimation:NO];
    }
    
    if ([self.delegate respondsToSelector:@selector(scrollToBottomWithAnimation:)]) {
        [self.delegate scrollToBottomWithAnimation:YES];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    if (curStatus != PhotonChatBarStatusKeyboard) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(scrollToBottomWithAnimation:)]) {
        [self.delegate scrollToBottomWithAnimation:YES];
    }
}

- (void)keyboardFrameWillChange:(NSNotification *)notification
{
    if (curStatus != PhotonChatBarStatusKeyboard && lastStatus != PhotonChatBarStatusKeyboard) {
        return;
    }
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (lastStatus == PhotonChatBarStatusMore || lastStatus == PhotonChatBarStatusEmoji) {
        if (keyboardFrame.size.height <= HEIGHT_CHAT_KEYBOARD) {
            return;
        }
    }
    else if (curStatus == PhotonChatBarStatusEmoji || curStatus == PhotonChatBarStatusMore) {
        return;
    }
    [self.chatBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).mas_offset(MIN(-keyboardFrame.size.height, -SAFEAREA_INSETS_BOTTOM));
    }];
    [self.view layoutIfNeeded];
    
    if ([self.delegate respondsToSelector:@selector(scrollToBottomWithAnimation:)]) {
        [self.delegate scrollToBottomWithAnimation:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (curStatus != PhotonChatBarStatusKeyboard && lastStatus != PhotonChatBarStatusKeyboard) {
        return;
    }
    if (curStatus == PhotonChatBarStatusEmoji || curStatus == PhotonChatBarStatusMore) {
        return;
    }
    [self.chatBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).mas_offset(-SAFEAREA_INSETS_BOTTOM);
    }];
    [self.view layoutIfNeeded];
}

#pragma mark ---- PhotonCharBarDelegate -------
- (void)chatBar:(PhotonCharBar *)chatBar changeStatusFrom:(PhotonChatBarStatus)fromStatus to:(PhotonChatBarStatus)toStatus{
    if (curStatus == toStatus) {
        return;
    }
    lastStatus = fromStatus;
    curStatus = toStatus;
    if (toStatus == PhotonChatBarStatusInit) {
        if (fromStatus == PhotonChatBarStatusMore) {
            [self.moreKeyboard dismissWithAnimation:YES];
        }
        else if (fromStatus == PhotonChatBarStatusEmoji) {
            [self.emojiKeyboard dismissWithAnimation:YES];
        }
    }
    else if (toStatus == PhotonChatBarStatusVoice) {
        if (fromStatus ==PhotonChatBarStatusMore) {
            [self.moreKeyboard dismissWithAnimation:YES];
        }
        else if (fromStatus == PhotonChatBarStatusEmoji) {
            [self.emojiKeyboard dismissWithAnimation:YES];
        }
    }
    else if (toStatus == PhotonChatBarStatusEmoji) {
        if (fromStatus ==PhotonChatBarStatusMore) {
            [self.moreKeyboard dismissWithAnimation:YES];
        }
            [self.emojiKeyboard showInView:self.view withAnimation:YES];
    }
    else if (toStatus == PhotonChatBarStatusMore) {
        if (fromStatus == PhotonChatBarStatusEmoji) {
            [self.emojiKeyboard dismissWithAnimation:YES];
        }
        [self.moreKeyboard showInView:self.view withAnimation:YES];
    }
}

- (void)chatBar:(PhotonCharBar *)chatBar didChangeTextViewHeight:(CGFloat)height{
    if ([self.delegate respondsToSelector:@selector(scrollToBottomWithAnimation:)]) {
        [self.delegate scrollToBottomWithAnimation:NO];
    }
}

// 发送
- (void)chatBar:(PhotonCharBar *)chatBar sendText:(NSString *)text{
    NSString *sendText = text.trim;
    if ([sendText length] == 0) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(sendTextMessage:)]) {
        [self.delegate sendTextMessage:text];
    }
}

#pragma mark ---------- 语音录制相关 ---------
// 开始录音
- (void)chatBarStartRecording:(PhotonCharBar *)chatBar{
    [self.audioRecorder startRecording];
    
    [self.recorderIndicatorView setStatus:PhotonRecorderStatusRecording];
    [self.view addSubview:self.recorderIndicatorView];
    [self.recorderIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(205, 205));
    }];
    
}

// 将要结束录音
- (void)chatBarWillCancelRecording:(PhotonCharBar *)chatBar cancel:(BOOL)cancel{
      [self.recorderIndicatorView setStatus:cancel ? PhotonRecorderStatusWillCancel : PhotonRecorderStatusRecording];
}

// 结束录音
- (void)chatBarDidCancelRecording:(PhotonCharBar *)chatBar{
    [self.audioRecorder cancleRecording];
    [self.recorderIndicatorView removeFromSuperview];
}

// 录音完成，发送
- (void)chatBarFinishedRecoding:(PhotonCharBar *)chatBar{
    [self.audioRecorder stopRecording];
}

#pragma mark --------- PhotonAudioRecorderDelegate ---
// 发送中，监控音量
- (void)audioRecorder:(nullable PhotonAudioRecorder *)recorder volume:(CGFloat)volume{
    NSLog(@"volume = %@",@(volume));
}
// 完成发送
- (void)finishAudioRecorder:(nullable PhotonAudioRecorder *)recorder time:(CGFloat)time{
    if (time < 1.0){
        // 录音时间较短，无法发送
        return;
    }
    [self.recorderIndicatorView removeFromSuperview];
    NSString *filePath = recorder.cachePath;
    NSLog(@"filePath = %@",filePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSString *fileName = [NSString stringWithFormat:@"%.0lf.opus", [NSDate date].timeIntervalSince1970 * 1000];
        NSString *path = [[PhotonMessageCenter sharedCenter] getVoiceFilePath:_identifier fileName:fileName];
        if (![path isNotEmpty]) {
            return;
        }
        NSError *error;
        [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:path error:&error];
        if (error) {
            return;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendVoiceMessage:duraion:)]) {
            [self.delegate sendVoiceMessage:fileName duraion:time];
        }
        
    }
}
// 取消发送
- (void)cancleAudioRecorder:(nullable PhotonAudioRecorder *)recorder{
   
}

// 录制时间太短
- (void)audioRecorderTimeTooShort:(PhotonAudioRecorder *)recorder{
     [self.recorderIndicatorView setStatus:PhotonRecorderStatusTooShort];
   
}
////////////


#pragma mark --------- PhotonBaseKeyBoardDelegate ---
-(void)chatKeyboardWillShow:(id)keyboard animated:(BOOL)animated{
    if ([self.delegate respondsToSelector:@selector(scrollToBottomWithAnimation:)]) {
        [self.delegate scrollToBottomWithAnimation:YES];
    }
}

- (void)chatKeyboardDidShow:(id)keyboard animated:(BOOL)animated{
    if ([self.delegate respondsToSelector:@selector(scrollToBottomWithAnimation:)]) {
        [self.delegate scrollToBottomWithAnimation:YES];
    }
}

- (void)chatKeyboardWillDismiss:(id)keyboard animated:(BOOL)animated{
    
}

- (void)chatKeyboardDidDismiss:(id)keyboard animated:(BOOL)animated{
    
}

- (void)chatKeyboard:(id)keyboard didChangeHeight:(CGFloat)height{
    [self.chatBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).mas_offset(MIN(-height, -SAFEAREA_INSETS_BOTTOM));
    }];
    [self.view layoutIfNeeded];
    
    if ([self.delegate respondsToSelector:@selector(scrollToBottomWithAnimation:)]) {
        [self.delegate scrollToBottomWithAnimation:YES];
    }
}

#pragma mark ---------- PhotonMoreKeyBoardDelegate -------
- (void)moreKeyboard:(id)keyboard didSelectedKeyboardItem:(PhotonMoreKeyboardItem *)item{
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    if (item.type == PhotonMoreKeyboardItemTypeCamera) {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        }
        else {
            return;
        }
    }
    else {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [imagePickerController setDelegate:self];
    
    [[self getCurrentVC] presentViewController:imagePickerController animated:YES completion:nil];
}

//MARK: UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        if (imageData && [self.delegate respondsToSelector:@selector(sendImageMessage:)]) {
            [self.delegate sendImageMessage:imageData];
        }
    }else{
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        PHAsset *imageAsset;
        if (@available(iOS 11.0, *)) {
            imageAsset = [info objectForKey:UIImagePickerControllerPHAsset];
        } else {
            NSURL *imageAssetUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
            if (imageAssetUrl) {
                PHFetchResult *results = [PHAsset fetchAssetsWithALAssetURLs:@[imageAssetUrl]
                                                                     options:nil];
                if (results.count) {
                    imageAsset = [results lastObject];
                }
            }
        }
        [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            if (imageData && [self.delegate respondsToSelector:@selector(sendImageMessage:)]) {
                [self.delegate sendImageMessage:imageData];
            }
        }];
    }
   
    
    
}


#pragma mark ---------- PhotonEmojiKeyboardDelegate -------
- (void)emojiKeyboardDidClickRemove:(PhotonEmojiKeyboard *)emojiView{
    [self.chatBar deleteLastCharacter];
}
- (void)emojiKeyboardDidClickSend:(PhotonEmojiKeyboard *)emojiView{
    [self.chatBar sendCurrentText];
}
- (void)emojiKeyboard:(PhotonEmojiKeyboard *)emojiView selectEmojiWithText:(NSString *)emojiText{
    [self.chatBar addEmojiString:emojiText];
}


- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    
    return currentVC;
}
- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        currentVC = rootVC;
    }
    return currentVC;
}
@end
