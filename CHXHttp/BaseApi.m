//
//  BaseApi.m
//  Copyright (c) 2016 Roy Shaw (http://mochxiao.com).
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
    @"Client-App-Version": @"1.1.0",
    @"Client-Device-Model": @"Simulator",
    @"Client-System-Version": @"9.3",
    @"Member-Id": @"859",
    @"Member-Signature": @"3ca0f10a1e5839a2a59b08048469ff59",
    @"Data-Signature": self._chx_dataSignature,
    @"Belong-To-Shop-Id": @"859"
    };
}

- (NSString *)_chx_dataSignature {
    NSMutableArray<NSString *> *arr = [@[NSLocalizedString(@"api_token", nil), @"v1", self.proxy.clazz, self.proxy.function] mutableCopy];
    NSMutableString *str = [[NSMutableString alloc] initWithString:[arr componentsJoinedByString:@"/"]];
    if (self.bodies) {
        [str appendString:self.bodies.queryString];
    }
    return str.MD5Digest;
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

- (nonnull DecodingHandler)decodingResponse {
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
