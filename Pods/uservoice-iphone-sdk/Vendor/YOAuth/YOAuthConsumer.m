//
//  YOAuthConsumer.m
//  YOAuth
//
//  Created by Zach Graves on 2/14/09.
//  Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//  
//  The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import "YOAuthConsumer.h"


@implementation YOAuthConsumer

#pragma mark init

+ (YOAuthConsumer *)consumerWithKey:(NSString *)aKey andSecret:(NSString *)aSecret {
    YOAuthConsumer *consumer = [[YOAuthConsumer alloc] initWithKey:aKey andSecret:aSecret];
    return consumer;
}

- (id)initWithKey:(NSString *)aKey andSecret:(NSString *)aSecret {
    if ((self = [super init])) {
        [self setKey:aKey];
        [self setSecret:aSecret];
    }

    return self;
}

@end
