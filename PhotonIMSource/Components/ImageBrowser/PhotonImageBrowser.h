//
//  PhotonImageBrowser.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface PhotonImageBrowser : NSObject
+ (void)showImage:(nullable UIImage *)image;
+ (void)showImages:(nullable NSArray <UIImage *> *)images
      defaultImage:(nullable UIImage *)defaultImage;
+ (void)showImageWithURL:(nullable NSString *)imageURL
        placeholderImage:(nullable UIImage *)placeholderImage;
+ (void)showImagesWithURLs:(nullable NSArray <NSString *>*)imageURLs
           defaultImageURL:(nullable NSString *)defaultImageURL
          placeholderImage:(nullable UIImage *)placeholderImage;
+ (void)showImagesWithURLs:(nullable NSArray <NSString *>*)imageURLs
            smallImageURLs:(nullable NSArray <NSString *>*)smallImageURLs
           defaultImageURL:(nullable NSString *)defaultImageURL
          placeholderImage:(nullable UIImage *)placeholderImage
                imageViews:(nullable NSArray <UIImageView *> *)imageViews
             imageViewURLs:(nullable NSArray <NSString *>*)imageViewURLs;
@end

@interface UIImageView (BrowserMode)

- (void)enterBrowserMode;
- (void)enterBrowserModeWithImages:(nullable NSArray <UIImage *> *)images;
- (void)enterBrowserModeWithImages:(nullable NSArray<UIImage *> *)images defaultImage:(nullable UIImage *)defaultImage;
- (void)enterBrowserModeWithImageURL:(nullable NSString *)imageURL placeholderImage:(nullable UIImage *)placeholderImage;
- (void)enterBrowserModeWithImageURLs:(nullable NSArray <NSString *>*)imageURLs
                                defaultImageURL:(nullable NSString *)defaultImageURL
                               placeholderImage:(nullable UIImage *)placeholderImage;
- (void)enterBrowserModeWithImageURLs:(nullable NSArray <NSString *>*)imageURLs
                                 smallImageURLs:(nullable NSArray <NSString *>*)smallImageURLs
                                defaultImageURL:(nullable NSString *)defaultImageURL
                               placeholderImage:(nullable UIImage *)placeholderImage
                                     imageViews:(nullable NSArray <UIImageView *> *)imageViews
                                  imageViewURLs:(nullable NSArray <NSString *>*)imageViewURLs;

@end

NS_ASSUME_NONNULL_END
