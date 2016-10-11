//
//  ViewController.m
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
    LoginApi *login = [[[LoginApi alloc] initWithUsername:@"18583221776" password:@"111111"] startRequest];
    
    [login responseFailure:^(LoginApi *endpoint, NSError * _Nullable error) {
        NSLog(@"Error: %@", error);
    }];
    [login responseSuccess:^(__kindof CHXHttpEndpoint * _Nonnull endpoint, id  _Nullable result) {
        NSLog(@"Json: %@", result);
    }];
}

- (IBAction)handleMultipleApiAction:(UIButton *)sender {
    AppStartApi *start = [AppStartApi new];
    LoginApi *login = [[LoginApi alloc] initWithUsername:@"18583221776" password:@"111111"];
    
    login.progressHandler = ^(NSProgress *progress) {
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
    download.progressHandler = ^(NSProgress *progress) {
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
    upload.progressHandler =  ^(NSProgress *progress) {
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
