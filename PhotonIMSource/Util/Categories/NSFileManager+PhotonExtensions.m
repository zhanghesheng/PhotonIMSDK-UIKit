//
//  NSFileManager+Extensions.m
//  PhotonIM
//
//  Created by Bruce on 2019/6/25.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "NSFileManager+PhotonExtensions.h"

@implementation NSFileManager(PhotonExtensions)
+ (NSURL *)URLForDirectory:(NSSearchPathDirectory)directory
{
    return [self.defaultManager URLsForDirectory:directory inDomains:NSUserDomainMask].lastObject;
}

+ (NSString *)pathForDirectory:(NSSearchPathDirectory)directory
{
    return NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES)[0];
}

+ (NSURL *)documentsURL
{
    return [self URLForDirectory:NSDocumentDirectory];
}

+ (NSString *)documentsPath
{
    return [self pathForDirectory:NSDocumentDirectory];
}

+ (NSURL *)libraryURL
{
    return [self URLForDirectory:NSLibraryDirectory];
}

+ (NSString *)libraryPath
{
    return [self pathForDirectory:NSLibraryDirectory];
}

+ (NSURL *)cachesURL
{
    return [self URLForDirectory:NSCachesDirectory];
}

+ (NSString *)cachesPath
{
    return [self pathForDirectory:NSCachesDirectory];
}

+ (float)photonDeepSearchFolderSize:(NSString*)path
{
    __block unsigned long long folderSize = 0;
    [self enumerateFolderPath:path UsingBlock:^(NSString *fileName, NSString *fullPath, NSUInteger idx, BOOL isDir) {
        if (isDir) {
            folderSize += [self photonDeepSearchFolderSize:fullPath];
        } else {
            NSDictionary *fileAttributeDic = [self.defaultManager attributesOfItemAtPath:fullPath error:NULL];
            folderSize += fileAttributeDic.fileSize;
        }
    }];
    return folderSize;
}
+ (void)enumerateFolderPath:(NSString *)path UsingBlock:(void (^)(NSString *fileName, NSString *fullPath, NSUInteger idx, BOOL isDir))block
{
    NSArray *tempArray = [self.defaultManager contentsOfDirectoryAtPath:path error:nil];
    [tempArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *fileName = obj;
        BOOL isDir;
        NSString *fullPath = [path stringByAppendingPathComponent:fileName];
        if ([self.defaultManager fileExistsAtPath:fullPath isDirectory:&isDir]) {
            block(fileName, fullPath, idx, isDir);
        }
    }];
}
@end
