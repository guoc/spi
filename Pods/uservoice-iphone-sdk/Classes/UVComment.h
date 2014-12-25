//
//  UVComment.h
//  UserVoice
//
//  Created by UserVoice on 11/11/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@class UVSuggestion;

@interface UVComment : UVBaseModel

@property (nonatomic, assign) NSInteger commentId;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, retain) NSString *avatarUrl;
@property (nonatomic, assign) NSInteger karmaScore;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, assign) NSInteger updatedCommentCount;

+ (id)getWithSuggestion:(UVSuggestion *)suggestion page:(NSInteger)page delegate:(id<UVModelDelegate>)delegate;
+ (id)createWithSuggestion:(UVSuggestion *)suggestion text:(NSString *)text delegate:(id<UVModelDelegate>)delegate;

@end
