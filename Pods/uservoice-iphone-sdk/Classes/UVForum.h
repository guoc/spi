//
//  UVForum.h
//  UserVoice
//
//  Created by UserVoice on 11/23/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@interface UVForum : UVBaseModel

@property (nonatomic, assign) NSInteger forumId;
@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *prompt;
@property (nonatomic, assign) NSInteger suggestionsCount;
@property (nonatomic, retain) NSMutableArray *categories;
@property (nonatomic, retain) NSMutableArray *suggestions;

+ (id)getWithId:(int)forumId delegate:(id<UVModelDelegate>)delegate;

@end
