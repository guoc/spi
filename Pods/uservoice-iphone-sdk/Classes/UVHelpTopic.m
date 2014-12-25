//
//  UVHelpTopic.m
//  UserVoice
//
//  Created by Austin Taylor on 11/16/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVHelpTopic.h"
#import "UVUtils.h"

@implementation UVHelpTopic

+ (id)getAllWithDelegate:(id<UVModelDelegate>)delegate {
    NSString *path = [self apiPath:@"/topics.json"];
    return [self getPath:path
              withParams:nil
                  target:delegate
                selector:@selector(didRetrieveHelpTopics:)
                 rootKey:@"topics"];
}

+ (id)getTopicWithId:(NSInteger)topicId delegate:(id<UVModelDelegate>)delegate {
    NSString *path = [self apiPath:[NSString stringWithFormat:@"/topics/%d.json", (int)topicId]];
    return [self getPath:path
              withParams:nil
                  target:delegate
                selector:@selector(didRetrieveHelpTopic:)
                 rootKey:@"topic"];
}


- (id)initWithDictionary:(NSDictionary *)dict {
    if ((self = [super init])) {
        _topicId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
        _name = [UVUtils decodeHTMLEntities:[self objectOrNilForDict:dict key:@"name"]];
        _articleCount = [(NSNumber *)[dict objectForKey:@"article_count"] integerValue];
    }
    return self;
}

@end
