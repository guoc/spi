//
//  UVConfig.m
//  UserVoice
//
//  Created by UserVoice on 10/19/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVConfig.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVAttachment.h"

@interface UVConfig ()

@property (nonatomic, strong) NSMutableArray *attachments;

@end

@implementation UVConfig

+ (UVConfig *)configWithSite:(NSString *)site {
    return [[UVConfig alloc] initWithSite:site andKey:nil andSecret:nil];
}

+ (UVConfig *)configWithSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret {
    return [[UVConfig alloc] initWithSite:site andKey:key andSecret:secret];
}

+ (UVConfig *)configWithSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret andSSOToken:(NSString *)token {
    return [[UVConfig alloc] initWithSite:site andKey:key andSecret:secret andSSOToken:token];
}

+ (UVConfig *)configWithSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret andEmail:(NSString *)email andDisplayName:(NSString *)displayName andGUID:(NSString *)guid {
    return [[UVConfig alloc] initWithSite:site andKey:key andSecret:secret andEmail:email andDisplayName:displayName andGUID:guid];
}

- (id)initWithSite:(NSString *)theSite andKey:(NSString *)theKey andSecret:(NSString *)theSecret {
    if (self = [super init]) {
        NSURL* url = [NSURL URLWithString:theSite];
        NSString* saneURL;
        if (url.host == nil) {
            saneURL = [NSString stringWithFormat:@"%@", url];
        } else {
            saneURL = [NSString stringWithFormat:@"%@", url.host];
        }

        _key = theKey;
        _site = saneURL;
        _secret = theSecret;
        _showForum = YES;
        _showPostIdea = YES;
        _showContactUs = YES;
        _showKnowledgeBase = YES;
    }
    return self;
}

- (NSInteger)forumId {
    return _forumId == 0 ? [UVSession currentSession].clientConfig.defaultForumId : _forumId;
}

- (NSDictionary *)traits {
    NSMutableDictionary *traits = [NSMutableDictionary dictionary];
    NSDictionary *accountTraits = [_userTraits objectForKey:@"account"];
    for (NSString *k in _userTraits) {
        if ([k isEqualToString:@"account"]) continue;
        [traits setObject:[NSString stringWithFormat:@"%@", [_userTraits objectForKey:k]] forKey:k];
    }
    for (NSString *k in accountTraits) {
        [traits setObject:[NSString stringWithFormat:@"%@", [accountTraits objectForKey:k]] forKey:[NSString stringWithFormat:@"account_%@", k]];
    }
    return traits;
}

- (BOOL)showForum {
    if ([UVSession currentSession].clientConfig && ![UVSession currentSession].clientConfig.feedbackEnabled)
        return NO;
    else
        return _showForum;
}

- (BOOL)showPostIdea {
    if ([UVSession currentSession].clientConfig && ![UVSession currentSession].clientConfig.feedbackEnabled)
        return NO;
    else
        return _showPostIdea;
}

- (BOOL)showContactUs {
    if ([UVSession currentSession].clientConfig && ![UVSession currentSession].clientConfig.ticketsEnabled)
        return NO;
    else
        return _showContactUs;
}

- (BOOL)showKnowledgeBase {
    if ([UVSession currentSession].clientConfig && ![UVSession currentSession].clientConfig.ticketsEnabled)
        return NO;
    else
        return _showKnowledgeBase;
}

- (void)identifyUserWithEmail:(NSString *)theEmail name:(NSString *)name guid:(NSString *)theGuid {
    _email = theEmail;
    _displayName = name;
    _guid = theGuid;
}

- (id)initWithSite:(NSString *)theSite andKey:(NSString *)theKey andSecret:(NSString *)theSecret andSSOToken:(NSString *)theToken {
    if (self = [self initWithSite:theSite andKey:theKey andSecret:theSecret]) {
        _ssoToken = theToken;
    }
    return self;
}

- (id)initWithSite:(NSString *)theSite andKey:(NSString *)theKey andSecret:(NSString *)theSecret andEmail:(NSString *)theEmail andDisplayName:(NSString *)theDisplayName andGUID:(NSString *)theGuid {
    if (self = [self initWithSite:theSite andKey:theKey andSecret:theSecret]) {
        _email = theEmail;
        _displayName = theDisplayName;
        _guid = theGuid;
    }
    return self;
}

- (void)addAttachmentNamed:(NSString *)fileName contentType:(NSString *)contentType base64EncodedData:(NSString *)data
{
    UVAttachment *attachment = [[UVAttachment alloc] init];
    attachment.fileName = fileName;
    attachment.contentType = contentType;
    attachment.base64EncodedData = data;
    
    if (! _attachments) {
        _attachments = [NSMutableArray array];
    }
    [_attachments addObject:attachment];
}

@end
