//
//  CHXHttpProcessor.m
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

#import "CHXHttpProcessor.h"
#import "CHXHttpEndpoint.h"
#import "CHXHttpEndpoint+Internal.h"
#import "CHXHttpRequest.h"
#import "CHXHttpResponse.h"
#import "AFNetworking.h"

// synchronized
#define SYNCHRONIZED(...) dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(self->_lock);

@implementation CHXHttpProcessor {
    @private
    NSMutableSet<CHXHttpEndpoint *> *_tasks;
    dispatch_semaphore_t _lock;
}

+ (nonnull CHXHttpProcessor *)sharedInstance {
    static dispatch_once_t pred;
    static CHXHttpProcessor *singleton;
    dispatch_once(&pred, ^{
        dispatch_semaphore_t lock = dispatch_semaphore_create(1);
        NSMutableSet<CHXHttpEndpoint *> *tasks = [NSMutableSet new];
        singleton = [[self alloc] initWithLock:lock tasks:tasks];
    });
    return singleton;
}

- (instancetype)initWithLock:(dispatch_semaphore_t)lock tasks:(NSMutableSet<CHXHttpEndpoint *> *)tasks {
    self = [super init];
    if (!self) {
        return nil;
    }
    _lock = lock;
    _tasks = tasks;
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"CHXHttpProcessor init error" reason:@"Use 'sharedInstance' to get instance." userInfo:nil];
    return [super init];
}

- (void)addEndpoint:(nonnull __kindof CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> *)endpoint {
    SYNCHRONIZED([_tasks addObject:endpoint];)
    if (![_tasks containsObject:endpoint]) {
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer = _chx_requestSerializer(endpoint);
    requestSerializer.timeoutInterval = _chx_timeout(endpoint);
    [endpoint.headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    manager.requestSerializer = requestSerializer;
    
    manager.responseSerializer = _chx_responseSerializer(endpoint);
    
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
                                                   progress:endpoint.progressHandler
                                                destination:destination
                                          completionHandler:completionHandler];
                    [endpoint.wrapper.sessionTask resume];
                } else {
                    NSURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET"
                                                                               URLString:endpoint.url
                                                                              parameters:endpoint.bodies
                                                                                   error:nil];
                    endpoint.wrapper.sessionTask =
                        [manager downloadTaskWithRequest:request
                                                progress:endpoint.progressHandler
                                             destination:destination
                                       completionHandler:completionHandler];
                    [endpoint.wrapper.sessionTask resume];
                }
            } else {
                endpoint.wrapper.sessionTask =
                    [manager GET:endpoint.url
                      parameters:endpoint.bodies
                        progress:endpoint.progressHandler
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
                         progress:endpoint.progressHandler
                          success:success
                          failure:failure];
            } else {
                endpoint.wrapper.sessionTask =
                    [manager POST:endpoint.url
                       parameters:endpoint.bodies
                         progress:endpoint.progressHandler
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
    if ([endpoint respondsToSelector:@selector(timeout)]) {
        return endpoint.timeout;
    }
    return 10;
}

AFHTTPRequestSerializer <AFURLRequestSerialization> *_chx_requestSerializer(__kindof CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> * _Nonnull endpoint) {
    if ([endpoint respondsToSelector:@selector(encoding)]) {
        CHXHttpEncoding encodgin = [endpoint encoding];
        switch (encodgin) {
            case CHXHttpEncodingJson:
                return [AFJSONRequestSerializer serializer];
            case CHXHttpEncodingPropertyList:
                return [AFPropertyListRequestSerializer serializer];
            default:
                break;
        }
    }
    return [AFHTTPRequestSerializer serializer];
}

AFHTTPResponseSerializer <AFURLResponseSerialization> *_chx_responseSerializer(__kindof CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> * _Nonnull endpoint) {
    if ([endpoint respondsToSelector:@selector(decoding)]) {
        CHXHttpDecoding decoding = [endpoint decoding];
        switch (decoding) {
            case CHXHttpDecodingJson:
                return [AFJSONResponseSerializer serializer];
            case CHXHttpDecodingPropertyList:
                return [AFPropertyListResponseSerializer serializer];
            case CHXHttpDecodingXml:
                return [AFXMLParserResponseSerializer serializer];
            case CHXHttpDecodingImage:
                return [AFImageResponseSerializer serializer];
            case CHXHttpDecodingCompound:
                return [AFCompoundResponseSerializer serializer];
            default:
                break;
        }
    }
    return [AFHTTPResponseSerializer serializer];
}

- (void)removeEndpoint:(nonnull __kindof CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> *)endpoint {
    if (![_tasks containsObject:endpoint]) {
        return;
    }
    SYNCHRONIZED([_tasks removeObject:endpoint];);
    [endpoint.wrapper.sessionTask cancel];
}

- (void)suspendEndpoint:(nonnull __kindof CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> *)endpoint {
    if (![_tasks containsObject:endpoint]) {
        return;
    }
    [endpoint.wrapper.sessionTask suspend];
}

- (void)resumeEndpoint:(nonnull __kindof CHXHttpEndpoint<CHXHttpRequest, CHXHttpResponse> *)endpoint {
    if (![_tasks containsObject:endpoint]) {
        return;
    }
    [endpoint.wrapper.sessionTask resume];
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
    
    NSDictionary<NSString *, NSObject *> *dic = endpoint.decodingResponse(responseObject);
    if (!dic) {
        NSError *error = _chx_makeError(-1023, @"Server Response Data Deserialize Failed.");
        _chx_handleFailure(receiver, endpoint, error);
        return;
    }
    endpoint.wrapper.responseObject = dic;
    
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
