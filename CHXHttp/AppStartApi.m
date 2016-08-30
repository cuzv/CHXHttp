//
//  AppStartApi.m
//  CHXHttp
//
//  Created by Moch Xiao on 8/30/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import "AppStartApi.h"

@implementation AppStartApi


- (CHXHttpMethod)method {
    return CHXHttpMethodGet;
}

#pragma mark - AppHttpRules

- (nonnull NSString *)moudle {
    return @"item";
}

- (nonnull NSString *)clazz {
    return @"AppManager";
}

- (nonnull NSString *)function {
    return @"appStart";
}


@end
