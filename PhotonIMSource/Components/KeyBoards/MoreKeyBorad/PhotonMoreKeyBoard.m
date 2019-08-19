//
//  PhotonMoreKeyBoard.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/19.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonMoreKeyBoard.h"
#import "PhotonMoreKeyboardCell.h"
#import "PhotonMoreKeyboardItem.h"

#define     SPACE_TOP        15
#define     WIDTH_CELL       60

@interface PhotonMoreKeyBoard()<UICollectionViewDelegate,UICollectionViewDataSource>

@end

static PhotonMoreKeyBoard *_keyboard;
@implementation PhotonMoreKeyBoard
+ (instancetype)sharedKeyBoard{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _keyboard = [[PhotonMoreKeyBoard alloc] init];
    });
    return _keyboard;
}

- (id)init
{
    if (self = [super init]) {
        [self setBackgroundColor:[UIColor colorGrayForChatBar]];
        [self addSubview:self.collectionView];
        [self addSubview:self.pageControl];
        [self p_addMasonry];
        
        [self registerCellClass];
    }
    return self;
}

- (CGFloat)keyboardHeight
{
    return HEIGHT_CHAT_KEYBOARD + SAFEAREA_INSETS_BOTTOM;
}

#pragma mark - # Public Methods
- (void)setChatMoreKeyboardItems:(NSArray *)chatMoreKeyboardItems
{
    _chatMoreKeyboardItems = chatMoreKeyboardItems;
    [self.collectionView reloadData];
    NSUInteger pageNumber = chatMoreKeyboardItems.count / self.pageItemCount + (chatMoreKeyboardItems.count % self.pageItemCount == 0 ? 0 : 1);
    [self.pageControl setNumberOfPages:pageNumber];
}

- (void)reset
{
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, self.collectionView.width, self.collectionView.height) animated:NO];
}

#pragma mark - # Event Response
- (void)pageControlChanged:(UIPageControl *)pageControl
{
    [self.collectionView scrollRectToVisible:CGRectMake(self.collectionView.width * pageControl.currentPage, 0, self.collectionView.width, self.collectionView.height) animated:YES];
}

#pragma mark - Private Methods -
- (void)p_addMasonry
{
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.and.right.mas_equalTo(self);
        make.height.mas_equalTo(190);
    }];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(-2 - SAFEAREA_INSETS_BOTTOM);
    }];
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

#pragma mark - # Getter
- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        [_collectionView setPagingEnabled:YES];
        [_collectionView setDataSource:self];
        [_collectionView setDelegate:self];
        [_collectionView setShowsHorizontalScrollIndicator:NO];
        [_collectionView setShowsHorizontalScrollIndicator:NO];
        [_collectionView setScrollsToTop:NO];
    }
    return _collectionView;
}

- (UIPageControl *)pageControl
{
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];
        [_pageControl setPageIndicatorTintColor:[UIColor colorGrayLine]];
        [_pageControl setCurrentPageIndicatorTintColor:[UIColor grayColor]];
        [_pageControl addTarget:self action:@selector(pageControlChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}



#pragma mark - Public Methods -
- (void)registerCellClass
{
    [self.collectionView registerClass:[PhotonMoreKeyboardCell class] forCellWithReuseIdentifier:@"PhotonMoreKeyboardCell"];
}

#pragma mark - Delegate -
//MARK: UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.chatMoreKeyboardItems.count / self.pageItemCount + (self.chatMoreKeyboardItems.count % self.pageItemCount == 0 ? 0 : 1);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pageItemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotonMoreKeyboardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotonMoreKeyboardCell" forIndexPath:indexPath];
    NSUInteger index = indexPath.section * self.pageItemCount + indexPath.row;
    NSUInteger tIndex = [self p_transformIndex:index];  // 矩阵坐标转置
    if (tIndex >= self.chatMoreKeyboardItems.count) {
        [cell setItem:nil];
    }
    else {
        [cell setItem:self.chatMoreKeyboardItems[tIndex]];
    }
    __weak typeof(self) weakSelf = self;
    [cell setClickBlock:^(PhotonMoreKeyboardItem *sItem) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(moreKeyboard:didSelectedKeyboardItem:)]) {
            [weakSelf.delegate moreKeyboard:weakSelf didSelectedKeyboardItem:sItem];
        }
    }];
    return cell;
}

//MARK: UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(WIDTH_CELL, (collectionView.height - SPACE_TOP) / 2 * 0.93);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return (collectionView.width - WIDTH_CELL * self.pageItemCount / 2) / (self.pageItemCount / 2 + 1);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return (collectionView.height - SPACE_TOP) / 2 * 0.07;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat space = (collectionView.width - WIDTH_CELL * self.pageItemCount / 2) / (self.pageItemCount / 2 + 1);
    return UIEdgeInsetsMake(SPACE_TOP, space, 0, space);
}
//Mark: UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.pageControl setCurrentPage:(int)(scrollView.contentOffset.x / scrollView.width)];
}

#pragma mark - Private Methods -
- (NSUInteger)p_transformIndex:(NSUInteger)index
{
    NSUInteger page = index / self.pageItemCount;
    index = index % self.pageItemCount;
    NSUInteger x = index / 2;
    NSUInteger y = index % 2;
    return self.pageItemCount / 2 * y + x + page * self.pageItemCount;
}

#pragma mark - # Getter
- (NSInteger)pageItemCount
{
    return 8;
}
@end
