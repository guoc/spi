//
//  UVSession.h
//  UserVoice
//
//  Created by UserVoice on 10/22/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVModelDelegate.h"

@class UVConfig;
@class UVClientConfig;
@class UVAccessToken;
@class UVRequestToken;
@class YOAuthConsumer;
@class UVSuggestion;
@class UVForum;

// Keeps track of data such as the user's login state, app configuration, etc.
// during the course of a single UserVoice session.
@interface UVSession : NSObject<UVModelDelegate> {
    UVUser *_user;
    YOAuthConsumer *_yOAuthConsumer;
}

@property (nonatomic, assign) BOOL isModal;
@property (nonatomic, retain) UVConfig *config;
@property (nonatomic, retain) UVClientConfig *clientConfig;
@property (nonatomic, retain) UVUser *user;
@property (nonatomic, retain) UVForum *forum;
@property (nonatomic, retain) UVAccessToken *accessToken;
@property (nonatomic, retain) UVRequestToken *requestToken;
@property (nonatomic, retain) NSMutableDictionary *externalIds;
@property (nonatomic, retain) NSArray *topics;
@property (nonatomic, retain) NSArray *articles;
@property (nonatomic, retain) NSString *flashTitle;
@property (nonatomic, retain) NSString *flashMessage;
@property (nonatomic, retain) UVSuggestion *flashSuggestion;

+ (UVSession *)currentSession;
- (YOAuthConsumer *)yOAuthConsumer;

- (void)setExternalId:(NSString *)identifier forScope:(NSString *)scope;
- (void)clear;

@end
