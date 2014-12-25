//
//  UVRequestToken.h
//  UserVoice
//
//  Created by Austin Taylor on 10/23/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseModel.h"

@class YOAuthToken;

@interface UVRequestToken : UVBaseModel

@property (nonatomic, retain) YOAuthToken *oauthToken;

+ (id)getRequestTokenWithDelegate:(id<UVModelDelegate>)delegate;
- (id)initWithDictionary:(NSDictionary *)dict;

@end
