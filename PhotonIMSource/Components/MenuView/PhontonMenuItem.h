//
//  PhontonMenuItem.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/24.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface PhontonMenuItem : UIMenuItem

- (id)initWithTitle:(NSString *)title block:(void(^)(void))block;

@property(nonatomic, assign, getter=isEnabled) BOOL enabled;

@property(nonatomic, copy) void(^block)(void);

+ (void)installMenuHandlerForObject:(id)object;

@end

NS_ASSUME_NONNULL_END
