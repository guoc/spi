//
//  UVHelpTopic.h
//  UserVoice
//
//  Created by Austin Taylor on 11/16/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseModel.h"

@interface UVHelpTopic : UVBaseModel

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) NSInteger topicId;
@property (nonatomic, assign) NSInteger articleCount;

+ (id)getAllWithDelegate:(id<UVModelDelegate>)delegate;
+ (id)getTopicWithId:(NSInteger)topicId delegate:(id<UVModelDelegate>)delegate;

@end
