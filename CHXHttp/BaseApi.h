//
//  BaseApi.h
//  CHXHttp
//
//  Created by Moch Xiao on 8/29/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHXHttpEndpoint.h"
#import "CHXHttpRequest.h"
#import "CHXHttpResponse.h"


@protocol AppHttpRules <NSObject>

- (nonnull NSString *)host;
- (nonnull NSString *)moudle;
- (nonnull NSString *)clazz;
- (nonnull NSString *)function;

@end

@interface BaseApi : CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse, AppHttpRules>

@end
