//
//  PhotonCharBar.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotonMacros.h"
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface PhotonChatAtInfo : NSObject
@property (nonatomic,assign)AtType atType;
@property (nonatomic,copy)NSString *userid;
@property (nonatomic,copy)NSString *nickName;
@end

@class PhotonCharBar;
@protocol PhotonCharBarDelegate <NSObject>
/**
 *  chatBar状态改变
 */
- (void)chatBar:(PhotonCharBar *)chatBar changeStatusFrom:(PhotonChatBarStatus)fromStatus to:(PhotonChatBarStatus)toStatus;

/**
 *  输入框高度改变
 */
- (void)chatBar:(PhotonCharBar *)chatBar didChangeTextViewHeight:(CGFloat)height;

/**
 *  发送文字
 */
- (void)chatBar:(PhotonCharBar *)chatBar sendText:(NSString *)text;

// 录音控制

/**
 *  开始录音
 */
- (void)chatBarStartRecording:(PhotonCharBar *)chatBar;

/**
 * 将要结束录音
 */
- (void)chatBarWillCancelRecording:(PhotonCharBar *)chatBar cancel:(BOOL)cancel;

/**
 * 结束录音
 */
- (void)chatBarDidCancelRecording:(PhotonCharBar *)chatBar;

/**
 * 完成录音
 */
- (void)chatBarFinishedRecoding:(PhotonCharBar *)chatBar;


- (void)chatBarTextViewDidChange:(PhotonCharBar *)charBar;
@end

@interface PhotonCharBar : UIView
@property(nonatomic, weak)id<PhotonCharBarDelegate> delegate;
@property(nonatomic,assign)PhotonChatBarStatus status;
@property(nonatomic, copy, readonly,nullable) NSString *currentInputText;
@property(nonatomic, copy, readonly,nullable) NSString *currentText;
@property(nonatomic,assign)NSInteger maxTextWordCount;
@property (nonatomic, strong, readonly,nullable) UITextView *textView;
@property (nonatomic, assign) BOOL activity;
@property (nonatomic, copy) NSArray<PhotonChatAtInfo *>*atInfos;
@property (nonatomic, assign)AtType atType;

- (void)addEmojiString:(nullable NSString *)emojiString;

- (void)addAtContent:(NSString *)content;

- (void)sendCurrentText;

- (void)deleteLastCharacter;
@end

NS_ASSUME_NONNULL_END
