//
//  BaseApi.m
//  CHXHttp
//
//  Created by Moch Xiao on 8/29/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import "BaseApi.h"
#import "NSDataExtension.h"
#import "NSDictionary+Extension.h"
#import "NSString+MD5.h"

@interface BaseApi ()
@property (nonatomic, weak) id<AppHttpRules> proxy;
@end

@implementation BaseApi

#pragma mark - CHXHttpRequest

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if (![self conformsToProtocol:@protocol(AppHttpRules)]) {
        [NSException raise:@"MustConformsToProtocol"
                    format:@"Must conforms protocol %@.",
         NSStringFromProtocol(@protocol(AppHttpRules))];
    }
    
    _proxy = (id<AppHttpRules>)self;
    
    return self;
}

- (NSString *)url {
    return [@[self.proxy.host, self.proxy.moudle, @"v1", self.proxy.clazz, self.proxy.function] componentsJoinedByString:@"/"];
}

- (CHXHttpMethod)method {
    return CHXHttpMethodGet;
}

- (NSDictionary *)headers {
    return @{
    @"Client-Idcard": @"AC20B1F4-AB2E-4725-8872-4F9A2999B879",
    @"Client-System": @"ios-micro-buy",
    @"Client-App-Version": @"1.0.0",
    @"Client-Device-Model": @"Simulator",
    @"Client-System-Version": @"9.3",
    @"Member-Id": @"0",
    @"Member-Signature": @"",
    @"Data-Signature": self._chx_dataSignature,
    @"Belong-To-Shop-Id": @"14441"
    };
}

- (NSString *)_chx_dataSignature {
    NSMutableArray<NSString *> *arr = [@[NSLocalizedString(@"api_token", nil), @"v1", self.proxy.clazz, self.proxy.function] mutableCopy];
    if (self.bodies) {
        [arr addObject:self.bodies.queryString];
    }
    return [arr componentsJoinedByString:@"/"].MD5Digest;
}

- (NSDictionary *)bodies {
    return nil;
}

- (BOOL)enableRequestLog {
    return NO;
}

#pragma mark - CHXHttpResponse

- (NSString *)codeFieldName {
    return @"code";
}

- (NSInteger)successCodeValue {
    return 0;
}

- (NSString *)messageFieldName {
    return @"msg";
}

- (NSString *)resultFieldName {
    return  @"result";
}

- (ResponseObjectSerializer)responseObjectSerializer {
    return ^(id rep) {
        return [rep chx_JSONObject];
    };
}

- (BOOL)enableResponseLog {
    return NO;
}

#pragma mark - AppHttpRules

- (nonnull NSString *)host {
    return NSLocalizedString(@"your_host", nil);
}

- (nonnull NSString *)moudle {
    [NSException raise:@"Must Override Method"
                format:@"Class `%@` must override method `%@`",
     NSStringFromClass(self.class),
     NSStringFromSelector(_cmd)];
    return @"";
}

- (nonnull NSString *)clazz {
    [NSException raise:@"Must Override Method"
                format:@"Class `%@` must override method `%@`",
     NSStringFromClass(self.class),
     NSStringFromSelector(_cmd)];
    return @"";
}

- (nonnull NSString *)function {
    [NSException raise:@"Must Override Method"
                format:@"Class `%@` must override method `%@`",
     NSStringFromClass(self.class),
     NSStringFromSelector(_cmd)];
    return @"";
}


@end
