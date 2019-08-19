//
//  PhotonSafeMutableArray.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/28.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotonSafeMutableArray : NSObject
- (void)addObject:(id)anObject;

- (NSUInteger)count;

- (id)objectAtIndex:(NSUInteger)index;

- (void)removeObjectAtIndex:(NSUInteger)index;

- (void)removeAllObjects;

- (void)removeObject:(id) object;
@end

NS_ASSUME_NONNULL_END
