//
//  CHXHttpRequest.h
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

#ifndef CHXHttpRequest_h
#define CHXHttpRequest_h

#import <Foundation/Foundation.h>

@interface CHXHttpUploadElement : NSObject

@property (nonatomic, readonly, copy, nonnull) NSData *data;
@property (nonatomic, readonly, copy, nonnull) NSString *name;
@property (nonatomic, readonly, copy, nonnull) NSString *fileName;
@property (nonatomic, readonly, copy, nonnull) NSString *mimeType;

- (nullable instancetype)initWithData:(nonnull NSData *)data name:(nonnull NSString *)name fileName:(nonnull NSString *)fileName mimeType:(nonnull NSString *)mimeType;

@end

typedef NS_ENUM(NSInteger, CHXHttpMethod) {
    CHXHttpMethodGet,
    CHXHttpMethodPost,
    CHXHttpMethodPut,
    CHXHttpMethodHead,
    CHXHttpMethodPatch,
    CHXHttpMethodDelete
};

@protocol CHXHttpRequest <NSObject>

@required

- (nonnull NSString *)url;
- (CHXHttpMethod)method;
- (nullable NSDictionary *)headers;
- (nullable NSDictionary *)bodies;

@optional

/// Default value `10s`
- (NSTimeInterval)timeoutIntervalForRequest;
- (BOOL)enableRequestLog;

// Upload
- (nonnull NSArray<CHXHttpUploadElement *> *)uploadElements;

// Download
- (nullable NSData *)resumeData;
- (nonnull NSURL *)destinationWithTargetPath:(nonnull NSURL *)targetPath response:(nonnull NSURLResponse *)response;

@end

#endif /* CHXHttpRequest_h */
