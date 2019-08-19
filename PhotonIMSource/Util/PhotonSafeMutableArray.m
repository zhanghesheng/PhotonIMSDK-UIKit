//
//  PhotonSafeMutableArray.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/28.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonSafeMutableArray.h"

@interface PhotonSafeMutableArray ()
@property(nonatomic, strong) NSMutableArray *mutableArray;
@property(nonatomic, strong) dispatch_queue_t cacheQueue;
@end

@implementation PhotonSafeMutableArray

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mutableArray = [NSMutableArray arrayWithCapacity:100];
        //创建一个顺序执行的队列
        self.cacheQueue = dispatch_queue_create("com.deep.urlcache.queue",
                                                DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (NSUInteger)count {
    __block NSUInteger countRet = 0;
    __weak PhotonSafeMutableArray *instance = self;
    dispatch_sync(instance.cacheQueue, ^{
        countRet = [instance.mutableArray count];
    });
    
    return countRet;
}


- (void)addObject:(id)anObject {
    if (!anObject) {
        return;
    }
    __weak PhotonSafeMutableArray *instance = self;
    dispatch_sync(instance.cacheQueue, ^{
        [instance.mutableArray addObject:anObject];
    });
}

- (id)objectAtIndex:(NSUInteger)index {
    __weak PhotonSafeMutableArray *instance = self;
    __block id obj = nil;
    dispatch_sync(instance.cacheQueue, ^{
        obj = instance.mutableArray[index];
    });
    
    return obj;
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    __weak PhotonSafeMutableArray *instance = self;
    dispatch_sync(instance.cacheQueue, ^{
        [instance.mutableArray removeObjectAtIndex:index];
    });
}

- (void)removeAllObjects {
    __weak PhotonSafeMutableArray *instance = self;
    
    dispatch_sync(instance.cacheQueue, ^{
        [instance.mutableArray removeAllObjects];
    });
}

- (void)removeObject:(id)object {
    __weak PhotonSafeMutableArray *instance = self;
    
    dispatch_sync(instance.cacheQueue, ^{
        [instance.mutableArray removeObject:object];
    });
}
@end
