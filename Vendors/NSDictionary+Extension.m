//
//  NSDictionary+Extension.m
//  CHXHttp
//
//  Created by Roy Shaw on 8/30/16.
//  Copyright © 2016 Roy Shaw. All rights reserved.
//

#import "NSDictionary+Extension.h"

@implementation NSDictionary (Extension)

- (NSString *)queryString {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.allKeys.count];
    for (id key in self.allKeys) {
        [arr addObject:[NSString stringWithFormat:@"%@=%@", key, [self objectForKey:key]]];
    }
    return [arr componentsJoinedByString:@"&"];
}

@end
