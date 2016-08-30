//
//  LoginApi.h
//  CHXHttp
//
//  Created by Moch Xiao on 8/29/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseApi.h"

@interface LoginApi : BaseApi

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password;

@end
