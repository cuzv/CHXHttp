//
//  CHXHttpProcessor.m
//  CHXHttp
//
//  Created by Moch Xiao on 8/30/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import "CHXHttpProcessor.h"
#import "CHXHttpEndpoint.h"
#import "CHXHttpEndpoint+Internal.h"
#import "CHXHttpRequest.h"
#import "CHXHttpResponse.h"
#import "AFNetworking.h"

@interface CHXHttpProcessor()
@property (nonatomic, strong) NSMutableSet<CHXHttpEndpoint *> *tasks;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@end

@implementation CHXHttpProcessor

+ (nonnull CHXHttpProcessor *)sharedInstance {
    static dispatch_once_t pred;
    static CHXHttpProcessor *singleton = nil;
    
    dispatch_once(&pred, ^{
        singleton = [CHXHttpProcessor new];
    });
    
    return singleton;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _tasks = [NSMutableSet new];
    
    return self;
}

- (void)addEndpoint:(nonnull __kindof CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> *)endpoint {
    [self.tasks addObject:endpoint];

    // 开启请求
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.operationQueue.maxConcurrentOperationCount = 10;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = _chx_timeout(endpoint);
    
    [endpoint.headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    
    
    @weakify(endpoint);
    void (^success)(NSURLSessionDataTask *, id) = ^(NSURLSessionDataTask *task, id responseObject) {
        @strongify(endpoint);
        _chx_handleSuccess(self, endpoint, responseObject);
    };
    void (^failure)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
        @strongify(endpoint);
        _chx_handleFailure(self, endpoint, error);
    };
    switch (endpoint.method) {
        case CHXHttpMethodGet: {
            if ([endpoint respondsToSelector:@selector(destinationWithTargetPath:response:)]) {
                NSURL *(^destination)(NSURL *, NSURLResponse *) = ^ NSURL *(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    @strongify(endpoint);
                    return [endpoint destinationWithTargetPath:targetPath response:response];
                };
                void (^completionHandler)(NSURLResponse *, NSURL *, NSError *) = ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                    @strongify(endpoint);
                    if (error) {
                        _chx_handleFailure(self, endpoint, error);
                    } else {
                        _chx_handlerEmptyResponseSuccess(self, endpoint, @"SUCCESS", filePath.absoluteString);
                    }
                };
                
                if ([endpoint respondsToSelector:@selector(resumeData)] && endpoint.resumeData) {
                    endpoint.wrapper.sessionTask =
                        [manager downloadTaskWithResumeData:endpoint.resumeData
                                                   progress:endpoint.progressHander
                                                destination:destination
                                          completionHandler:completionHandler];
                } else {
                    NSURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET"
                                                                               URLString:endpoint.url
                                                                              parameters:endpoint.bodies
                                                                                   error:nil];
                    endpoint.wrapper.sessionTask =
                        [manager downloadTaskWithRequest:request
                                                progress:endpoint.progressHander
                                             destination:destination
                                       completionHandler:completionHandler];
                }
            } else {
                endpoint.wrapper.sessionTask =
                    [manager GET:endpoint.url
                      parameters:endpoint.bodies
                        progress:endpoint.progressHander
                         success:success
                         failure:failure];
            }
        }
            break;
        case CHXHttpMethodPost: {
            if ([endpoint respondsToSelector:@selector(uploadElements)]) {
                void (^constructingBody)(id<AFMultipartFormData>) = ^(id<AFMultipartFormData>  _Nonnull formData) {
                    for (CHXHttpUploadElement *element in endpoint.uploadElements) {
                        [formData appendPartWithFileData:element.data
                                                    name:element.name
                                                fileName:element.fileName
                                                mimeType:element.mimeType];
                    }
                };
                endpoint.wrapper.sessionTask =
                    [manager POST:endpoint.url
                       parameters:endpoint.bodies
        constructingBodyWithBlock:constructingBody
                         progress:endpoint.progressHander
                          success:success
                          failure:failure];
            } else {
                endpoint.wrapper.sessionTask =
                    [manager POST:endpoint.url
                       parameters:endpoint.bodies
                         progress:endpoint.progressHander
                          success:success
                          failure:failure];
            }
        }
            break;
        case CHXHttpMethodPut: {
            endpoint.wrapper.sessionTask =
                [manager PUT:endpoint.url
                  parameters:endpoint.bodies
                     success:success
                     failure:failure];
        }
            break;
        case CHXHttpMethodHead: {
            endpoint.wrapper.sessionTask =
                [manager HEAD:endpoint.url
                   parameters:endpoint.bodies
                      success:^(NSURLSessionDataTask * _Nonnull task) {
                          @strongify(endpoint);
                          _chx_handlerEmptyResponseSuccess(self, endpoint, @"SUCCESS", @{});
                      } failure:failure];
        }
            break;
        case CHXHttpMethodPatch: {
            endpoint.wrapper.sessionTask =
                [manager PATCH:endpoint.url
                    parameters:endpoint.bodies
                       success:success
                       failure:failure];
        }
            break;
        case CHXHttpMethodDelete: {
            endpoint.wrapper.sessionTask =
                [manager DELETE:endpoint.url
                     parameters:endpoint.bodies
                        success:success
                        failure:failure];
        }
            break;
    }
}

NSTimeInterval _chx_timeout(__kindof CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> * _Nonnull endpoint) {
    if ([endpoint respondsToSelector:@selector(timeoutIntervalForRequest)]) {
        return endpoint.timeoutIntervalForRequest;
    }
    return 10;
}

- (void)removeEndpoint:(nonnull __kindof CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> *)endpoint {
    [endpoint.wrapper.sessionTask cancel];
    [self.tasks removeObject:endpoint];
}

#pragma mark - Handle result

void _chx_handleSuccess(CHXHttpProcessor *_Nonnull receiver,
                        __kindof CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> *_Nonnull endpoint,
                        id _Nullable responseObject)
{
    if (!responseObject && endpoint.method != CHXHttpMethodHead) {
        NSError *error = _chx_makeError(-1024, @"Server Response No Data.");
        _chx_handleFailure(receiver, endpoint, error);
        return;
    }
    
    NSDictionary<NSString *, NSObject *> *dict = endpoint.responseObjectSerializer(responseObject);
    if (!dict) {
        NSError *error = _chx_makeError(-1023, @"Server Response Data Deserialize Failed.");
        _chx_handleFailure(receiver, endpoint, error);
        return;
    }
    endpoint.wrapper.responseObject = dict;
    
    if (!endpoint.success) {
        NSError *error = _chx_makeError(endpoint.code, endpoint.message ?: @"Empty Error Message.");
        _chx_handleFailure(receiver, endpoint, error);
        return;
    }
    
    [endpoint requestComplete];
    
    [receiver removeEndpoint:endpoint];
}

void _chx_handlerEmptyResponseSuccess(CHXHttpProcessor *_Nonnull receiver,
                                      __kindof CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> *_Nonnull endpoint,
                                      NSString *_Nonnull message,
                                      id result)
{
    endpoint.wrapper.responseObject = @{endpoint.codeFieldName:@(endpoint.successCodeValue),
                                        endpoint.messageFieldName:message,
                                        endpoint.resultFieldName:result};
    [endpoint requestComplete];
    
    [receiver removeEndpoint:endpoint];
}

void _chx_handleFailure(CHXHttpProcessor *_Nonnull receiver,
                        __kindof CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> *_Nonnull endpoint,
                        NSError * _Nonnull error)
{
    endpoint.wrapper.error = error;
    
    [endpoint requestComplete];
    
    [receiver removeEndpoint:endpoint];
}

NSError * _chx_makeError(NSInteger code, NSString *message)
{
    return [NSError errorWithDomain:@"com.mochxiao.chxhttp.error" code:code userInfo:@{NSLocalizedFailureReasonErrorKey:message, NSLocalizedDescriptionKey:message}];
}

@end
