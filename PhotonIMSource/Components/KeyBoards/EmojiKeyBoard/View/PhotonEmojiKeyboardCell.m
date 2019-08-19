//
//  PhotonEmojiKeyboardCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/20.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonEmojiKeyboardCell.h"
#import "PhotonMacros.h"
#import "PhotonEmojiKeyboardItem.h"
@interface PhotonEmojiKeyboardCell(){
    
}
@property (nonatomic,strong) UIImageView *bgView;
@property (nonatomic,strong) UIImageView *emojiIconView;
@end
@implementation PhotonEmojiKeyboardCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor colorWithHex:0xF7F7F7];
        [self configViews];
    }
    return self;
}

- (void)configViews
{

    [self.contentView addSubview:_bgView];
    [self.contentView addSubview:self.emojiIconView];
}

- (void)bindItem:(PhotonEmojiKeyboardItem *)item{
    UIImage *image = [UIImage imageNamed:item.emojiName];
    self.emojiIconView.image = image;
   
    [self.emojiIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
        make.bottom.right.mas_equalTo(0);
    }];
    
}
- (NSString *)filterBracketWithText:(NSString *)text
{
    NSMutableString *result = [NSMutableString stringWithString:text];
    
    NSRange leftBracketRange = [result rangeOfString:@"["];
    if (leftBracketRange.location != NSNotFound) {
        [result deleteCharactersInRange:leftBracketRange];
    }
    
    NSRange rightBracketRange = [result rangeOfString:@"]"];
    if (rightBracketRange.location != NSNotFound) {
        [result deleteCharactersInRange:rightBracketRange];
    }
    
    return result;
}
- (UIImageView *)emojiIconView{
    if (!_emojiIconView) {
        _emojiIconView = [[UIImageView alloc] init];
        _emojiIconView.backgroundColor = [UIColor clearColor];
        _emojiIconView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _emojiIconView;
}
@end
