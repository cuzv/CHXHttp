//
//  CHXHttpResponse.h
//  Copyright (c) 2016 Roy Shaw (http://mochxiao.com).
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

#ifndef CHXHttpResponse_h
#define CHXHttpResponse_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CHXHttpDecoding) {
    CHXHttpDecodingForm,
    CHXHttpDecodingJson,
    CHXHttpDecodingPropertyList,
    CHXHttpDecodingXml,
    CHXHttpDecodingImage,
    CHXHttpDecodingCompound
};

typedef NSDictionary<NSString *, NSObject *> *_Nonnull(^DecodingHandler)(_Nonnull id);

@protocol CHXHttpResponse <NSObject>

@required

- (nonnull NSString *)codeFieldName;
- (NSInteger)successCodeValue;
- (nonnull NSString *)messageFieldName;
- (nonnull NSString *)resultFieldName;


@optional

- (CHXHttpDecoding)decoding;
/// Call after AF decoded if provided.
- (nonnull DecodingHandler)decodingResponse;
- (BOOL)enableResponseLog;

@end



#endif /* CHXHttpResponse_h */
