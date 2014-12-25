//
//  UVRequestToken.m
//  UserVoice
//
//  Created by Austin Taylor on 10/23/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVRequestToken.h"
#import "YOAuthToken.h"
#import "UVSession.h"
#import "UVConfig.h"

@implementation UVRequestToken

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _oauthToken = [YOAuthToken tokenWithDictionary:dict];
    }
    return self;
}

+ (id)getRequestTokenWithDelegate:(id<UVModelDelegate>)delegate {
    NSString *path = [[self class] apiPath:[NSString stringWithFormat:@"/oauth/request_token.json"]];
    
    return [self getPath:path
              withParams:nil
                  target:delegate
                selector:@selector(didRetrieveRequestToken:)
                 rootKey:@"token"
                 context:@"request-token"];
}

@end
