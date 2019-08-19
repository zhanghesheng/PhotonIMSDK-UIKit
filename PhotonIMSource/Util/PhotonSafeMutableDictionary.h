//
//  PhotonSafeMutableDictionary.h
//  PhotonIM
//
//  Created by Bruce on 2019/6/28.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotonSafeMutableDictionary : NSObject
- (id)objectForKey:(id)aKey;

- (void)removeObjectForKey:(id)aKey;

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;

- (void)removeAllObjects;
@end

NS_ASSUME_NONNULL_END
