//
//  DownloadApi.m
//  CHXHttp
//
//  Created by Moch Xiao on 8/31/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import "DownloadApi.h"

@implementation DownloadApi


- (NSString *)url {
    return @"http://img.haioo.com/7dcdoJnA7cAZF1qTlhTb5yup_OleHO9rK-AouPhub1a32CipxpIWtovkv7eqnSdDx0e4kEMZGxETzP9pMvkpLVR8KOjoQc35";
}

- (nonnull NSString *)moudle {
    return @"";
}

- (nonnull NSString *)clazz {
    return @"";
}

- (nonnull NSString *)function {
    return @"";
}

- (CHXHttpMethod)method {
    return CHXHttpMethodGet;
}

- (BOOL)enableRequestLog {
    return YES;
}

- (BOOL)enableResponseLog {
    return YES;
}

- (NSURL *)destinationWithTargetPath:(NSURL *)targetPath response:(NSURLResponse *)response {
    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *destination = [documents stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [NSUUID UUID].UUIDString]];
    return [NSURL fileURLWithPath:destination];
}

@end
