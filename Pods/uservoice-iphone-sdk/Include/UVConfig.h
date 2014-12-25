//
//  UVConfig.h
//  UserVoice
//
//  Created by UserVoice on 10/19/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UVConfig : NSObject

+ (UVConfig *)configWithSite:(NSString *)site;

// deprecated
+ (UVConfig *)configWithSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret;
+ (UVConfig *)configWithSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret andSSOToken:(NSString *)token;
+ (UVConfig *)configWithSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret andEmail:(NSString *)email andDisplayName:(NSString *)displayName andGUID:(NSString *)guid;

@property (nonatomic, retain) NSString *site;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *secret;
@property (nonatomic, retain) NSString *ssoToken;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *guid;
@property (nonatomic, retain) NSDictionary *customFields;
@property (nonatomic, assign) NSInteger topicId;
@property (nonatomic, assign) NSInteger forumId;
@property (nonatomic, assign) BOOL showForum;
@property (nonatomic, assign) BOOL showPostIdea;
@property (nonatomic, assign) BOOL showContactUs;
@property (nonatomic, assign) BOOL showKnowledgeBase;
@property (nonatomic, retain) NSString* extraTicketInfo;
@property (nonatomic, retain) NSDictionary *userTraits;

- (void)identifyUserWithEmail:(NSString *)email name:(NSString *)name guid:(NSString *)guid;

// merged user and account traits
- (NSDictionary *)traits;

- (void)addAttachmentNamed:(NSString *)fileName
               contentType:(NSString *)contentType
         base64EncodedData:(NSString *)data;

- (NSArray *)attachments;

@end
