//
//  UploadApi.m
//  CHXHttp
//
//  Created by Moch Xiao on 8/31/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import "UploadApi.h"

@interface UploadApi ()
@property (nonatomic, copy) NSArray<CHXHttpUploadElement *> *elements;
@end

@implementation UploadApi

- (instancetype)initWithElements:(NSArray<CHXHttpUploadElement *> *)elements {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _elements = elements;
    
    return self;
}

- (NSString *)url {
    return NSLocalizedString(@"upload_url", nil);
}

- (nonnull NSString *)moudle {
    return @"";
}

- (nonnull NSString *)clazz {
    return @"";
}

- (nonnull NSString *)function {
    return @"";
}


- (CHXHttpMethod)method {
    return CHXHttpMethodPost;
}

- (NSArray<CHXHttpUploadElement *> *)uploadElements {
    return self.elements;
}

@end
