//
//  PhotonEmojiKeyBoard.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/20.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonEmojiKeyboard.h"
#import "PhotonMacros.h"
#import "PhotonEmojiHorizontalLayout.h"
#import "PhotonEmojiKeyboardItem.h"
#import "PhotonEmojiKeyboardCell.h"

static const CGFloat kTopEdge = 24;
static const CGFloat kBottomEdge = 85;
@interface PhotonEmojiKeyboard()<
UICollectionViewDataSource,
UICollectionViewDelegate
>
@property (nonatomic,strong) PhotonEmojiHorizontalLayout *viewLayout;
@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,strong) UIButton *removeBtn;
@property (nonatomic,strong) UIButton *sendBtn;

@property (nonatomic,strong) NSMutableArray<PhotonEmojiKeyboardItem *> *dataList;
@end
static PhotonEmojiKeyboard *_keyBoard;


@implementation PhotonEmojiKeyboard
+ (instancetype)sharedKeyBoard{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _keyBoard = [[PhotonEmojiKeyboard alloc]init];
    });
    return _keyBoard;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self p_initContent];
    }
    return self;
}


- (void)p_initContent{
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.topView];
    [self addSubview:self.collectionView];
    [self addSubview:self.pageControl];
    [self addSubview:self.sendBtn];
    [self addSubview:self.removeBtn];
    [self p_addMasonry];
}

- (void)p_addMasonry{
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.and.right.mas_equalTo(self);
        make.height.mas_equalTo(kTopEdge);
    }];
    
    CGFloat height = [PhotonEmojiHorizontalLayout heightOfCollectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.left.and.right.mas_equalTo(self);
        make.height.mas_equalTo(height);
    }];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(self);
        make.top.mas_equalTo(self.collectionView.mas_bottom).mas_equalTo(SAFEAREA_INSETS_BOTTOM);
        make.height.mas_equalTo(35);
    }];
    
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(32.5);
        make.width.mas_equalTo(62.5);
        make.right.mas_equalTo(self).mas_offset(-10);
        make.top.mas_equalTo(self.pageControl.mas_bottom).mas_offset(10);
        
    }];
    
    [self.removeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.sendBtn.mas_left).mas_offset(-10);
        make.centerY.mas_equalTo(self.sendBtn);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(29);
    }];
    
   
}

- (void)setChatEmojiKeyboardItems:(NSArray *)chatEmojiKeyboardItems{
    if (chatEmojiKeyboardItems) {
         _dataList = [NSMutableArray arrayWithArray:chatEmojiKeyboardItems];
    }else{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"FaceEmoji" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        NSArray *items = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        _dataList = [NSMutableArray arrayWithCapacity:items.count];
        for (NSDictionary *item in items) {
            NSString *emojiName = item[@"credentialName"];
            PhotonEmojiKeyboardItem *item = [[PhotonEmojiKeyboardItem alloc] init];
            item.emojiName = emojiName;
            [_dataList addObject:item];
        }
    }
    [self loadData];
}

- (void)loadData
{
    self.viewLayout.itemCount = _dataList.count;
    
    [self.collectionView reloadData];
    
    //updatePageControl
    NSUInteger pageCount = self.viewLayout.pageCount;
    self.pageControl.numberOfPages = pageCount;
    self.pageControl.currentPage = 0;
}
#pragma mark - getter
- (PhotonEmojiHorizontalLayout *)viewLayout
{
    if (!_viewLayout) {
        _viewLayout = [[PhotonEmojiHorizontalLayout alloc] init];
    }
    return _viewLayout;
}
- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor colorWithHex:0XF7F7F7];
    }
    return _topView;
            
}
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.viewLayout];
        [_collectionView registerClass:[PhotonEmojiKeyboardCell class] forCellWithReuseIdentifier:NSStringFromClass([PhotonEmojiKeyboardCell class])];
        _collectionView.backgroundColor = [UIColor colorWithHex:0XF7F7F7];
        _collectionView.pagingEnabled = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        
        if ([_collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
            if (@available(iOS 10.0, *)) {
                [_collectionView setPrefetchingEnabled:NO];
            }
        }
        
    }
    return _collectionView;
}

- (UIPageControl *)pageControl {
    
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPage = 0;
        _pageControl.backgroundColor = [UIColor colorWithHex:0XF7F7F7];
        _pageControl.pageIndicatorTintColor = RGBAColor(0, 0, 0, 0.06);
        _pageControl.currentPageIndicatorTintColor = RGBAColor(0, 0, 0, 0.4);
    }
    return _pageControl;
}

- (UIButton *)sendBtn
{
    if (!_sendBtn) {
        _sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 33)];
        _sendBtn.layer.masksToBounds = YES;
        _sendBtn.layer.cornerRadius = 5.0f;
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:12.0f];
        [_sendBtn setBackgroundColor:[UIColor colorWithHex:0x02A33D] forState:UIControlStateNormal];
        [_sendBtn addTarget:self action:@selector(didClickSendBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (UIButton *)removeBtn
{
    if (!_removeBtn) {
        _removeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38, 30)];
        [_removeBtn setBackgroundImage:[UIImage imageNamed:@"emojiKB_emoji_delete"] forState:UIControlStateNormal];
        [_removeBtn addTarget:self action:@selector(didClickRemoveBtn:) forControlEvents:UIControlEventTouchUpInside];
        _removeBtn.contentMode= UIViewContentModeScaleAspectFit;
    }
    return _removeBtn;
}


#pragma mark ---- btn event --------
- (void)didClickSendBtn:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(emojiKeyboardDidClickSend:)]) {
        [self.delegate emojiKeyboardDidClickSend:self];
    }
}

- (void)didClickRemoveBtn:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(emojiKeyboardDidClickRemove:)]) {
        [self.delegate emojiKeyboardDidClickRemove:self];
    }
}

- (CGFloat)keyboardHeight{
    CGFloat collectionViewH = [PhotonEmojiHorizontalLayout heightOfCollectionView];
    CGFloat height = kTopEdge  + collectionViewH + kBottomEdge + SAFEAREA_INSETS_BOTTOM;
    return height;
}


#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotonEmojiKeyboardItem* item = [_dataList objectAtIndex:indexPath.item];
    PhotonEmojiKeyboardCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotonEmojiKeyboardCell class]) forIndexPath:indexPath];
    [cell bindItem:item];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotonEmojiKeyboardItem *item = [_dataList objectAtIndex:indexPath.item];
    if ([self.delegate respondsToSelector:@selector(emojiKeyboard:selectEmojiWithText:)]) {
        [self.delegate emojiKeyboard:self selectEmojiWithText:item.emojiName];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSUInteger page = round(scrollView.contentOffset.x / self.collectionView.width);
    self.pageControl.currentPage = page;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSUInteger page = round(scrollView.contentOffset.x / self.collectionView.width);
    self.pageControl.currentPage = page;
}


@end
