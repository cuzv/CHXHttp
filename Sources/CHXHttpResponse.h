//
//  CHXHttpResponse.h
//  CHXHttp
//
//  Created by Moch Xiao on 8/29/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#ifndef CHXHttpResponse_h
#define CHXHttpResponse_h

#import <Foundation/Foundation.h>

@protocol CHXHttpResponse <NSObject>

@required

- (nonnull NSString *)codeFieldName;
- (NSInteger)successCodeValue;
- (nonnull NSString *)messageFieldName;
- (nonnull NSString *)resultFieldName;

typedef NSDictionary<NSString *, NSObject *> *_Nonnull(^ResponseObjectSerializer)(_Nonnull id);
- (nonnull ResponseObjectSerializer)responseObjectSerializer;

@optional

- (BOOL)enableResponseLog;

@end



#endif /* CHXHttpResponse_h */
