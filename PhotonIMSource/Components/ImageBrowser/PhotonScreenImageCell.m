//
//  PhotonScreenImageCell.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonScreenImageCell.h"
static CGFloat const kLoadingWidth = 50.f;
static CGFloat const kLoadingHeight = 50.f;
@interface PhotonScreenImageCell()
@property (nonatomic, strong) UIScrollView  *imageScrollView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@end
@implementation PhotonScreenImageCell
@dynamic imageZoomScale;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageScrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
        _imageScrollView.layer.masksToBounds = NO;
        _imageScrollView.showsHorizontalScrollIndicator = NO;
        _imageScrollView.showsVerticalScrollIndicator = NO;
        _imageScrollView.maximumZoomScale = 2.0;
        _imageScrollView.minimumZoomScale = 1.0;
        _imageScrollView.backgroundColor = [UIColor clearColor];
        _imageScrollView.delegate = (id<UIScrollViewDelegate>) self;
        [self.contentView addSubview:self.imageScrollView];
        
        if (@available(iOS 11.0, *)) {
            _imageScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        _imageView = [[UIImageView alloc]initWithFrame:self.imageScrollView.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.userInteractionEnabled = YES;
        _imageView.clipsToBounds = YES;
        [self.imageScrollView addSubview:self.imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap.numberOfTapsRequired = 2;
        [_imageView addGestureRecognizer:tap];
        
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _loadingView.frame = CGRectMake((CGRectGetWidth(self.contentView.bounds) - kLoadingWidth)/2.f, (CGRectGetHeight(self.contentView.bounds) - kLoadingHeight)/2.f, kLoadingWidth, kLoadingHeight);
        _loadingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:self.loadingView];
    }
    
    return self;
}

- (void)startLoading {
    [self.contentView bringSubviewToFront:self.loadingView];
    [self.loadingView startAnimating];
}

- (void)stopLoading {
    [self.loadingView stopAnimating];
}

#pragma mark - Target-Action
- (void)doubleTap:(UITapGestureRecognizer *)gesture {
    if (self.imageScrollView.zoomScale > 1.0) {
        [self.imageScrollView setZoomScale:1.0 animated:YES];
    }
    else {
        CGPoint touchPoint = [gesture locationInView:self.imageView];
        CGFloat newZoomScale = self.imageScrollView.maximumZoomScale;
        CGFloat xSize = self.frame.size.width/newZoomScale;
        CGFloat ySize = self.frame.size.height/newZoomScale;
        [self.imageScrollView zoomToRect:CGRectMake(touchPoint.x - xSize/2, touchPoint.y - ySize/2, xSize, ySize) animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width) / 2 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height) / 2 : 0.0;
    
    self.imageView.center = CGPointMake(scrollView.contentSize.width / 2 + offsetX,scrollView.contentSize.height / 2 + offsetY);
}

#pragma mark - Getter
- (CGFloat)imageZoomScale {
    return self.imageScrollView.zoomScale;
}

- (void)setImageZoomScale:(CGFloat)imageZoomScale {
    [self.imageScrollView setZoomScale:imageZoomScale];
}

- (CGRect)imageZoomRect {
    if (self.imageZoomScale > 1.f) {
        return CGRectMake(-self.imageScrollView.contentOffset.x, -self.imageScrollView.contentOffset.y, self.imageScrollView.contentSize.width, self.imageScrollView.contentSize.height);
    }
    else {
        return self.imageScrollView.bounds;
    }
}
@end
