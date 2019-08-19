//
//  PhotonEmojiHorizontalLayout.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/20.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonEmojiHorizontalLayout.h"
#import "PhotonMacros.h"
static const CGFloat kEmojiItemWHRatio = 85.0f / 67.0f;
static const CGFloat kCollectionViewInset = 5;
static const NSUInteger kMaxRowCount = 3;
static const NSUInteger kMaxColumnCount = 8;
static const CGFloat kItemMagin = 6;

@interface PhotonEmojiHorizontalLayout()<UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray                *attributeAttay;
@property (nonatomic, assign) CGSize                        contentSize;
@end
@implementation PhotonEmojiHorizontalLayout
- (void)prepareLayout{
    
    [super prepareLayout];
    
    _attributeAttay = [NSMutableArray arrayWithCapacity:_itemCount];
    CGFloat itemWidth = [PhotonEmojiHorizontalLayout getItemWidth];
    CGFloat itemHeight = [PhotonEmojiHorizontalLayout getItemHeight];
    
    for (NSUInteger i = 0; i < _itemCount; ++i) {
        
        CGFloat x = kCollectionViewInset + (itemWidth + kItemMagin) * (i % kMaxColumnCount) + (PhotoScreenWidth * (i / (kMaxColumnCount * kMaxRowCount)));
        CGFloat y = (itemHeight + kItemMagin) * ((i / kMaxColumnCount) % kMaxRowCount);
        
        CGRect itemFrame = CGRectMake(x, y, itemWidth, itemHeight);
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *aAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        aAttribute.frame = itemFrame;
        [_attributeAttay addObject:aAttribute];
    }

    self.contentSize = CGSizeMake(PhotoScreenWidth * self.pageCount, [PhotonEmojiHorizontalLayout heightOfCollectionView]);
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    return _attributeAttay;
}

-(CGSize)collectionViewContentSize {
    
    return self.contentSize;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    return NO;
}

#pragma mark - 辅助方法
- (NSUInteger)pageCount
{
    return _itemCount / (kMaxRowCount * kMaxColumnCount);
}

+ (CGFloat)getItemWidth
{
    return (PhotoScreenWidth - (kCollectionViewInset * 2) - kItemMagin * (kMaxColumnCount - 1)) / kMaxColumnCount;
}

+ (CGFloat)getItemHeight
{
    return [self getItemWidth] / kEmojiItemWHRatio;
}

+ (CGFloat)heightOfCollectionView
{
    CGFloat itemH = [self getItemHeight];
    return itemH * kMaxRowCount + kItemMagin*(kMaxRowCount - 1);
}
@end
