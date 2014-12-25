//
//  UVAccessToken.m
//  UserVoice
//
//  Created by Scott Rutherford on 16/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVAccessToken.h"
#import "UVRequestToken.h"
#import "YOAuthToken.h"
#import "UVSession.h"
#import "UVConfig.h"

#define KEY    @"uv-iphone-k"
#define SECRET @"uv-iphone-s"
#define GUID   @"uv-accesstoken-guid"

@implementation UVAccessToken

+ (BOOL)exists {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs stringForKey:KEY] != nil;
}

+ (BOOL)existsForGuid:(NSString *)guid {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [guid isEqualToString:[prefs stringForKey:GUID]] && [prefs stringForKey:KEY] != nil;
}

- (void)remove {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:KEY];
    [prefs removeObjectForKey:SECRET];
    [prefs removeObjectForKey:GUID];
    [prefs synchronize];
}


// check to see if a token exists on the device and if so load it
// if not get a request token from the api
- (id)initWithExisting {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [self initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [prefs stringForKey:KEY], @"oauth_token",
                                     [prefs stringForKey:SECRET], @"oauth_token_secret", nil]];
}

+ (id)getAccessTokenWithDelegate:(id<UVModelDelegate>)delegate andEmail:(NSString *)email andPassword:(NSString *)password {
    NSString *path = [[self class] apiPath:[NSString stringWithFormat:@"/oauth/authorize.json"]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            password, @"password",
                            email, @"email",
                            [UVSession currentSession].requestToken.oauthToken.key, @"request_token", nil];

    return [self getPath:path
              withParams:params
                  target:delegate
                selector:@selector(didRetrieveAccessToken:)
                 rootKey:@"token"];
}

- (void)persist {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:_oauthToken.key forKey:KEY];
    [prefs setObject:_oauthToken.secret forKey:SECRET];
    // if we were given a guid, use this access token until the guid changes
    if ([UVSession currentSession].config.guid) {
        [prefs setObject:[UVSession currentSession].config.guid forKey:GUID];
    }
    [prefs synchronize];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _oauthToken = [YOAuthToken tokenWithDictionary:dict];
    }
    return self;
}

@end
