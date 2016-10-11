//
//  DownloadApi.m
//  Copyright (c) 2016 Moch Xiao (http://mochxiao.com).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
