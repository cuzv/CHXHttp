//
//  CHXHttpBatchTask.m
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

#import "CHXHttpBatchTask.h"

@interface CHXHttpBatchTask ()
@property (nonatomic, copy, readwrite, nonnull) NSArray<CHXHttpEndpoint *> *endpoints;
@end

@implementation CHXHttpBatchTask

- (void)dealloc {
    NSLog(@"~~~~~~~~~~~%s~~~~~~~~~~~", __FUNCTION__);
}

- (nullable instancetype)initWithEndpoints:(nonnull NSArray<CHXHttpEndpoint *> *)endpoints; {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _endpoints = endpoints;
    
    return self;
}

- (nonnull __kindof CHXHttpBatchTask *)startRequest {
    for (CHXHttpEndpoint *endpoint in self.endpoints) {
        [endpoint startRequest];
    }
    return self;
}

- (nonnull __kindof CHXHttpBatchTask *)stopRequest {
    for (CHXHttpEndpoint *endpoint in self.endpoints) {
        [endpoint stopRequest];
    }
    return self;
}

- (nonnull __kindof CHXHttpBatchTask *)responseSuccess:(nonnull void(^)(__kindof CHXHttpBatchTask *_Nonnull batchTask, NSArray<id> *_Nullable results))successHandler {
    return [self responseSuccess:successHandler deliverOnMainThread:YES];
}

- (nonnull __kindof CHXHttpBatchTask *)responseSuccess:(nonnull void(^)(__kindof CHXHttpBatchTask *_Nonnull batchTask, NSArray<id> *_Nonnull results))successHandler deliverOnMainThread:(BOOL)deliverOnMainThread {
    NSMutableArray<id> *results = [NSMutableArray arrayWithCapacity:self.endpoints.count];
    for (NSInteger index = 0; index < self.endpoints.count; ++index) {
        [results addObject:[NSNull null]];
    }
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create(@"com.mochxiao.chxhttp.response.queue".UTF8String, DISPATCH_QUEUE_CONCURRENT);

    [self.endpoints enumerateObjectsUsingBlock:^(CHXHttpEndpoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(group);
        [obj responseSuccess:^(__kindof CHXHttpEndpoint * _Nonnull endpoint, id  _Nonnull obj) {
            results[idx] = obj;
            dispatch_group_leave(group);
        }];
    }];

    dispatch_group_notify(group, queue, ^{
        if (deliverOnMainThread) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successHandler(self, results);
            });
        } else {
            successHandler(self, results);
        }
    });
    
    return self;
}

- (nonnull __kindof CHXHttpBatchTask *)responseFailure:(nonnull void(^)(__kindof CHXHttpBatchTask *_Nonnull batchTask, NSError *_Nonnull error))failureHandler {
    return [self responseFailure:failureHandler deliverOnMainThread:YES];
}

- (nonnull __kindof CHXHttpBatchTask *)responseFailure:(nonnull void(^)(__kindof CHXHttpBatchTask *_Nonnull batchTask, NSError *_Nonnull error))failureHandler deliverOnMainThread:(BOOL)deliverOnMainThread {
    [self.endpoints enumerateObjectsUsingBlock:^(CHXHttpEndpoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj responseFailure:^(__kindof CHXHttpEndpoint * _Nonnull endpoint, NSError * _Nonnull error) {
            if (endpoint.success) {
                return;
            }
            if (deliverOnMainThread) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   failureHandler(self, error);
                });
            } else {
                failureHandler(self, error);
            }
            *stop = YES;
        }];
    }];
    
    return self;

}


@end
