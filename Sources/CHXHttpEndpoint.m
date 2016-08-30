//
//  CHXHttpEndpoint.m
//  CHXHttp
//
//  Created by Moch Xiao on 8/29/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import "CHXHttpEndpoint.h"
#import "CHXHttpEndpoint+Internal.h"
#import "CHXHttpRequest.h"
#import "CHXHttpResponse.h"
#import "CHXHttpProcessor.h"

#pragma mark - CHXHttpEndpointWrapper

@implementation CHXHttpEndpointWrapper

- (void)dealloc {
    NSLog(@"~~~~~~~~~~~%s~~~~~~~~~~~", __FUNCTION__);
}

- (instancetype)initWithOwner:(CHXHttpEndpoint *)owner {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _owner = owner;
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"
            "class: %@\ncode: %@\nmessage: %@\nresult: %@"
            "\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n",
            NSStringFromClass(self.owner.class),
            @(self.owner.code),
            self.owner.message,
            self.owner.result];
}

- (NSString *)debugDescription {
    return self.description;
}

@end


#pragma mark - CHXHttpUploadElement

@implementation CHXHttpUploadElement

- (instancetype)initWithData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _data = data;
    _name = name;
    _fileName = fileName;
    _mimeType = mimeType;
    
    return self;
}

@end

#pragma mark - CHXHttpEndpoint

@interface CHXHttpEndpoint()
@property (nonatomic, weak) CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> *proxy;
/// The event notify queue
@property (nonatomic, strong, nonnull) dispatch_queue_t queue;
@end

@implementation CHXHttpEndpoint

- (void)dealloc {
    NSLog(@"~~~~~~~~~~~%s~~~~~~~~~~~", __FUNCTION__);
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 必须实现 @protocol(CHXHttpRequest) 和 @protocol(CHXHttpResponse)
    if (![self conformsToProtocol:@protocol(CHXHttpRequest)] ||
        ![self conformsToProtocol:@protocol(CHXHttpResponse)]) {
        [NSException raise:@"MustConformsToProtocol"
                    format:@"Must conforms protocol %@ and %@.",
         NSStringFromProtocol(@protocol(CHXHttpRequest)),
         NSStringFromProtocol(@protocol(CHXHttpResponse))];
    }
    
    _proxy = (CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> *)self;
    _wrapper = [[CHXHttpEndpointWrapper alloc] initWithOwner:self];
    _queue = ({
        NSString *label = [NSString stringWithFormat:@"com.mochxiao.chxhttp.queue-%zd", self.hash];
        dispatch_queue_t queue = dispatch_queue_create(label.UTF8String, DISPATCH_QUEUE_CONCURRENT);
        dispatch_suspend(queue);
        queue;
    });
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"
            "class: %@\nurl: %@\nheaders: %@\nbodies: %@"
            "\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n",
            NSStringFromClass(self.class),
            self.proxy.url,
            self.proxy.headers,
            self.proxy.bodies];
}

- (NSString *)debugDescription {
    return self.description;
}

- (NSUInteger)hash {
    return self.proxy.url.hash + self.proxy.headers.hash + self.proxy.bodies.hash;
}

- (BOOL)isEqual:(id)object {
    if (![object isMemberOfClass:self.class]) {
        return NO;
    }
    if (object == self) {
        return YES;
    }
    
    CHXHttpEndpoint *obj = (CHXHttpEndpoint *)object;
    if (![obj.proxy.url isEqualToString:self.proxy.url]) {
        return NO;
    }
    if (![obj.proxy.headers isEqual:self.proxy.headers]) {
        return NO;
    }
    if (![obj.proxy.bodies isEqual:self.proxy.bodies]) {
        return NO;
    }
    return YES;
}

- (void)requestComplete {
    if ([self.proxy respondsToSelector:@selector(enableResponseLog)] && self.proxy.enableResponseLog) {
        NSLog(@"%@", self.wrapper);
    }
    dispatch_resume(self.queue);
}

#pragma mark - Methods

- (nonnull __kindof CHXHttpEndpoint *)startRequest {
    [[CHXHttpProcessor sharedInstance] addEndpoint:self.proxy];
    if ([self.proxy respondsToSelector:@selector(enableRequestLog)] && self.proxy.enableRequestLog) {
        NSLog(@"%@", self);
    }
    return self;
}

- (nonnull __kindof CHXHttpEndpoint *)stopRequest {
    [[CHXHttpProcessor sharedInstance] removeEndpoint:self.proxy];
    return self;
}

- (nonnull __kindof CHXHttpEndpoint *)responseSuccess:(nonnull void(^)(__kindof CHXHttpEndpoint *_Nonnull endpoint, id _Nonnull obj))successHandler {
    return [self responseSuccess:successHandler deliverOnMainThread:YES];
}

- (nonnull __kindof CHXHttpEndpoint *)responseSuccess:(nonnull void(^)(__kindof CHXHttpEndpoint *_Nonnull endpoint, id _Nonnull obj))successHandler deliverOnMainThread:(BOOL)deliverOnMainThread {
    dispatch_async(self.queue, ^{
        if (!self.proxy.success) {
            return;
        }
        if (deliverOnMainThread) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successHandler(self, self.proxy.result);
            });
        } else {
            successHandler(self, self.proxy.result);
        }
    });
    return self;
}

- (nonnull __kindof CHXHttpEndpoint *)responseFailure:(nonnull void(^)(__kindof CHXHttpEndpoint *_Nonnull endpoint, NSError *_Nonnull error))failureHandler {
    return [self responseFailure:failureHandler deliverOnMainThread:YES];
}

- (nonnull __kindof CHXHttpEndpoint *)responseFailure:(nonnull void(^)(__kindof CHXHttpEndpoint *_Nonnull endpoint, NSError *_Nonnull error))failureHandler deliverOnMainThread:(BOOL)deliverOnMainThread {
    dispatch_async(self.queue, ^{
        if (self.proxy.success) {
            return;
        }
        if (deliverOnMainThread) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failureHandler(self, self.proxy.error);
            });
        } else {
            failureHandler(self, self.proxy.error);
        }
    });
    return self;
}


#pragma mark - CHXHttpEndpoint

- (NSInteger)code {
    if (self.responseObject) {
        return [(id)self.responseObject[self.proxy.codeFieldName] integerValue];
    }
    return self.proxy.error.code;
}

- (nullable NSString *)message {
    if (self.responseObject) {
        return (NSString *)self.responseObject[self.proxy.messageFieldName];
    }
    return self.proxy.error.localizedDescription;
}

- (nullable id)result {
    return self.responseObject[self.proxy.resultFieldName];
}

- (BOOL)success {
    return self.proxy.code == self.proxy.successCodeValue;
}

- (nullable NSDictionary<NSString *, NSObject *> *)responseObject {
    return self.wrapper.responseObject;
}

- (nullable NSError *)error {
    return self.wrapper.error;
}

- (nullable NSURLSessionTask *)sessionTask {
    return self.wrapper.sessionTask;
}



@end
