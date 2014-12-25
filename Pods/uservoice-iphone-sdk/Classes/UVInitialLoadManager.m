//
//  UVInitialLoadManager.m
//  UserVoice
//
//  Created by Austin Taylor on 12/10/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVInitialLoadManager.h"
#import "UserVoice.h"
#import "UVHelpTopic.h"
#import "UVArticle.h"
#import "UVAccessToken.h"
#import "UVRequestToken.h"
#import "UVClientConfig.h"
#import "UVConfig.h"
#import "UVUser.h"
#import "UVSession.h"
#import "UVRequestContext.h"
#import "UVUtils.h"
#import "UVForum.h"
#import "UVBabayaga.h"
#import "UVBaseViewController.h"

@implementation UVInitialLoadManager {
    UIAlertView *_errorAlertView;
    BOOL _complete;
}

+ (UVInitialLoadManager *)loadWithDelegate:(id)delegate action:(SEL)action {
    UVInitialLoadManager *manager = [[UVInitialLoadManager alloc] initWithDelegate:delegate action:action];
    [manager beginLoad];
    return manager;
}

- (id)initWithDelegate:(id)theDelegate action:(SEL)theAction {
    if (self = [super init]) {
        _delegate = theDelegate;
        _action = theAction;
    }
    return self;
}

- (void)beginLoad {
    if ([UVSession currentSession].clientConfig) {
        [self didLoadClientConfig];
    } else {
        [UVClientConfig getWithDelegate:self];
    }
}

- (void)loadUser {
    if ([UVSession currentSession].config.ssoToken != nil || ([UVSession currentSession].config.guid != nil && ![UVAccessToken existsForGuid:[UVSession currentSession].config.guid])) {
        [UVRequestToken getRequestTokenWithDelegate:self];
    } else if ([UVAccessToken exists]) {
        [UVSession currentSession].accessToken = [[UVAccessToken alloc] initWithExisting];
        [UVUser retrieveCurrentUser:self];
    } else {
        [self didLoadUser];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)checkComplete {
    @synchronized(self) {
        if (_configDone && _userDone && _topicsDone && _articlesDone && _forumDone) {
            if (_dismissed || _complete) return;
            _complete = YES;
            [_delegate performSelector:_action];
        }
    }
}
#pragma clang diagnostic pop
 
- (void)didRetrieveRequestToken:(UVRequestToken *)token {
    if (_dismissed) return;
    [UVSession currentSession].requestToken = token;
    if ([UVSession currentSession].config.ssoToken != nil) {
        [UVUser findOrCreateWithSsoToken:[UVSession currentSession].config.ssoToken delegate:self];
    } else if ([UVSession currentSession].config.guid != nil) {
        [UVUser findOrCreateWithGUID:[UVSession currentSession].config.guid andEmail:[UVSession currentSession].config.email andName:[UVSession currentSession].config.displayName andDelegate:self];
    } else {
        // this should never happen
        [self didLoadUser];
    }
}

- (void)didRetrieveClientConfig:(UVClientConfig *)clientConfig {
    if (_dismissed) return;
    [UVSession currentSession].clientConfig = clientConfig;
    [self didLoadClientConfig];
}

- (void)didLoadClientConfig {
    UVClientConfig *clientConfig = [UVSession currentSession].clientConfig;
    _configDone = YES;
    [self loadUser];
    if (clientConfig.ticketsEnabled) {
        if ([UVSession currentSession].config.topicId) {
            [UVHelpTopic getTopicWithId:[UVSession currentSession].config.topicId delegate:self];
            [UVArticle getArticlesWithTopicId:[UVSession currentSession].config.topicId page:1 delegate:self];
        } else {
            [UVHelpTopic getAllWithDelegate:self];
            [UVArticle getArticlesWithPage:1 delegate:self];
        }
    } else {
        _topicsDone = YES;
        _articlesDone = YES;
    }
    [self checkComplete];
}

- (void)didRetrieveForum:(UVForum *)forum {
    if (_dismissed) return;
    [UVSession currentSession].forum = forum;
    _forumDone = YES;
    [self checkComplete];
}

- (void)didCreateUser:(UVUser *)theUser {
    if (_dismissed) return;
    [UVSession currentSession].user = theUser;
    [[UVSession currentSession].accessToken persist];
    [UVBabayaga track:IDENTIFY];
    [self didLoadUser];
}

- (void)didRetrieveCurrentUser:(UVUser *)theUser {
    if (_dismissed) return;
    [UVSession currentSession].user = theUser;
    [[UVSession currentSession].accessToken persist];
    [self didLoadUser];
}

- (void)didLoadUser {
    _userDone = YES;
    if ([UVSession currentSession].clientConfig.feedbackEnabled) {
        [UVForum getWithId:(int)[UVSession currentSession].config.forumId delegate:self];
    } else {
        _forumDone = YES;
    }
    [self checkComplete];
}

- (void)didRetrieveHelpTopic:(UVHelpTopic *)topic {
    if (_dismissed) return;
    [UVSession currentSession].topics = @[topic];
    _topicsDone = YES;
    [self checkComplete];
}

- (void)didRetrieveHelpTopics:(NSArray *)topics {
    if (_dismissed) return;
    [UVSession currentSession].topics = [topics filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"articleCount > 0"]];
    _topicsDone = YES;
    [self checkComplete];
}

- (void)didRetrieveArticles:(NSArray *)articles {
    if (_dismissed) return;
    [UVSession currentSession].articles = articles;
    _articlesDone = YES;
    [self checkComplete];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [_delegate performSelector:@selector(dismiss)];
}

- (void)didReceiveError:(NSError *)error context:(UVRequestContext *)requestContext {
    if (_dismissed) return;
    NSString *message = nil;
    if ([UVUtils isAuthError:error]) {
        if ([requestContext.context isEqualToString:@"sso"] || [requestContext.context isEqualToString:@"local-sso"]) {
          // SSO and local SSO can fail with regard to admins. It's ok to proceed without a user.
          [self didLoadUser];
          return;
        }
        if ([UVAccessToken exists]) {
            [[UVSession currentSession].accessToken remove];
            [UVSession currentSession].accessToken = nil;
            [self loadUser];
            return;
        } else {
            message = NSLocalizedStringFromTableInBundle(@"This application didn't configure UserVoice properly", @"UserVoice", [UserVoice bundle], nil);
        }
    } else if ([UVUtils isConnectionError:error]) {
        message = NSLocalizedStringFromTableInBundle(@"There appears to be a problem with your network connection, please check your connectivity and try again.", @"UserVoice", [UserVoice bundle], nil);
    } else {
        message = NSLocalizedStringFromTableInBundle(@"Sorry, there was an error in the application.", @"UserVoice", [UserVoice bundle], nil);
    }
    
    if (_errorAlertView) {
        return;
    }
    
    _errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Error", @"UserVoice", [UserVoice bundle], nil)
                                                 message:message
                                                delegate:self
                                       cancelButtonTitle:nil
                                       otherButtonTitles:NSLocalizedStringFromTableInBundle(@"OK", @"UserVoice", [UserVoice bundle], nil), nil];
    [_errorAlertView show];
}

- (void)dealloc {
    if (_errorAlertView) {
        _errorAlertView.delegate = nil;
    }
}


@end
