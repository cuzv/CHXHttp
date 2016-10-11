//
//  CHXHttpEndpoint.h
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
- (nonnull __kindof CHXHttpEndpoint *)suspendRequest;
- (nonnull __kindof CHXHttpEndpoint *)resumeRequest;

- (nonnull __kindof CHXHttpEndpoint *)responseSuccess:(nonnull void(^)(__kindof CHXHttpEndpoint *_Nonnull endpoint, id _Nonnull result))successHandler;
- (nonnull __kindof CHXHttpEndpoint *)responseSuccess:(nonnull void(^)(__kindof CHXHttpEndpoint *_Nonnull endpoint, id _Nonnull result))successHandler deliverOnMainThread:(BOOL)deliverOnMainThread;

- (nonnull __kindof CHXHttpEndpoint *)responseFailure:(nonnull void(^)(__kindof CHXHttpEndpoint *_Nonnull endpoint, NSError *_Nonnull error))failureHandler;
- (nonnull __kindof CHXHttpEndpoint *)responseFailure:(nonnull void(^)(__kindof CHXHttpEndpoint *_Nonnull endpoint, NSError *_Nonnull error))failureHandler deliverOnMainThread:(BOOL)deliverOnMainThread;

/// `Get`: download progress, `POST`: upload progress.
/// **This callback runs in background thread.**
@property (nonatomic, copy, nullable) void (^progressHandler)(NSProgress * _Nullable);


@end
