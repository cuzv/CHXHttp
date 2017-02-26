//
//  CHXHttpBatchTask.h
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
#import "CHXHttpEndpoint.h"

@interface CHXHttpBatchTask : NSObject

@property (nonatomic, copy, readonly, nonnull) NSArray<CHXHttpEndpoint *> *endpoints;
- (nullable instancetype)initWithEndpoints:(nonnull NSArray<CHXHttpEndpoint *> *)endpoints;

- (nonnull __kindof CHXHttpBatchTask *)startRequest;
- (nonnull __kindof CHXHttpBatchTask *)stopRequest;

- (nonnull __kindof CHXHttpBatchTask *)responseSuccess:(nonnull void(^)(__kindof CHXHttpBatchTask *_Nonnull batchTask, NSArray<id> *_Nonnull results))successHandler;
- (nonnull __kindof CHXHttpBatchTask *)responseSuccess:(nonnull void(^)(__kindof CHXHttpBatchTask *_Nonnull batchTask, NSArray<id> *_Nonnull results))successHandler deliverOnMainThread:(BOOL)deliverOnMainThread;

- (nonnull __kindof CHXHttpBatchTask *)responseFailure:(nonnull void(^)(__kindof CHXHttpBatchTask *_Nonnull batchTask, NSArray<NSError *> *_Nonnull errors))failureHandler;
- (nonnull __kindof CHXHttpBatchTask *)responseFailure:(nonnull void(^)(__kindof CHXHttpBatchTask *_Nonnull batchTask, NSArray<NSError *> *_Nonnull errors))failureHandler deliverOnMainThread:(BOOL)deliverOnMainThread;


@end
