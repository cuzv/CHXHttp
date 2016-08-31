//
//  CHXHttpBatchTask.h
//  CHXHttp
//
//  Created by Moch Xiao on 8/29/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
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

- (nonnull __kindof CHXHttpBatchTask *)responseFailure:(nonnull void(^)(__kindof CHXHttpBatchTask *_Nonnull batchTask, NSError *_Nonnull error))failureHandler;
- (nonnull __kindof CHXHttpBatchTask *)responseFailure:(nonnull void(^)(__kindof CHXHttpBatchTask *_Nonnull batchTask, NSError *_Nonnull error))failureHandler deliverOnMainThread:(BOOL)deliverOnMainThread;


@end
