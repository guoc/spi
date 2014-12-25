//
//  UVToken.h
//  UserVoice
//
//  Created by Scott Rutherford on 16/05/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@class YOAuthToken;

@interface UVAccessToken : UVBaseModel

@property (nonatomic, retain) YOAuthToken *oauthToken;

+ (BOOL)exists;
+ (BOOL)existsForGuid:(NSString *)guid;
+ (id)getAccessTokenWithDelegate:(id<UVModelDelegate>)delegate andEmail:(NSString *)email andPassword:(NSString *)password;

- (id)initWithExisting;
- (id)initWithDictionary:(NSDictionary *)dict;

- (void)persist;
- (void)remove;

@end
