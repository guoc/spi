//
//  UVUser.h
//  UserVoice
//
//  Created by UserVoice on 10/26/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@class UVSuggestion;

@protocol UVUserDelegate;

@interface UVUser : UVBaseModel

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;

+ (id)forgotPassword:(NSString *)email delegate:(id<UVModelDelegate>)delegate;

// discover
+ (id)discoverWithEmail:(NSString *)email delegate:(id<UVModelDelegate>)delegate;

// create
+ (id)findOrCreateWithEmail:(NSString *)anEmail andName:(NSString *)aName andDelegate:(id<UVModelDelegate>)delegate;
+ (id)findOrCreateWithGUID:(NSString *)aGUID andEmail:(NSString *)anEmail andName:(NSString *)aName andDelegate:(id<UVModelDelegate>)delegate;
+ (id)findOrCreateWithSsoToken:(NSString *)aToken delegate:(id<UVModelDelegate>)delegate;
+ (id)retrieveCurrentUser:(id<UVModelDelegate>)delegate;

// update
- (id)identify:(NSString *)externalId withScope:(NSString *)externalScope delegate:(id<UVModelDelegate>)delegate;

@end

