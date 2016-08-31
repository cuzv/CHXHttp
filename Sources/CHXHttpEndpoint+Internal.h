//
//  CHXHttpEndpoint+Internal.h
//  CHXHttp
//
//  Created by Moch Xiao on 8/30/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHXHttpEndpointWrapper;
@interface CHXHttpEndpoint()

@property (nonatomic, strong, nullable) CHXHttpEndpointWrapper *wrapper;
- (void)requestComplete;

@end


@interface CHXHttpEndpointWrapper : NSObject

@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSObject *> *responseObject;
@property (nonatomic, strong, nullable) NSError *error;
@property (nonatomic, strong, nullable) NSURLSessionTask *sessionTask;

@property (nonatomic, weak, nullable) CHXHttpEndpoint *owner;
@end


#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif
