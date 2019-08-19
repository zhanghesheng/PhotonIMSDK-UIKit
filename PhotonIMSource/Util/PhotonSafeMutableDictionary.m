//
//  PhotonSafeMutableDictionary.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/28.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonSafeMutableDictionary.h"


@interface PhotonSafeMutableDictionary ()
@property(nonatomic, strong) NSMutableDictionary *mutableDictionary;
@property(nonatomic, strong) dispatch_queue_t cacheQueue;
@end

@implementation PhotonSafeMutableDictionary

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:100];
        //创建一个顺序执行的队列
        self.cacheQueue = dispatch_queue_create("com.deep.urlcache.queue",
                                                DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}


- (id)objectForKey:(id)aKey {
    if (!aKey) {
        return nil;
    }
    
    __block id obj = nil;
    __weak PhotonSafeMutableDictionary *instance = self;
    dispatch_sync(instance.cacheQueue, ^{
        obj = instance.mutableDictionary[aKey];
    });
    
    return obj;
}

- (void)removeObjectForKey:(id)aKey {
    if (!aKey) {
        return;
    }
    
    __weak PhotonSafeMutableDictionary *instance = self;
    dispatch_sync(instance.cacheQueue, ^{
        [instance.mutableDictionary removeObjectForKey:aKey];
    });
}


- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey {
    if (!anObject || !aKey) {
        return;
    }
    __weak PhotonSafeMutableDictionary *instance = self;
    dispatch_sync(instance.cacheQueue, ^{
        instance.mutableDictionary[aKey] = anObject;
    });
    
}

- (void)removeAllObjects {
    __weak PhotonSafeMutableDictionary *instance = self;
    dispatch_sync(instance.cacheQueue, ^{
        [instance.mutableDictionary removeAllObjects];
    });
}
@end
