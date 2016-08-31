//
//  CHXHttpProcessor.h
//  CHXHttp
//
//  Created by Moch Xiao on 8/30/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHXHttpEndpoint;
@protocol CHXHttpRequest;
@protocol CHXHttpResponse;

@interface CHXHttpProcessor : NSObject

+ (nonnull CHXHttpProcessor *)sharedInstance;

- (void)addEndpoint:(nonnull __kindof CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> *)endpoint;
- (void)removeEndpoint:(nonnull __kindof CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> *)endpoint;
- (void)suspendEndpoint:(nonnull __kindof CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> *)endpoint;
- (void)resumeEndpoint:(nonnull __kindof CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> *)endpoint;

@end
