//
//  UVSuggestion.h
//  UserVoice
//
//  Created by UserVoice on 10/27/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseModel.h"
#import "UVForum.h"
#import "UVCallback.h"

@class UVCategory;
@class UVUser;

@interface UVSuggestion : UVBaseModel

@property (nonatomic, assign) NSInteger suggestionId;
@property (nonatomic, assign) NSInteger forumId;
@property (nonatomic, assign) NSInteger commentsCount;
@property (nonatomic, assign) NSInteger subscriberCount;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *abstract;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *statusHexColor;
@property (nonatomic, retain) NSString *forumName;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSDate *closedAt;
@property (nonatomic, retain) NSString *creatorName;
@property (nonatomic, assign) NSInteger creatorId;
@property (nonatomic, retain) NSString *responseText;
@property (nonatomic, retain) NSString *responseUserName;
@property (nonatomic, retain) NSString *responseUserAvatarUrl;
@property (nonatomic, retain) NSString *responseUserTitle;
@property (nonatomic, retain) NSDate *responseCreatedAt;
@property (nonatomic, assign) NSInteger responseUserId;
@property (nonatomic, retain) UVCategory *category;
@property (nonatomic, readonly) UIColor *statusColor;
@property (nonatomic, readonly) NSString *categoryString;
@property (nonatomic, assign) BOOL subscribed;
@property (nonatomic, assign) NSInteger weight;
@property (nonatomic, assign) NSInteger rank;

// Retrieves a page (10 items) of suggestions.
+ (id)getWithForum:(UVForum *)forum page:(NSInteger)page delegate:(id<UVModelDelegate>)delegate;

// Retrieves the suggestions for the specified query.
+ (id)searchWithForum:(UVForum *)forum query:(NSString *)query delegate:(id<UVModelDelegate>)delegate;

// Creates a new suggestion with the specified title and text.
+ (id)createWithForum:(UVForum *)forum
             category:(NSInteger)categoryId
                title:(NSString *)title
                 text:(NSString *)text
             delegate:(id<UVModelDelegate>)delegate;

- (id)subscribe:(id<UVModelDelegate>)delegate;
- (id)unsubscribe:(id<UVModelDelegate>)delegate;

- (UIColor *)statusColor;
- (NSString *)responseUserWithTitle;
- (NSString *)rankString;

@end
