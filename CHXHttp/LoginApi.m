//
//  LoginApi.m
//  CHXHttp
//
//  Created by Moch Xiao on 8/29/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import "LoginApi.h"

@implementation LoginApi

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _username = username;
    _password = password;
    
    return self;
}


- (NSDictionary *)bodies {
    return @{@"userName": self.username,
             @"password": self.password};
}

- (CHXHttpMethod)method {
    return CHXHttpMethodPost;
}

#pragma mark - AppHttpRules

- (nonnull NSString *)moudle {
    return @"item";
}

- (nonnull NSString *)clazz {
    return @"User";
}

- (nonnull NSString *)function {
    return @"login";
}


@end
