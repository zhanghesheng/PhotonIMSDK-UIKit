//
//  PhotonDownloadFileReceipt.m
//  PhotonIM
//
//  Created by Bruce on 2019/7/4.
//  Copyright © 2019 Bruce. All rights reserved.
//

#import "PhotonDownloadFileReceipt.h"

@interface PhotonDownloadFileReceipt()
@end

@implementation PhotonDownloadFileReceipt
- (NSProgress *)progress {
    if (_progress == nil) {
        _progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    }
    _progress.totalUnitCount = self.totalBytesExpectedToWrite;
    _progress.completedUnitCount = self.totalBytesWritten;
    return _progress;
}

- (instancetype)initWithURL:(NSString *)url{
    if (self = [self init]) {
        self.url = url;
        self.totalBytesExpectedToWrite = 1;
    }
    return self;
}


#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.object forKey:NSStringFromSelector(@selector(object))];
    [aCoder encodeObject:self.url forKey:NSStringFromSelector(@selector(url))];
    [aCoder encodeObject:self.filePath forKey:NSStringFromSelector(@selector(filePath))];
    [aCoder encodeObject:@(self.state) forKey:NSStringFromSelector(@selector(state))];
    [aCoder encodeObject:self.filename forKey:NSStringFromSelector(@selector(filename))];
    [aCoder encodeObject:@(self.totalBytesWritten) forKey:NSStringFromSelector(@selector(totalBytesWritten))];
    [aCoder encodeObject:@(self.totalBytesExpectedToWrite) forKey:NSStringFromSelector(@selector(totalBytesExpectedToWrite))];
    [aCoder encodeObject:self.resumeData forKey:NSStringFromSelector(@selector(resumeData))];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.object = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(object))];
        self.url = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(url))];
        self.filePath = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(filePath))];
        self.state = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(state))] unsignedIntegerValue];
        self.filename = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(filename))];
        self.totalBytesWritten = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(totalBytesWritten))] unsignedIntegerValue];
        self.totalBytesExpectedToWrite = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(totalBytesExpectedToWrite))] unsignedIntegerValue];
        self.resumeData = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(resumeData))];
    }
    return self;
}
@end
