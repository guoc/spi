//
//  UVSubdomain.m
//  UserVoice
//
//  Created by Scott Rutherford on 28/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVSubdomain.h"

@implementation UVSubdomain

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _subdomainId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
        _name = [self objectOrNilForDict:dict key:@"name"];
        _host = [self objectOrNilForDict:dict key:@"host"];
        _key = [self objectOrNilForDict:dict key:@"key"];
        _defaultSort = [self objectOrNilForDict:dict key:@"default_sort"];
    }
    return self;
}

- (NSString *)suggestionSort {
    if ([_defaultSort isEqualToString:@"new"])
        return @"newest";
    else if ([_defaultSort isEqualToString:@"hot"])
        return @"hot";
    else
        return @"votes";
}

@end
