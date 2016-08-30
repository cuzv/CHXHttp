//
//  CHXHttpEndpoint.h
//  CHXHttp
//
//  Created by Moch Xiao on 8/29/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CHXHttpEndpoint <NSObject>


- (NSInteger)code;
- (nullable NSString *)message;
- (nullable id)result;

- (BOOL)success;

- (nullable NSDictionary<NSString *, NSObject *> *)responseObject;
- (nullable NSError *)error;
- (nullable NSURLSessionTask *)sessionTask;

@end

/// 作为 API 类的父类使用
/// 子类必须实现 <CHXHttpRequest, CHXHttpResponse> 协议
@interface CHXHttpEndpoint : NSObject <CHXHttpEndpoint>

- (nonnull __kindof CHXHttpEndpoint *)startRequest;
- (nonnull __kindof CHXHttpEndpoint *)stopRequest;

- (nonnull __kindof CHXHttpEndpoint *)responseSuccess:(nonnull void(^)(__kindof CHXHttpEndpoint *_Nonnull endpoint, id _Nonnull obj))successHandler;
- (nonnull __kindof CHXHttpEndpoint *)responseSuccess:(nonnull void(^)(__kindof CHXHttpEndpoint *_Nonnull endpoint, id _Nonnull obj))successHandler deliverOnMainThread:(BOOL)deliverOnMainThread;

- (nonnull __kindof CHXHttpEndpoint *)responseFailure:(nonnull void(^)(__kindof CHXHttpEndpoint *_Nonnull endpoint, NSError *_Nonnull error))failureHandler;
- (nonnull __kindof CHXHttpEndpoint *)responseFailure:(nonnull void(^)(__kindof CHXHttpEndpoint *_Nonnull endpoint, NSError *_Nonnull error))failureHandler deliverOnMainThread:(BOOL)deliverOnMainThread;

/// `Get`: download progress, `POST`: upload progress.
@property (nonatomic, copy, nullable) void (^progressHander)(NSProgress * _Nullable);


@end
