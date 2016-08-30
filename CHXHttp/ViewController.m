//
//  ViewController.m
//  CHXHttp
//
//  Created by Moch Xiao on 8/29/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import "ViewController.h"
#import "CHXHttpEndpoint.h"
#import "LoginApi.h"
#import "AppStartApi.h"
#import "CHXHttpBatchTask.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self testApi];
//    [self testMultipleApi];
    [self testDownload];
}

- (void)testApi {
    LoginApi *login = [[[LoginApi alloc] initWithUsername:@"13488888888" password:@"111111"] startRequest];
    
    [login responseFailure:^(LoginApi *endpoint, NSError * _Nullable error) {
        NSLog(@"Error: %@", error);
    }];
    
    [login responseSuccess:^(__kindof CHXHttpEndpoint * _Nonnull endpoint, id  _Nullable obj) {
        NSLog(@"Json: %@", obj);
    }];
}

- (void)testMultipleApi {
    AppStartApi *start = [AppStartApi new];
    LoginApi *login = [[LoginApi alloc] initWithUsername:@"13488888888" password:@"111111"];
    
    login.progressHander = ^(NSProgress *progress) {
        NSLog(@"progress: %f", progress.completedUnitCount * 1.0f / progress.totalUnitCount * 1.0f );
    };
    
    CHXHttpBatchTask *batchTask = [[CHXHttpBatchTask alloc] initWithEndpoints:@[start, login]];
    [batchTask startRequest];
    
    [batchTask responseFailure:^(__kindof CHXHttpBatchTask * _Nonnull batchTask, NSError * _Nullable error) {
        NSLog(@"FILURE: %@", error);
    }];

    [batchTask responseSuccess:^(__kindof CHXHttpBatchTask * _Nonnull batchTask, NSArray<id> * _Nullable objs) {
        NSLog(@"SUCCESS: %@", objs);
    }];
    
}


- (void)testDownload {
    
}

@end
