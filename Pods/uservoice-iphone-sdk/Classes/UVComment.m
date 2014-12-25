//
//  UVComment.m
//  UserVoice
//
//  Created by UserVoice on 11/11/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVComment.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVSuggestion.h"
#import "UVForum.h"
#import "UVUtils.h"


@implementation UVComment

+ (id)getWithSuggestion:(UVSuggestion *)suggestion page:(NSInteger)page delegate:(id<UVModelDelegate>)delegate {
    NSString *path = [self apiPath:[NSString stringWithFormat:@"/forums/%d/suggestions/%d/comments.json",
                                    (int)suggestion.forumId,
                                    (int)suggestion.suggestionId]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [[NSNumber numberWithInteger:page] stringValue],
                            @"page",
                            nil];
    return [self getPath:path
              withParams:params
                  target:delegate
                selector:@selector(didRetrieveComments:)
                 rootKey:@"comments"];
}

+ (id)createWithSuggestion:(UVSuggestion *)suggestion text:(NSString *)text delegate:(id<UVModelDelegate>)delegate {
    NSString *path = [self apiPath:[NSString stringWithFormat:@"/forums/%d/suggestions/%d/comments.json",
                                    (int)suggestion.forumId,
                                    (int)suggestion.suggestionId]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            text, @"comment[text]",
                            nil];
    return [[self class] postPath:path
                       withParams:params
                           target:delegate
                         selector:@selector(didCreateComment:)
                          rootKey:@"comment"];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _commentId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
        _text = [UVUtils decodeHTMLEntities:[self objectOrNilForDict:dict key:@"text"]];
        _updatedCommentCount = [dict[@"suggestion"][@"comments_count"] integerValue];
        NSDictionary *user = [dict objectForKey:@"creator"];
        if (user && ![[NSNull null] isEqual:user]) {
            _userName = [UVUtils decodeHTMLEntities:[user objectForKey:@"name"]];
            _userId = [(NSNumber *)[user objectForKey:@"id"] integerValue];
            _avatarUrl = [self objectOrNilForDict:user key:@"avatar_url"];
            _karmaScore = [(NSNumber *)[user objectForKey:@"karma_score"] integerValue];
            _createdAt = [self parseJsonDate:[dict objectForKey:@"created_at"]];
        }
    }
    return self;
}

@end
