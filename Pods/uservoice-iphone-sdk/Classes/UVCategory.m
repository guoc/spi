//
//  UVCategory.m
//  UserVoice
//
//  Created by UserVoice on 12/15/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVCategory.h"
#import "UVUtils.h"


@implementation UVCategory

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _categoryId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
        _name = [UVUtils decodeHTMLEntities:[self objectOrNilForDict:dict key:@"name"]];
    }
    return self;
}

@end
