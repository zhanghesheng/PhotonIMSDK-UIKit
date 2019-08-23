//
//  PhotonCharBar.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonCharBar.h"
#import "PontonTalkButton.h"
#import <Masonry/Masonry.h>
#import "PhotonMacros.h"
@interface PhotonCharBar()<UITextViewDelegate>{
    UIImage *kVoiceImage;
    UIImage *kVoiceImageHL;
    UIImage *kEmojiImage;
    UIImage *kEmojiImageHL;
    UIImage *kMoreImage;
    UIImage *kMoreImageHL;
    UIImage *kKeyboardImage;
    UIImage *kKeyboardImageHL;
}
@property (nonatomic, strong, nullable) UIButton *modeButton;
@property (nonatomic, strong, nullable) UIButton *voiceButton;
@property (nonatomic, strong, nullable) UITextView *textView;
@property (nonatomic, strong, nullable) UILabel    *textViewLabel;
@property (nonatomic, strong, nullable) PontonTalkButton *talkButton;
@property (nonatomic, strong, nullable) UIButton *emojiButton;
@property (nonatomic, strong, nullable) UIButton *moreButton;

@end

@implementation PhotonCharBar
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithHex:0xFFFFFF]];
        _maxTextWordCount = 480;
        [self p_initImage];

        [self addSubview:self.modeButton];
        [self addSubview:self.voiceButton];
        [self addSubview:self.textView];
        [self.textView addSubview:self.textViewLabel];
        [self addSubview:self.talkButton];
        [self addSubview:self.emojiButton];
        [self addSubview:self.moreButton];
        
        [self p_addMasonry];
        self.status = PhotonChatBarStatusInit;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}


#pragma mark - Public Methods
- (void)sendCurrentText
{
    if (self.textView.text.length > 0) {     // send Text
        if (_delegate && [_delegate respondsToSelector:@selector(chatBar:sendText:)]) {
            [_delegate chatBar:self sendText:self.textView.text];
        }
    }
    [self.textView setText:@""];
    [self hiddentTextViewLabel];
    [self p_reloadTextViewWithAnimation:YES];
}

- (void)addEmojiString:(NSString *)emojiString
{
    NSString *str = [NSString stringWithFormat:@"%@%@", self.textView.text, emojiString];
     NSInteger length = [self getTextLength:self.textView.text];
    if (length > _maxTextWordCount) {
        return;
    }
    [self.textView setText:str];
    [self hiddentTextViewLabel];
    [self p_reloadTextViewWithAnimation:YES];
    
}

- (void)deleteLastCharacter
{
    if([self textView:self.textView shouldChangeTextInRange:NSMakeRange(self.textView.text.length - 1, 1) replacementText:@""]){
        [self.textView deleteBackward];
    }
    [self hiddentTextViewLabel];
}

- (void)setActivity:(BOOL)activity
{
    _activity = activity;
    if (activity) {
        [self.textView setTextColor:[UIColor blackColor]];
    }
    else {
        [self.textView setTextColor:[UIColor grayColor]];
    }
}

- (BOOL)isFirstResponder
{
    if (self.status == PhotonChatBarStatusEmoji || self.status == PhotonChatBarStatusKeyboard || self.status == PhotonChatBarStatusMore) {
        return YES;
    }
    return NO;
}

- (BOOL)resignFirstResponder
{
    [self.moreButton setImage:kMoreImage imageHighlight:kMoreImageHL];
    [self.emojiButton setImage:kEmojiImage imageHighlight:kEmojiImageHL];
    if (self.status == PhotonChatBarStatusKeyboard) {
        [self.textView resignFirstResponder];
        self.status = PhotonChatBarStatusInit;
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:changeStatusFrom:to:)]) {
            [self.delegate chatBar:self changeStatusFrom:self.status to:PhotonChatBarStatusInit];
        }
    }
    return [super resignFirstResponder];
}


#pragma mark -------- text field delegate ----------
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [self setActivity:YES];
    if (self.status != PhotonChatBarStatusKeyboard) {
        if (_delegate && [_delegate respondsToSelector:@selector(chatBar:changeStatusFrom:to:)]) {
            [self.delegate chatBar:self changeStatusFrom:self.status to:PhotonChatBarStatusKeyboard];
        }
        if (self.status == PhotonChatBarStatusEmoji) {
            [self.emojiButton setImage:kEmojiImage imageHighlight:kEmojiImageHL];
        }
        else if (self.status == PhotonChatBarStatusMore) {
            [self.moreButton setImage:kMoreImage imageHighlight:kMoreImageHL];
        }
        self.status = PhotonChatBarStatusKeyboard;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self sendCurrentText];
        return NO;
    }else if (textView.text.length > 0 && [text isEqualToString:@""]){
        if ([textView.text characterAtIndex:range.location] == ']') {
            NSUInteger location = range.location;
            NSUInteger length = range.length;
            while (location != 0) {
                location --;
                length ++ ;
                char c = [textView.text characterAtIndex:location];
                if (c == '[') {
                    textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(location, length) withString:@""];
                    [self p_reloadTextViewWithAnimation:YES];
                    return NO;
                }
                else if (c == ']') {
                    return YES;
                }
            }
        }
    }
     return YES;
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self p_reloadTextViewWithAnimation:YES];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger length = [self getTextLength:textView.text];
    if (length > _maxTextWordCount)
    {
        NSInteger totalCount  = [self subString:textView.text subCount:_maxTextWordCount];
        textView.text = [textView.text substringToIndex:totalCount];
    }
    [self p_reloadTextViewWithAnimation:YES];
    [self hiddentTextViewLabel];
}

- (NSInteger )subString:(NSString *)text subCount:(NSInteger)count{
    NSInteger textLength = [text length];
    if (count > textLength) {
        return textLength;
    }
    if(count <= 0){
        return textLength;
    }
    // 字符串总长度
    NSInteger totalCount = count;
    // 循环的l索引
    NSInteger index = -1;
    // 位置
    NSInteger location = -1;
    while (index < count -1) {
        index ++;
        location ++;// 字符串中的索引位置
        NSInteger length  = 0;
        char c = [text characterAtIndex:location];
        if (c == '[') {
            location ++;
            length ++;
            char c = [text characterAtIndex:location];
            while (c != ']') {
                location ++;
                length ++;
                c = [text characterAtIndex:location];
            }
        }
        totalCount = totalCount + length;
    }
    return totalCount;
}

- (NSInteger)getTextLength:(NSString *)text{
    NSInteger totalLength = text.length;
    if (totalLength == 0) {
        return 0;
    }
    NSInteger location = totalLength - 1;
    if (location < 0) {
        return 0;
    }
    while (location != 0) {
        if ([text characterAtIndex:location] == ']') {
            NSInteger length = 1;
            while (location != 0) {
                location --;
                length ++;
                char c = [text characterAtIndex:location];
                if (c == ']') {
                    length --;
                }
                if (c == '[') {
                    totalLength = totalLength - length + 1;
                    break;
                }
            }
        }else{
            location --;
        }
    }
    return totalLength;
}



- (void)hiddentTextViewLabel{
    if ([self.textView.text length] == 0) {
        [self.textViewLabel setHidden:NO];
        
    }else{
        
        [self.textViewLabel setHidden:YES];
        
    }
}



#pragma mark - layer init ---------
- (UIButton *)modeButton
{
    if (_modeButton == nil) {
        _modeButton = [[UIButton alloc] init];
        [_modeButton setImage:[UIImage imageNamed:@"chat_toolbar_texttolist"] imageHighlight:[UIImage imageNamed:@"chat_toolbar_texttolist_HL"]];
        [_modeButton addTarget:self action:@selector(modeButtonDown) forControlEvents:UIControlEventTouchUpInside];
    }
    return _modeButton;
}

- (UIButton *)voiceButton
{
    if (_voiceButton == nil) {
        _voiceButton = [[UIButton alloc] init];
        [_voiceButton setImage:kVoiceImage imageHighlight:kVoiceImageHL];
        [_voiceButton addTarget:self action:@selector(voiceButtonDown) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

- (UITextView *)textView
{
    if (_textView == nil) {
        _textView = [[UITextView alloc] init];
        [_textView setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:16.0f]];
        _textView.textColor = [UIColor colorWithHex:0x000000];
        [_textView setReturnKeyType:UIReturnKeySend];
        [_textView setDelegate:self];
        [_textView setScrollsToTop:NO];
    }
    return _textView;
}
-  (UILabel *)textViewLabel{
    if (!_textViewLabel) {
        _textViewLabel = [[UILabel alloc] init];
        _textViewLabel.text = @"发消息...";
        _textViewLabel.numberOfLines = 1;
        _textViewLabel.textAlignment = NSTextAlignmentLeft;
        _textViewLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.0f];
        _textViewLabel.textColor = [UIColor colorWithHex:0xA1A1A1];
    }
    return _textViewLabel;
}
- (PontonTalkButton *)talkButton
{
    if (_talkButton == nil) {
        _talkButton = [[PontonTalkButton alloc] init];
        [_talkButton setHidden:YES];
        __weak typeof(self) weakSelf = self;
        [_talkButton setTouchBeginAction:^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(chatBarStartRecording:)]) {
                [weakSelf.delegate chatBarStartRecording:weakSelf];
            }
        } willTouchCancelAction:^(BOOL cancel) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(chatBarWillCancelRecording:cancel:)]) {
                [weakSelf.delegate chatBarWillCancelRecording:weakSelf cancel:cancel];
            }
        } touchEndAction:^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(chatBarFinishedRecoding:)]) {
                [weakSelf.delegate chatBarFinishedRecoding:weakSelf];
            }
        } touchCancelAction:^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(chatBarDidCancelRecording:)]) {
                [weakSelf.delegate chatBarDidCancelRecording:weakSelf];
            }
        }];
    }
    return _talkButton;
}

- (UIButton *)emojiButton
{
    if (_emojiButton == nil) {
        _emojiButton = [[UIButton alloc] init];
        [_emojiButton setImage:kEmojiImage imageHighlight:kEmojiImageHL];
        [_emojiButton addTarget:self action:@selector(emojiButtonDown) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiButton;
}

- (UIButton *)moreButton
{
    if (_moreButton == nil) {
        _moreButton = [[UIButton alloc] init];
        [_moreButton setImage:kMoreImage imageHighlight:kMoreImageHL];
        [_moreButton addTarget:self action:@selector(moreButtonDown) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (NSString *)curText
{
    return self.textView.text;
}


#pragma mark -------  button event ---------

- (void)modeButtonDown
{
    if (self.status == PhotonChatBarStatusEmoji) {
        if (_delegate && [_delegate respondsToSelector:@selector(chatBar:changeStatusFrom:to:)]) {
            [self.delegate chatBar:self changeStatusFrom:self.status to:PhotonChatBarStatusInit];
        }
        [self.emojiButton setImage:kEmojiImage imageHighlight:kEmojiImage];
        self.status = PhotonChatBarStatusInit;
        
    }
    else if (self.status == PhotonChatBarStatusMore) {
        if (_delegate && [_delegate respondsToSelector:@selector(chatBar:changeStatusFrom:to:)]) {
            [self.delegate chatBar:self changeStatusFrom:self.status to:PhotonChatBarStatusInit];
        }
        [self.moreButton setImage:kMoreImage imageHighlight:kMoreImage];
        self.status = PhotonChatBarStatusInit;
    }
}

static NSString *textRec = @"";
- (void)voiceButtonDown
{
    [self.textView resignFirstResponder];
    
    // 开始文字输入
    if (self.status == PhotonChatBarStatusVoice) {
        if (textRec.length > 0) {
            [self.textView setText:textRec];
            textRec = @"";
            [self p_reloadTextViewWithAnimation:YES];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(chatBar:changeStatusFrom:to:)]) {
            [self.delegate chatBar:self changeStatusFrom:self.status to:PhotonChatBarStatusKeyboard];
        }
        [self.voiceButton setImage:kVoiceImage imageHighlight:kVoiceImage];
        [self.textView becomeFirstResponder];
        [self.textView setHidden:NO];
        [self.talkButton setHidden:YES];
        self.status = PhotonChatBarStatusKeyboard;
    }
    else {          // 开始语音
        if (self.textView.text.length > 0) {
            textRec = self.textView.text;
            self.textView.text = @"";
            [self p_reloadTextViewWithAnimation:YES];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(chatBar:changeStatusFrom:to:)]) {
            [self.delegate chatBar:self changeStatusFrom:self.status to:PhotonChatBarStatusVoice];
        }
        if (self.status == PhotonChatBarStatusKeyboard) {
            [self.textView resignFirstResponder];
        }
        else if (self.status == PhotonChatBarStatusEmoji) {
            [self.emojiButton setImage:kEmojiImage imageHighlight:kEmojiImageHL];
        }
        else if (self.status == PhotonChatBarStatusMore) {
            [self.moreButton setImage:kMoreImage imageHighlight:kMoreImageHL];
        }
        [self.talkButton setHidden:NO];
        [self.textView setHidden:YES];
        [self.voiceButton setImage:kKeyboardImage imageHighlight:kKeyboardImageHL];
        self.status = PhotonChatBarStatusVoice;
    }
}

- (void)emojiButtonDown
{
    // 开始文字输入
    if (self.status == PhotonChatBarStatusEmoji) {
        if (_delegate && [_delegate respondsToSelector:@selector(chatBar:changeStatusFrom:to:)]) {
            [self.delegate chatBar:self changeStatusFrom:self.status to:PhotonChatBarStatusKeyboard];
        }
        [self.emojiButton setImage:kEmojiImage imageHighlight:kEmojiImageHL];
        [self.textView becomeFirstResponder];
        self.status = PhotonChatBarStatusKeyboard;
    }
    else {      // 打开表情键盘
        if (_delegate && [_delegate respondsToSelector:@selector(chatBar:changeStatusFrom:to:)]) {
            [self.delegate chatBar:self changeStatusFrom:self.status to:PhotonChatBarStatusEmoji];
        }
        if (self.status == PhotonChatBarStatusVoice) {
            [self.voiceButton setImage:kVoiceImage imageHighlight:kVoiceImageHL];
            [self.talkButton setHidden:YES];
            [self.textView setHidden:NO];
        }
        else if (self.status == PhotonChatBarStatusMore) {
            [self.moreButton setImage:kMoreImage imageHighlight:kMoreImageHL];
        }
        [self.emojiButton setImage:kKeyboardImage imageHighlight:kKeyboardImageHL];
        [self.textView resignFirstResponder];
        self.status = PhotonChatBarStatusEmoji;
    }
}

- (void)moreButtonDown
{
    // 开始文字输入
    if (self.status == PhotonChatBarStatusMore) {
        if (_delegate && [_delegate respondsToSelector:@selector(chatBar:changeStatusFrom:to:)]) {
            [self.delegate chatBar:self changeStatusFrom:self.status to:PhotonChatBarStatusKeyboard];
        }
        [self.moreButton setImage:kMoreImage imageHighlight:kMoreImageHL];
        [self.textView becomeFirstResponder];
        self.status = PhotonChatBarStatusKeyboard;
    }
    else {      // 打开更多键盘
        if (_delegate && [_delegate respondsToSelector:@selector(chatBar:changeStatusFrom:to:)]) {
            [self.delegate chatBar:self changeStatusFrom:self.status to:PhotonChatBarStatusMore];
        }
        if (self.status == PhotonChatBarStatusVoice) {
            [self.voiceButton setImage:kVoiceImage imageHighlight:kVoiceImageHL];
            [self.talkButton setHidden:YES];
            [self.textView setHidden:NO];
        }
        else if (self.status == PhotonChatBarStatusEmoji) {
            [self.emojiButton setImage:kEmojiImage imageHighlight:kEmojiImageHL];
        }
        [self.moreButton setImage:kKeyboardImage imageHighlight:kKeyboardImageHL];
        [self.textView resignFirstResponder];
        self.status = PhotonChatBarStatusMore;
    }
}


#pragma mark - Private Methods
- (void)p_reloadTextViewWithAnimation:(BOOL)animation
{
    CGFloat textHeight = [self.textView sizeThatFits:CGSizeMake(self.textView.width, MAXFLOAT)].height;
    CGFloat height = textHeight > HEIGHT_CHATBAR_TEXTVIEW ? textHeight : HEIGHT_CHATBAR_TEXTVIEW;
    height = (textHeight <= HEIGHT_MAX_CHATBAR_TEXTVIEW ? textHeight : HEIGHT_MAX_CHATBAR_TEXTVIEW);
    [self.textView setScrollEnabled:textHeight > height];
    if (height != self.textView.height) {
        if (animation) {
            [UIView animateWithDuration:0.2 animations:^{
                [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(height);
                }];
                if (self.superview) {
                    [self.superview layoutIfNeeded];
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:didChangeTextViewHeight:)]) {
                    [self.delegate chatBar:self didChangeTextViewHeight:self.textView.height];
                }
            } completion:^(BOOL finished) {
                if (textHeight > height) {
                    [self.textView setContentOffset:CGPointMake(0, textHeight - height) animated:YES];
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:didChangeTextViewHeight:)]) {
                    [self.delegate chatBar:self didChangeTextViewHeight:height];
                }
            }];
        }
        else {
            [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(height);
            }];
            if (self.superview) {
                [self.superview layoutIfNeeded];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:didChangeTextViewHeight:)]) {
                [self.delegate chatBar:self didChangeTextViewHeight:height];
            }
            if (textHeight > height) {
                [self.textView setContentOffset:CGPointMake(0, textHeight - height) animated:YES];
            }
        }
    }
    else if (textHeight > height) {
        if (animation) {
            CGFloat offsetY = self.textView.contentSize.height - self.textView.height;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.textView setContentOffset:CGPointMake(0, offsetY) animated:YES];
            });
        }
        else {
            [self.textView setContentOffset:CGPointMake(0, self.textView.contentSize.height - self.textView.height) animated:NO];
        }
    }
}

- (void)p_addMasonry
{
    [self.modeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.bottom.mas_equalTo(self).mas_offset(-4);
        make.width.mas_equalTo(0);
    }];
    
    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self.modeButton.mas_right).mas_offset(1);
        make.width.mas_equalTo(38);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_offset(9);
        make.bottom.mas_equalTo(self).mas_offset(-9);
        make.left.mas_equalTo(self.voiceButton.mas_right).mas_offset(4);
        make.right.mas_equalTo(self.emojiButton.mas_left).mas_offset(-4);
//        make.height.mas_equalTo(HEIGHT_CHATBAR_TEXTVIEW);
    }];
    
    [self.talkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.textView);
        make.size.mas_equalTo(self.textView);
    }];
    
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.width.mas_equalTo(self.voiceButton);
        make.right.mas_equalTo(self).mas_offset(-1);
    }];
    
    [self.emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.width.mas_equalTo(self.voiceButton);
        make.right.mas_equalTo(self.moreButton.mas_left);
    }];
    
    CGSize size = [self.textViewLabel sizeThatFits:CGSizeMake(PhotoScreenWidth, 23)];
    [self.textViewLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.centerY.mas_equalTo(self.textView);
        make.left.mas_equalTo(self.textView).mas_offset(5);
    }];
}

- (void)p_initImage
{
    kVoiceImage = [UIImage imageNamed:@"chat_toolbar_voice"];
    kEmojiImage = [UIImage imageNamed:@"chat_toolbar_emotion"];
    kMoreImage = [UIImage imageNamed:@"chat_toolbar_more"];
    kKeyboardImage = [UIImage imageNamed:@"chat_toolbar_keyboard"];
    kKeyboardImageHL = [UIImage imageNamed:@"chat_toolbar_keyboard_HL"];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor colorGrayLine].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, PhotoScreenWidth, 0);
    CGContextStrokePath(context);
}
@end
