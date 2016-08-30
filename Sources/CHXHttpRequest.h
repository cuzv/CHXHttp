//
//  CHXHttpRequest.h
//  CHXHttp
//
//  Created by Moch Xiao on 8/29/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
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
