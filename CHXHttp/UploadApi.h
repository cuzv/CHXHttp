//
//  UploadApi.h
//  CHXHttp
//
//  Created by Moch Xiao on 8/31/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import "BaseApi.h"

@interface UploadApi : BaseApi

- (instancetype)initWithElements:(NSArray<CHXHttpUploadElement *> *)elements;

@end
