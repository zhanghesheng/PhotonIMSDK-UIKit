//
//  PhotonImageMessageChatCellTableViewCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/24.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonImageMessageChatCell.h"
#import "PhotonImageMessageChatItem.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PhotonMacros.h"
@interface PhotonImageMessageChatCell()
@end

@implementation PhotonImageMessageChatCell
- (void)dealloc
{
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
    }
    return self;
}

- (void)setObject:(id)object{
    [super setObject:object];
    if (!self.item) {
        return;
    }
    PhotonImageMessageChatItem *imageItem = (PhotonImageMessageChatItem *)object;
    NSURL *fileURL = nil;
    if (imageItem.thumURL) {
        if ([imageItem.thumURL hasPrefix:@"http"]) {
            fileURL = [NSURL URLWithString:imageItem.thumURL];
        }else{
            fileURL = [NSURL fileURLWithPath:imageItem.thumURL];
        }
    }
   
    if (fileURL) {
        [self.contentBackgroundView sd_setImageWithURL:fileURL placeholderImage:nil];
    }else{
        if (imageItem.localPath) {
            [self.contentBackgroundView setImage:[UIImage imageWithContentsOfFile:imageItem.localPath]];
        }else{
            if ([imageItem.orignURL hasPrefix:@"http"]) {
                fileURL = [NSURL URLWithString:imageItem.orignURL];
            }else{
                fileURL = [NSURL fileURLWithPath:imageItem.orignURL];
            }
            [self.contentBackgroundView sd_setImageWithURL:fileURL placeholderImage:nil];
        }
    }
}

- (void)p_layoutViews{
    PhotonBaseChatItem *item = (PhotonBaseChatItem *)self.item;
    CGRect contentBackgroundViewFrame = self.contentBackgroundView.frame;
    contentBackgroundViewFrame.size = CGSizeMake(item.contentSize.width + MSG_SPACE_RIGHT + MSG_SPACE_LEFT, item.contentSize.height + MSG_SPACE_TOP + MSG_SPACE_BTM);
    CGFloat contentBackgroundViewLeft = 0;
    if (item.fromType == PhotonChatMessageFromSelf) {
        contentBackgroundViewLeft = contentBackgroundViewFrame.origin.x-contentBackgroundViewFrame.size.width;
    }else{
        contentBackgroundViewLeft = contentBackgroundViewFrame.origin.x;
    }
    contentBackgroundViewFrame.origin.x = contentBackgroundViewLeft;
    self.contentBackgroundView.frame = contentBackgroundViewFrame;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self p_layoutViews];
    [self subview_layout];
}

- (void)prepareForReuse{
    [super prepareForReuse];
}

#pragma mark ----- Getter ---------
- (void)longPressBGView:(UIGestureRecognizer *)gestureRecognizer{
    [super longPressBGView:gestureRecognizer];
}

- (void)tapBackgroundView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatCell:chatMessageCellTap:)]) {
        [self.delegate chatCell:self chatMessageCellTap:self.item];
    }
}

+(CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    PhotonImageMessageChatItem *item = (PhotonImageMessageChatItem *)object;
    return item.itemHeight;
}

+ (NSString *)cellIdentifier{
    return @"PhotonImageMessageChatCell";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
