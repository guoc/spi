//
//  UVSession.m
//  UserVoice
//
//  Created by UserVoice on 10/22/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVSession.h"
#import "UVConfig.h"
#import "UVStyleSheet.h"
#import "YOAuth.h"
#import "UVClientConfig.h"
#import "UVForum.h"
#import "UVSubdomain.h"
#import "UVUtils.h"
#import "UVUser.h"
#import <stdlib.h>

@implementation UVSession

+ (UVSession *)currentSession {
    static UVSession *currentSession;
    @synchronized(self) {
        if (!currentSession) {
            currentSession = [UVSession new];
        }
    }

    return currentSession;
}

- (BOOL)loggedIn {
    return _user != nil;
}

- (UVUser *)user {
    return _user;
}

- (void)setUser:(UVUser *)newUser {
    _user = newUser;
    if (_user && _externalIds) {
        for (NSString *scope in _externalIds) {
            NSString *identifier = [_externalIds valueForKey:scope];
            [_user identify:identifier withScope:scope delegate:self];
        }
    }
}

- (void)setClientConfig:(UVClientConfig *)newConfig {
    _clientConfig = newConfig;
}

- (void)setExternalId:(NSString *)identifier forScope:(NSString *)scope {
    if (_externalIds == nil) {
        _externalIds = [NSMutableDictionary dictionary];
    }
    [_externalIds setObject:identifier forKey:scope];
    if (_user) {
        [_user identify:identifier withScope:scope delegate:self];
    }
}

- (void)didIdentifyUser:(UVUser *)user {
    // nothing to do
}

// This is used when dismissing UV so that everything gets reloaded
- (void)clear {
    _requestToken = nil;
    _user = nil;
    _clientConfig = nil;
    _yOAuthConsumer = nil;
}

- (YOAuthConsumer *)yOAuthConsumer {
    if (!_yOAuthConsumer) {
        if (_config.key != nil) {
            _yOAuthConsumer = [[YOAuthConsumer alloc] initWithKey:_config.key andSecret:_config.secret];
        } else if (_clientConfig != nil) {
            _yOAuthConsumer = [[YOAuthConsumer alloc] initWithKey:_clientConfig.key andSecret:_clientConfig.secret];
        }
    }
    return _yOAuthConsumer;
}

@end
