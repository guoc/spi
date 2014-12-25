//
//  YOAuthToken.m
//  YOAuth
//
//  Created by Zach Graves on 2/14/09.
//  Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//  
//  The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import "YOAuthToken.h"

@implementation YOAuthToken

#pragma mark init

+ (YOAuthToken *)tokenWithKey:(NSString *)aKey andSecret:(NSString *)aSecret {
    YOAuthToken *token = [[YOAuthToken alloc] initWithKey:aKey andSecret:aSecret];
    return token;
}

+ (YOAuthToken *)tokenWithDictionary:(NSDictionary *)aDictionary {
    YOAuthToken *token = [YOAuthToken tokenWithKey:[aDictionary valueForKey:@"oauth_token"] 
                                         andSecret:[aDictionary valueForKey:@"oauth_token_secret"]];

    //NSLog(@"Created token key: %@ secret: %@", token.key, token.secret);
    return token;
}

- (id)initWithKey:(NSString *)aKey andSecret:(NSString *)aSecret {
    if ((self = [super init])) {
        [self setKey:aKey];
        [self setSecret:aSecret];
    }

    return self;
}

@end
