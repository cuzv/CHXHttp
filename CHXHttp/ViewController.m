//
//  ViewController.m
//  CHXHttp
//
//  Created by Moch Xiao on 8/29/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import "ViewController.h"
#import "CHXHttp.h"
#import "LoginApi.h"
#import "AppStartApi.h"
#import "CHXHttpBatchTask.h"
#import "DownloadApi.h"
#import "UploadApi.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, copy) NSData *downloadedData;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.progressView.progress = 0;
}

- (IBAction)handleApiAction:(UIButton *)sender {
    LoginApi *login = [[[LoginApi alloc] initWithUsername:@"13488888888" password:@"111111"] startRequest];
    
    [login responseFailure:^(LoginApi *endpoint, NSError * _Nullable error) {
        NSLog(@"Error: %@", error);
    }];
    [login responseSuccess:^(__kindof CHXHttpEndpoint * _Nonnull endpoint, id  _Nullable result) {
        NSLog(@"Json: %@", result);
    }];
}

- (IBAction)handleMultipleApiAction:(UIButton *)sender {
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

    [batchTask responseSuccess:^(__kindof CHXHttpBatchTask * _Nonnull batchTask, NSArray<id> * _Nullable results) {
        NSLog(@"SUCCESS: %@", results);
    }];
    
}

- (IBAction)handleDownloadAction:(UIButton *)sender {
    DownloadApi *download = [DownloadApi new];
    self.progressView.progress = 0;
    download.progressHander = ^(NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress.completedUnitCount * 1.0f / progress.totalUnitCount * 1.0f;
        });
    };
    [download startRequest];
    [download responseSuccess:^(__kindof CHXHttpEndpoint * _Nonnull endpoint, id  _Nonnull result) {
        NSLog(@"SUCCESS: %@", result);
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:result]];
        self.downloadedData = data;
        self.imageView.image = [UIImage imageWithData:data];
    }];
    [download responseFailure:^(__kindof CHXHttpEndpoint * _Nonnull endpoint, NSError * _Nonnull error) {
        NSLog(@"FILURE: %@", error);
    }];
}

- (IBAction)handleUploadAction:(UIButton *)sender {
    CHXHttpUploadElement *element0 = [[CHXHttpUploadElement alloc] initWithData:self.downloadedData
                                                                           name:@"file[]"
                                                                       fileName:@"test_345909034.png"
                                                                       mimeType:@"image/jpeg"];
    UploadApi *upload = [[UploadApi alloc] initWithElements:@[element0]];
    self.progressView.progress = 0;
    upload.progressHander =  ^(NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress.completedUnitCount * 1.0f / progress.totalUnitCount * 1.0f;
        });
    };
    [upload startRequest];
    [upload responseSuccess:^(__kindof CHXHttpEndpoint * _Nonnull endpoint, id  _Nonnull result) {
        NSLog(@"SUCCESS: %@", result);
    }];
    [upload responseFailure:^(__kindof CHXHttpEndpoint * _Nonnull endpoint, NSError * _Nonnull error) {
        NSLog(@"FILURE: %@", error);
    }];
}

@end
