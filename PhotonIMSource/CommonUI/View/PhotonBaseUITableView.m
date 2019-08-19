//
//  PhotonBaseUITableView.m
//  PhotonIM
//
//  Created by Bruce on 2019/8/12.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonBaseUITableView.h"

@interface PhotonBaseUITableView()
@property (nonatomic, assign) CGPoint contentOffsetForRestore;
@end

@implementation PhotonBaseUITableView



- (void)reloadDataWithoutScrollToTop {
    [self reloadData];
    [self setContentOffset:self.contentOffsetForRestore];
}



- (void)setContentSize:(CGSize)contentSize {
    CGFloat previousContentHeight = self.contentSize.height;
    [super setContentSize:contentSize];
    CGFloat currentContentHeight = self.contentSize.height;
    self.contentOffsetForRestore = CGPointMake(0, (currentContentHeight - previousContentHeight - self.contentInset.top));
}


- (void)scrollToBottomWithAnimation:(BOOL)animation
{
    CGFloat viewHeight = self.frame.size.height;
    if (self.contentHeight > viewHeight) {
        CGFloat offsetY = self.contentHeight - viewHeight;
        [self setOffsetY:offsetY animated:animation];
    }
}

- (void)setOffsetY:(CGFloat)offsetY animated:(BOOL)animated
{
    CGPoint point = self.contentOffset;
    point.y = offsetY;
    [self setContentOffset:point animated:animated];
}

- (CGFloat)contentHeight
{
    return self.contentSize.height;
}
@end
