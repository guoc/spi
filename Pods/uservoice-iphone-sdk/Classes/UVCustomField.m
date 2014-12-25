//
//  UVCustomField.m
//  UserVoice
//
//  Created by UserVoice on 6/9/11.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//

#import "UVCustomField.h"
#import "UVSession.h"
#import "UVClientConfig.h"

@implementation UVCustomField

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _fieldId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
        _required = ![(NSNumber *)[self objectOrNilForDict:dict key:@"allow_blank"] boolValue];
        _name = [self objectOrNilForDict:dict key:@"name"];
        NSArray *valueDictionaries = [self objectOrNilForDict:dict key:@"possible_values"];
        NSMutableArray *valueNames = [NSMutableArray arrayWithCapacity:[valueDictionaries count]];
        for (NSDictionary *valueAttributes in valueDictionaries) {
            [valueNames addObject:[valueAttributes valueForKey:@"value"]];
        }
        _values = [NSArray arrayWithArray:valueNames];
    }
    return self;
}

- (BOOL)isPredefined {
    return [_values count] > 0;
}

- (BOOL)isRequired {
    return _required;
}

@end
