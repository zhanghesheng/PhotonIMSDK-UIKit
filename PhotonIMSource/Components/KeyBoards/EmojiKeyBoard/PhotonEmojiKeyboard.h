//
//  PhotonEmojiKeyBoard.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/20.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotonBaseKeyBoard.h"
NS_ASSUME_NONNULL_BEGIN
@class PhotonEmojiKeyboard;

@protocol PhotonEmojiKeyboardDelegate <NSObject>
@optional
- (void)emojiKeyboardDidClickRemove:(PhotonEmojiKeyboard *)emojiView;
- (void)emojiKeyboardDidClickSend:(PhotonEmojiKeyboard *)emojiView;
- (void)emojiKeyboard:(PhotonEmojiKeyboard *)emojiView selectEmojiWithText:(NSString *)emojiText;
@end
@interface PhotonEmojiKeyboard : PhotonBaseKeyBoard
@property(nonatomic,weak,nullable)id<PhotonEmojiKeyboardDelegate> delegate;
@property (nonatomic,copy,nullable) NSArray *chatEmojiKeyboardItems;
+ (instancetype)sharedKeyBoard;
@end

NS_ASSUME_NONNULL_END
