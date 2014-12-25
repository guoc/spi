//
//  UVUser.m
//  UserVoice
//
//  Created by UserVoice on 10/26/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVUser.h"
#import "UVRequestToken.h"
#import "UVSuggestion.h"
#import "UVSession.h"
#import "YOAuthToken.h"
#import "UVConfig.h"
#import "UVClientConfig.h"
#import "UVForum.h"
#import "UVUtils.h"

@implementation UVUser

+ (id)discoverWithEmail:(NSString *)email delegate:(id<UVModelDelegate>)delegate {
    NSString *path = [self apiPath:@"/users/discover.json"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: email, @"email", nil];
    return [self getPath:path
              withParams:params
                  target:delegate
                selector:@selector(didDiscoverUser:)
                 rootKey:@"user"];
}

+ (id)retrieveCurrentUser:(id<UVModelDelegate>)delegate {
    NSString *path = [self apiPath:@"/users/current.json"];
    return [self getPath:path
              withParams:nil
                  target:delegate
                selector:@selector(didRetrieveCurrentUser:)
                 rootKey:@"user"];
}

// only called when instigated by the user, creates a global user
+ (id)findOrCreateWithEmail:(NSString *)anEmail andName:(NSString *)aName andDelegate:(id<UVModelDelegate>)delegate {
    NSString *path = [self apiPath:@"/users.json"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            aName == nil ? @"" : aName, @"user[display_name]",
                            anEmail == nil ? @"" : anEmail, @"user[email]",
                            [UVSession currentSession].requestToken.oauthToken.key, @"request_token",
                            nil];
    return [self postPath:path
               withParams:params
                   target:delegate
                 selector:@selector(didCreateUser:)
                  rootKey:@"user"];
}

// two methods for creating with the client, create local users
+ (id)findOrCreateWithGUID:(NSString *)aGUID andEmail:(NSString *)anEmail andName:(NSString *)aName andDelegate:(id<UVModelDelegate>)delegate {
    NSString *path = [self apiPath:@"/users/find_or_create.json"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            aGUID, @"user[guid]",
                            aName == nil ? @"" : aName, @"user[display_name]",
                            anEmail == nil ? @"" : anEmail, @"user[email]",
                            [UVSession currentSession].requestToken.oauthToken.key, @"request_token",
                            nil];
    return [self postPath:path
              withParams:params
                  target:delegate
                selector:@selector(didCreateUser:)
                 rootKey:@"user"
                 context:@"local-sso"];
}

+ (id)findOrCreateWithSsoToken:(NSString *)aToken delegate:(id<UVModelDelegate>)delegate {
    NSString *path = [self apiPath:@"/users/find_or_create.json"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            aToken, @"sso",
                            [UVSession currentSession].requestToken.oauthToken.key, @"request_token",
                            nil];
    return [self postPath:path
               withParams:params
                   target:delegate
                 selector:@selector(didCreateUser:)
                  rootKey:@"user"
                  context:@"sso"];
}

+ (id)forgotPassword:(NSString *)email delegate:(id<UVModelDelegate>)delegate {
    NSString *path = [self apiPath:@"/users/forgot_password.json"];
    NSDictionary *params = @{@"user[email]" : email};
    return [self getPath:path
              withParams:params
                  target:delegate
                selector:@selector(didSendForgotPassword:)
                 rootKey:@"user"];
}

- (id)identify:(NSString *)externalId withScope:(NSString *)externalScope delegate:(id<UVModelDelegate>)delegate {
    NSString *path = [UVUser apiPath:@"/users/identify.json"];
    NSDictionary *payload = @{
        @"external_scope" : externalScope,
        @"upsert" : [NSNumber numberWithBool:TRUE],
        @"identifications" : @[
            @{
                @"id" : [NSString stringWithFormat:@"%d", (int)_userId],
                @"external_id" : externalId
            }
        ]
    };
    
    return [[self class] putPath:path
                        withJSON:payload
                          target:delegate
                        selector:@selector(didIdentifyUser:)
                         rootKey:@"identifications"];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _userId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
        _name = [UVUtils decodeHTMLEntities:[self objectOrNilForDict:dict key:@"name"]];
        _email = [self objectOrNilForDict:dict key:@"email"];
    }
    return self;
}

@end
