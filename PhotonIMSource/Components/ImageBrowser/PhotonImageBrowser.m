//
//  PhotonImageBrowser.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonImageBrowser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <objc/runtime.h>
#import "PhotonScreenImageCell.h"
#import "PhotonMacros.h"
#import "PhotonContent.h"
static NSTimeInterval const DefaultAnimationDuration = .25f;

static void * PhotonImageBrowserBackgroundViewKey = &PhotonImageBrowserBackgroundViewKey;
static void * PhotonImageBrowserCollectionViewKey = &PhotonImageBrowserCollectionViewKey;
static void * PhotonImageBrowserImagesKey = &PhotonImageBrowserImagesKey;
static void * PhotonImageBrowserImageURLsKey = &PhotonImageBrowserImageURLsKey;
static void * PhotonImageBrowserSmallImageURLsKey = &PhotonImageBrowserSmallImageURLsKey;
static void * PhotonImageBrowserPlaceholderImageKey = &PhotonImageBrowserPlaceholderImageKey;
static void * PhotonImageBrowserImageViewsKey = &PhotonImageBrowserImageViewsKey;
static void * PhotonImageBrowserImageViewURLsKey = &PhotonImageBrowserImageViewURLsKey;
static void * PhotonImageBrowserAnimationIndexPathKey = &PhotonImageBrowserAnimationIndexPathKey;
static void * PhotonImageBrowserOriginalImageViewKey = &PhotonImageBrowserOriginalImageViewKey;
static void * PhotonImageBrowserActionSheetViewKey = &PhotonImageBrowserActionSheetViewKey;
static void * PhotonImageBrowserActionSheetBackgroundViewKey = &PhotonImageBrowserActionSheetBackgroundViewKey;

@interface PhotonImageBrowser()<UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate>
@end

@implementation PhotonImageBrowser
+(void)showImage:(nullable UIImage *)image {
    [self showImages:image?@[image]:nil defaultImage:image];
}

+ (void)showImages:(nullable NSArray<UIImage *> *)images defaultImage:(nullable UIImage *)defaultImage {
    [self setImages:images];
    [self setImageURLs:nil];
    [self setPlaceholderImage:nil];
    [self setAnimationIndexPath:nil];
    
    NSUInteger index = [images indexOfObject:defaultImage];
    if (defaultImage && images.count > 0 && index != NSNotFound) {
        [self enterFullscreenModeWithDefaultIndex:index animated:YES];
    }
}

+ (void)showImageWithURL:(nullable NSString *)imageURL placeholderImage:(nullable UIImage *)placeholderImage {
    [self showImagesWithURLs:imageURL?@[imageURL]:nil defaultImageURL:imageURL placeholderImage:placeholderImage];
}

+ (void)showImagesWithURLs:(nullable NSArray <NSString *>*)imageURLs
defaultImageURL:(nullable NSString *)defaultImageURL
placeholderImage:(nullable UIImage *)placeholderImage {
    [self showImagesWithURLs:imageURLs smallImageURLs:imageURLs defaultImageURL:defaultImageURL placeholderImage:placeholderImage imageViews:nil imageViewURLs:nil];
}

+ (void)showImagesWithURLs:(nullable NSArray <NSString *>*)imageURLs
smallImageURLs:(nullable NSArray <NSString *>*)smallImageURLs
defaultImageURL:(nullable NSString *)defaultImageURL
placeholderImage:(nullable UIImage *)placeholderImage
imageViews:(nullable NSArray <UIImageView *> *)imageViews
imageViewURLs:(nullable NSArray<NSString *> *)imageViewURLs {
    [self setImages:nil];
    [self setImageURLs:imageURLs];
    [self setSmallImageURLs:smallImageURLs];
    [self setPlaceholderImage:placeholderImage];
    [self setImageViews:imageViews];
    [self setImageViewURLs:imageViewURLs];
    [self setAnimationIndexPath:nil];
    
    NSUInteger index = [imageURLs indexOfObject:defaultImageURL];
    if (defaultImageURL &&[defaultImageURL length] > 0 && imageURLs.count > 0 && index != NSNotFound) {
        [self enterFullscreenModeWithDefaultIndex:index animated:YES];
    }
}

+ (void)enterFullscreenModeWithDefaultIndex:(NSUInteger)index animated:(BOOL)animated {
    [self.backgroundView makeKeyAndVisible];
    [self.backgroundView addSubview:self.collectionView];
    [self.collectionView reloadData];
    
    if (index != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        
        // 记录下哪个cell要展示动画
        [self setAnimationIndexPath:indexPath];
        
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    [UIView animateWithDuration:DefaultAnimationDuration animations:^{
        self.backgroundView.backgroundColor = [UIColor blackColor];
    }];
}

+ (void)dismiss {
    UIImageView *originalImageView = self.originalImageView;
    
    PhotonScreenImageCell *cell = (PhotonScreenImageCell *)[self.collectionView cellForItemAtIndexPath:self.collectionView.indexPathsForVisibleItems.firstObject];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    NSString *smallImageURL = [self.smallImageURLs objectAtIndex:indexPath.item];
    for (NSInteger i = 0; i < self.imageViewURLs.count; i++) {
        NSString *imageViewURL = [self.imageViewURLs objectAtIndex:i];
        if ([smallImageURL isEqualToString:imageViewURL]) {
            originalImageView = [self.imageViews objectAtIndex:i];
            break;
        }
    }
    
    [cell stopLoading];
    
    CGRect originalFrame = [originalImageView.superview convertRect:originalImageView.frame toView:cell];
    CGSize imageSize = [self imageSizeInCell:cell originalImageView:cell.imageView atIndexPath:indexPath];
    cell.imageView.frame = CGRectMake((CGRectGetWidth(cell.imageZoomRect) - imageSize.width)/2.f, (CGRectGetHeight(cell.imageZoomRect) - imageSize.height)/2.f, imageSize.width, imageSize.height);
    CGRect rect = [cell.imageView.superview convertRect:cell.imageView.frame toView:cell];
    cell.imageView.frame = rect;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell.imageView.layer setContentsRect:CGRectMake(0, 0, 1, 1)];
    [cell addSubview:cell.imageView];
    
    [UIView animateWithDuration:DefaultAnimationDuration animations:^{
        self.backgroundView.backgroundColor = [UIColor clearColor];
        if (originalImageView && originalImageView.superview) {
            [cell.imageView setFrame:originalFrame];
            [cell.imageView.layer setContentsRect:originalImageView.layer.contentsRect];
        }
        else {
            cell.imageView.alpha = 0.f;
        }
    } completion:^(BOOL finished) {
        [self.collectionView removeFromSuperview];
        [self setCollectionView:nil];
        
        [self.backgroundView removeFromSuperview];
        [self setBackgroundView:nil];
        
        [UIApplication.sharedApplication.delegate.window makeKeyWindow];
    }];
    
    // 清理当前数据
    [self setImages:nil];
    [self setImageURLs:nil];
    [self setSmallImageURLs:nil];
    [self setPlaceholderImage:nil];
    [self setOriginalImageView:nil];
    [self setImageViews:nil];
    [self setImageViewURLs:nil];
    [self setAnimationIndexPath:nil];
    [self setActionSheetView:nil];
    [self setActionSheetBackgroundView:nil];
}

#pragma mark - UICollectionViewDelegate
+ (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(PhotonScreenImageCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *animationIndexPath = self.animationIndexPath;
    UIImageView *originalImageView = self.originalImageView;
    
    if ([animationIndexPath isEqual:indexPath] && originalImageView) {
        // 播放动画
        CGRect originalFrame = [originalImageView.superview convertRect:originalImageView.frame toView:self.backgroundView];
        [cell.imageView setImage:[self smallImageAtIndexPath:indexPath]];
        [cell.imageView setFrame:originalFrame];
        [cell.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [cell.imageView.layer setContentsRect:originalImageView.layer.contentsRect];
        [UIView animateWithDuration:DefaultAnimationDuration animations:^{
            CGSize imageSize = [self imageSizeInCell:cell originalImageView:originalImageView atIndexPath:indexPath];
            [cell.imageView setBounds:CGRectMake(0, 0, imageSize.width, imageSize.height)];
            [cell.imageView setCenter:CGPointMake(CGRectGetMidX(cell.bounds), CGRectGetMidY(cell.bounds))];
            [cell.imageView.layer setContentsRect:CGRectMake(0, 0, 1, 1)];
        } completion:^(BOOL finished) {
            [self loadingImageForCell:cell atIndexPath:indexPath];
        }];
        
        // 播放一次动画之后就将animationIndexPath数据清空，以保证只展示一次动画
        [self setAnimationIndexPath:nil];
    }
    else {
        [self loadingImageForCell:cell atIndexPath:indexPath];
    }
}

+ (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(PhotonScreenImageCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell setImageZoomScale:1.0];
}

#pragma mark - UICollectionViewDataSource
+ (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section  {
    return self.images?self.images.count:self.imageURLs.count;
}

+ (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotonScreenImageCell class]) forIndexPath:indexPath];
}

#pragma mark - UIGestureRecognizerDelegate
+ (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

+ (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    else if (([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [(UITapGestureRecognizer *)gestureRecognizer numberOfTapsRequired] == 1) && ([otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [(UITapGestureRecognizer *)otherGestureRecognizer numberOfTapsRequired] == 2)){
        return YES;
    }
    else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && otherGestureRecognizer.view == self.collectionView) {
        return YES;
    }
    else if (gestureRecognizer.view == [self backgroundView] && otherGestureRecognizer.view == [self actionSheetBackgroundView]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Target-Action
+ (void)longPress:(UIGestureRecognizer *)gesture {
    UIImage *image = [self currentVisibleImage];
    
    if (!image) return;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [[self backgroundView] addSubview:self.actionSheetBackgroundView];
        self.actionSheetBackgroundView.alpha = 0.f;
        
        [[self backgroundView] addSubview:self.actionSheetView];
        self.actionSheetView.frame = CGRectMake(0, CGRectGetHeight([self containerView].bounds), CGRectGetWidth(self.actionSheetView.frame), CGRectGetHeight(self.actionSheetView.frame));
        
        [UIView animateWithDuration:.25f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.actionSheetBackgroundView.alpha = 1.f;
            self.actionSheetView.frame = CGRectMake(0, CGRectGetHeight([self containerView].bounds) - CGRectGetHeight(self.actionSheetView.frame), CGRectGetWidth(self.actionSheetView.frame), CGRectGetHeight(self.actionSheetView.frame));
        } completion:nil];
    }
}

+ (void)saveImage:(id)sender {
    UIImage *image = [self currentVisibleImage];
    
    if (image) {
        [self cancel:nil];
        
//        Class assetsLibrary= NSClassFromString(@"PHPhotoLibrary");
//        [assetsLibrary saveImag:image toAlubm:@"PhotonIM" withCompletionBlock:^(BOOL success,NSError *error) {
//            if (success) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [[MDVChatUtil sharedIndicate] showOKInView:self.backgroundView withText:@"图片保存成功" timeOut:1.f];
//                });
//            }
//        }];
    }
}

+ (void)cancel:(id)sender {
    [UIView animateWithDuration:.25f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.actionSheetBackgroundView.alpha = 0.f;
        self.actionSheetView.frame = CGRectMake(0, CGRectGetHeight([self containerView].bounds), CGRectGetWidth(self.actionSheetView.frame), CGRectGetHeight(self.actionSheetView.frame));
    } completion:^(BOOL finished) {
        [self.actionSheetBackgroundView removeFromSuperview];
        [self setActionSheetBackgroundView:nil];
        
        [self.actionSheetView removeFromSuperview];
        [self setActionSheetView:nil];
    }];
}

#pragma mark - Private Methods
+ (void)loadingImageForCell:(PhotonScreenImageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    cell.imageView.frame = cell.bounds;
//    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (self.images) {
        UIImage *image = [self.images objectAtIndex:indexPath.item];
        cell.imageView.image = image;
    }
    else {
        NSString *imageURL = [self.imageURLs objectAtIndex:indexPath.item];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:imageURL]) {
            cell.imageView.image = [UIImage imageWithContentsOfFile:imageURL];
        } else {
            UIImage *placeholderImage = [self smallImageAtIndexPath:indexPath];
            
            [cell startLoading];
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:placeholderImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (image) {
                    cell.imageView.image = image;
                }
                [cell stopLoading];
            }];
        }
    }
}

+ (CGSize)imageSizeInCell:(PhotonScreenImageCell *)cell originalImageView:(UIImageView *)originalImageView atIndexPath:(NSIndexPath *)indexPath {
    if (!cell || !originalImageView) return CGSizeZero;
    
    UIImage *smallImage = [self smallImageAtIndexPath:indexPath];
    
    UIImage *image = smallImage?:originalImageView.image;
    
    if (!image) return CGSizeZero;
    
    CGFloat imageRatio = image.size.width/image.size.height;
    
    CGFloat viewRatio = CGRectGetWidth([UIScreen mainScreen].bounds)/CGRectGetHeight([UIScreen mainScreen].bounds);
    
    if (imageRatio < viewRatio) {
        CGFloat scale = CGRectGetHeight(cell.bounds)/image.size.height;
        CGFloat width = scale * image.size.width;
        
        return CGSizeMake(width * cell.imageZoomScale, CGRectGetHeight(cell.bounds) * cell.imageZoomScale);
    }
    else {
        CGFloat scale = CGRectGetWidth(cell.bounds)/image.size.width;
        CGFloat height = scale * image.size.height;
        
        return CGSizeMake(CGRectGetWidth(cell.bounds) * cell.imageZoomScale, height * cell.imageZoomScale);
    }
}

+ (UIImage *)smallImageAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *smallImage = nil;
    
    NSString *imageURL = [self.imageURLs objectAtIndex:indexPath.item];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageURL]) {
        smallImage = [UIImage imageWithContentsOfFile:imageURL];
    }
    else {
        if (self.smallImageURLs.count > 0) {
            NSString *smallImageURL = [self.smallImageURLs objectAtIndex:indexPath.item];
            
            NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:smallImageURL]];
            smallImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:key];
        }
        else if (self.imageViews.count > 0) {
            UIImageView *imageView = [self.imageViews objectAtIndex:indexPath.item];
            
            smallImage = imageView.image?:self.originalImageView.image;
        }
    }
    
    smallImage = smallImage?:self.placeholderImage;
    
    return smallImage;
}

+ (UIImage *)currentVisibleImage {
    PhotonScreenImageCell *cell = [[self collectionView] visibleCells].firstObject;
    
    return cell.imageView.image;
}

+ (UIView *)containerView {
    return [PhotonContent sharedAppDelegate].window;
}

+ (UIWindow *)backgroundView {
    UIWindow *backgroundView = objc_getAssociatedObject(self, PhotonImageBrowserBackgroundViewKey);
    if (!backgroundView) {
        backgroundView = [[UIWindow alloc] initWithFrame:[self containerView].bounds];
        backgroundView.userInteractionEnabled = YES;
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        backgroundView.backgroundColor = [UIColor clearColor];
        backgroundView.windowLevel = UIWindowLevelStatusBar + 1;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        tap.delegate = (id<UIGestureRecognizerDelegate>)self;
        [backgroundView addGestureRecognizer:tap];
        
        [self setBackgroundView:backgroundView];
    }
    
    return backgroundView;
}

+ (void)setBackgroundView:(UIWindow *)backgroundView {
    objc_setAssociatedObject(self, PhotonImageBrowserBackgroundViewKey, backgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (UICollectionView *)collectionView {
    UICollectionView *collectionView = objc_getAssociatedObject(self, PhotonImageBrowserCollectionViewKey);
    
    if (!collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(CGRectGetWidth([self backgroundView].frame), CGRectGetHeight([self backgroundView].frame));
        layout.minimumLineSpacing = 0.f;
        layout.minimumInteritemSpacing = 0.f;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        collectionView = [[UICollectionView alloc] initWithFrame:[self backgroundView].bounds collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = (id<UICollectionViewDelegate>)self;
        collectionView.dataSource = (id<UICollectionViewDataSource>)self;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.pagingEnabled = YES;
        collectionView.bounces = YES;
        [collectionView registerClass:[PhotonScreenImageCell class] forCellWithReuseIdentifier:NSStringFromClass([PhotonScreenImageCell class])];
        
        if (@available(iOS 11.0, *)) {
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
//        UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
//        longPress.delegate =  (id<UIGestureRecognizerDelegate>)self;
//        longPress.delaysTouchesBegan = YES;
//        [collectionView addGestureRecognizer:longPress];
        
        [self setCollectionView:collectionView];
    }
    
    return collectionView;
}

+ (void)setCollectionView:(UICollectionView *)collectionView {
    objc_setAssociatedObject(self, PhotonImageBrowserCollectionViewKey, collectionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (UIView *)actionSheetView {
    UIView *actionSheetView = objc_getAssociatedObject(self, PhotonImageBrowserActionSheetViewKey);
    if (!actionSheetView) {
        CGFloat safeBottom = 0.f;
        
        if (@available(iOS 11, *)) {
            safeBottom = [self containerView].safeAreaInsets.bottom;
        }
        
        CGFloat const separatorLineHeight = .5f;
        CGFloat const buttonHeight = 55.f;
        
        actionSheetView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([self containerView].bounds) - buttonHeight * 2.f - separatorLineHeight - safeBottom, CGRectGetWidth([self containerView].bounds), buttonHeight * 2.f + separatorLineHeight + safeBottom)];
        actionSheetView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        actionSheetView.backgroundColor = [UIColor whiteColor];
        
        UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(actionSheetView.bounds), buttonHeight)];
        saveButton.titleLabel.font = [UIFont systemFontOfSize:18.f];
        [saveButton setTitle:@"保存图片" forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(saveImage:) forControlEvents:UIControlEventTouchUpInside];
        [actionSheetView addSubview:saveButton];
        
        UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(saveButton.frame), CGRectGetWidth(actionSheetView.frame), separatorLineHeight)];
        separatorLine.backgroundColor = [UIColor colorWithWhite:0 alpha:.05f];
        [actionSheetView addSubview:separatorLine];
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(separatorLine.frame), CGRectGetWidth(actionSheetView.bounds), buttonHeight)];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:18.f];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [actionSheetView addSubview:cancelButton];
        
        [self setActionSheetView:actionSheetView];
    }
    
    return actionSheetView;
}

+ (void)setActionSheetView:(UIView *)actionSheetView {
    objc_setAssociatedObject(self, PhotonImageBrowserActionSheetViewKey, actionSheetView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (UIView *)actionSheetBackgroundView {
    UIView *actionSheetBackgroundView = objc_getAssociatedObject(self, PhotonImageBrowserActionSheetBackgroundViewKey);
    
    if (!actionSheetBackgroundView) {
        actionSheetBackgroundView = [[UIView alloc] initWithFrame:[self containerView].bounds];
        actionSheetBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        actionSheetBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:.4f];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel:)];
        [actionSheetBackgroundView addGestureRecognizer:tap];
        
        [self setActionSheetBackgroundView:actionSheetBackgroundView];
    }
    
    return actionSheetBackgroundView;
}

+ (void)setActionSheetBackgroundView:(UIView *)actionSheetBackgroundView {
    objc_setAssociatedObject(self, PhotonImageBrowserActionSheetBackgroundViewKey, actionSheetBackgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSArray <UIImage *> *)images{
    return objc_getAssociatedObject(self, PhotonImageBrowserImagesKey);
}

+ (void)setImages:(NSArray <UIImage *> *)images {
    objc_setAssociatedObject(self, PhotonImageBrowserImagesKey, images, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSArray <NSString *>*)imageURLs {
    return objc_getAssociatedObject(self, PhotonImageBrowserImageURLsKey);
}

+ (void)setImageURLs:(NSArray <NSString *>*)imageURLs {
    objc_setAssociatedObject(self, PhotonImageBrowserImageURLsKey, imageURLs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSArray <NSString *>*)smallImageURLs {
    return objc_getAssociatedObject(self, PhotonImageBrowserSmallImageURLsKey);
}

+ (void)setSmallImageURLs:(NSArray <NSString *> *)smallImageURLs {
    objc_setAssociatedObject(self, PhotonImageBrowserSmallImageURLsKey, smallImageURLs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (UIImage *)placeholderImage {
    return objc_getAssociatedObject(self, PhotonImageBrowserPlaceholderImageKey);
}

+ (void)setPlaceholderImage:(UIImage *)placeholderImage {
    objc_setAssociatedObject(self, PhotonImageBrowserPlaceholderImageKey, placeholderImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSArray <UIImageView *> *)imageViews {
    return objc_getAssociatedObject(self, PhotonImageBrowserImageViewsKey);
}

+ (void)setImageViews:(NSArray <UIImageView *> *)imageViews {
    objc_setAssociatedObject(self, PhotonImageBrowserImageViewsKey, imageViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSArray <NSString *> *)imageViewURLs {
    return objc_getAssociatedObject(self, PhotonImageBrowserImageViewURLsKey);
}

+ (void)setImageViewURLs:(NSArray <NSString *> *)imageViewURLs {
    objc_setAssociatedObject(self, PhotonImageBrowserImageViewURLsKey, imageViewURLs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSIndexPath *)animationIndexPath {
    return objc_getAssociatedObject(self, PhotonImageBrowserAnimationIndexPathKey);
}

+ (void)setAnimationIndexPath:(NSIndexPath *)animationIndexPath {
    objc_setAssociatedObject(self, PhotonImageBrowserAnimationIndexPathKey, animationIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (UIImageView *)originalImageView {
    return objc_getAssociatedObject(self, PhotonImageBrowserOriginalImageViewKey);
}

+ (void)setOriginalImageView:(nullable UIImageView *)originalImageView {
    objc_setAssociatedObject(self, PhotonImageBrowserOriginalImageViewKey, originalImageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end


@implementation UIImageView (BrowserMode)

- (void)enterBrowserMode {
    [self enterBrowserModeWithImages:self.image?@[self.image]:nil];
}

- (void)enterBrowserModeWithImages:(nullable NSArray<UIImage *> *)images {
    [PhotonImageBrowser setOriginalImageView:self];
    [PhotonImageBrowser showImages:images defaultImage:self.image];
}

- (void)enterBrowserModeWithImages:(nullable NSArray<UIImage *> *)images defaultImage:(nullable UIImage *)defaultImage {
    [PhotonImageBrowser setOriginalImageView:self];
    [PhotonImageBrowser showImages:images defaultImage:defaultImage];
}

- (void)enterBrowserModeWithImageURL:(nullable NSString *)imageURL placeholderImage:(nullable UIImage *)placeholderImage {
    [self enterBrowserModeWithImageURLs:[imageURL isNotEmpty]?@[imageURL]:nil
                                  defaultImageURL:imageURL
                                 placeholderImage:placeholderImage];
}

- (void)enterBrowserModeWithImageURLs:(nullable NSArray<NSString *> *)imageURLs
                                defaultImageURL:(nullable NSString *)defaultImageURL
                               placeholderImage:(nullable UIImage *)placeholderImage {
    [self enterBrowserModeWithImageURLs:imageURLs
                                   smallImageURLs:imageURLs
                                  defaultImageURL:defaultImageURL
                                 placeholderImage:placeholderImage
                                       imageViews:nil
                                    imageViewURLs:nil];
}

- (void)enterBrowserModeWithImageURLs:(nullable NSArray <NSString *>*)imageURLs
                                 smallImageURLs:(nullable NSArray <NSString *>*)smallImageURLs
                                defaultImageURL:(nullable NSString *)defaultImageURL
                               placeholderImage:(nullable UIImage *)placeholderImage
                                     imageViews:(nullable NSArray <UIImageView *> *)imageViews
                                  imageViewURLs:(nullable NSArray <NSString *>*)imageViewURLs {
    [PhotonImageBrowser setOriginalImageView:self];
    [PhotonImageBrowser  showImagesWithURLs:imageURLs
                                  smallImageURLs:smallImageURLs
                                 defaultImageURL:defaultImageURL
                                placeholderImage:placeholderImage
                                      imageViews:imageViews
                                   imageViewURLs:imageViewURLs];
}

@end
