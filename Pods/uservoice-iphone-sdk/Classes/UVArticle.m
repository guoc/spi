//
//  UVArticle.m
//  UserVoice
//
//  Created by Austin Taylor on 5/8/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVArticle.h"
#import "UVSuggestion.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVForum.h"
#import "UVHelpTopic.h"
#import "UVConfig.h"
#import "UVUtils.h"

@implementation UVArticle

+ (id)getArticlesWithTopicId:(NSInteger)topicId page:(NSInteger)page delegate:(id<UVModelDelegate>)delegate {
    NSString *path = [self apiPath:[NSString stringWithFormat:@"/topics/%d/articles.json", (int)topicId]];
    NSDictionary *params = @{ @"sort" : @"ordered", @"page" : [NSString stringWithFormat:@"%d", (int)page] };
    return [self getPath:path
              withParams:params
                  target:delegate
                selector:@selector(didRetrieveArticles:)
                 rootKey:@"articles"];
}

+ (id)getArticlesWithPage:(NSInteger)page delegate:(id<UVModelDelegate>)delegate {
    NSString *path = [self apiPath:@"/articles.json"];
    NSDictionary *params = @{ @"sort" : @"ordered", @"page" : [NSString stringWithFormat:@"%d", (int)page] };
    return [self getPath:path
              withParams:params
                  target:delegate
                selector:@selector(didRetrieveArticles:)
                 rootKey:@"articles"];
}

+ (NSArray *)getInstantAnswers:(NSString *)query delegate:(id<UVModelDelegate>)delegate {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
        @"per_page" : @"3",
        @"forum_id" : [NSString stringWithFormat:@"%d", (int)[UVSession currentSession].forum.forumId],
           @"query" : query
    }];

    if ([UVSession currentSession].config.topicId)
        [params setObject:[NSString stringWithFormat:@"%d", (int)[UVSession currentSession].config.topicId] forKey:@"topic_id"];

    return [self getPath:[self apiPath:@"/instant_answers/search.json"]
              withParams:params
                  target:delegate
                selector:@selector(didRetrieveInstantAnswers:)
                 rootKey:@"instant_answers"];
}

+ (UVBaseModel *)modelForDictionary:(NSDictionary *)dict {
    if ([@"suggestion" isEqualToString:[dict objectForKey:@"type"]])
        return [UVSuggestion modelForDictionary:dict];
    return [super modelForDictionary:dict];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if ((self = [super init])) {
        _question = [UVUtils decodeHTMLEntities:[self objectOrNilForDict:dict key:@"title"]];
        _answerHTML = [self objectOrNilForDict:dict key:@"formatted_text"];
        _articleId = [(NSNumber *)[self objectOrNilForDict:dict key:@"id"] integerValue];
        _topicName = [UVUtils decodeHTMLEntities:[[self objectOrNilForDict:dict key:@"topic"] objectForKey:@"name"]];
        _weight = [(NSNumber *)[self objectOrNilForDict:dict key:@"normalized_weight"] integerValue];
    }
    return self;
}

@end
