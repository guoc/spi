//
//  UVSuggestion.m
//  UserVoice
//
//  Created by UserVoice on 10/27/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVSuggestion.h"
#import "UVSession.h"
#import "UVSubdomain.h"
#import "UVClientConfig.h"
#import "UVUser.h"
#import "UVForum.h"
#import "UVCategory.h"
#import "UVUtils.h"
#import "UVDeflection.h"

@implementation UVSuggestion

+ (id)getWithForum:(UVForum *)forum page:(NSInteger)page delegate:(id<UVModelDelegate>)delegate {
    NSString *path = [self apiPath:[NSString stringWithFormat:@"/forums/%d/suggestions.json", (int)forum.forumId]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [[NSNumber numberWithInteger:page] stringValue], @"page",
                            @"public", @"filter",
                            [[UVSession currentSession].clientConfig.subdomain suggestionSort], @"sort",
                            //@"5", @"per_page",
                            nil];
    return [self getPath:path
              withParams:params
                  target:delegate
                selector:@selector(didRetrieveSuggestions:)
                 rootKey:@"suggestions"
                 context:@"suggestions_load"];
}

+ (id)searchWithForum:(UVForum *)forum query:(NSString *)query delegate:(id<UVModelDelegate>)delegate {
    NSString *path = [self apiPath:[NSString stringWithFormat:@"/forums/%d/suggestions/search.json", (int)forum.forumId]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            query, @"query",
                            nil];
    return [self getPath:path
              withParams:params
                  target:delegate
                selector:@selector(didSearchSuggestions:)
                 rootKey:@"suggestions"];
}

+ (id)createWithForum:(UVForum *)forum
             category:(NSInteger)categoryId
                title:(NSString *)title
                 text:(NSString *)text
             delegate:(id<UVModelDelegate>)delegate {
    NSString *path = [self apiPath:[NSString stringWithFormat:@"/forums/%d/suggestions.json", (int)forum.forumId]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"true", @"subscribe",
                            title, @"suggestion[title]",
                            text == nil ? @"" : text, @"suggestion[text]",
                            categoryId == 0 ? @"" : [NSString stringWithFormat:@"%d", (int)categoryId], @"suggestion[category_id]",
                            [NSString stringWithFormat:@"%d", (int)[UVDeflection interactionIdentifier]], @"interaction_identifier",
                            nil];
    return [[self class] postPath:path
                       withParams:params
                           target:delegate
                         selector:@selector(didCreateSuggestion:)
                          rootKey:@"suggestion"];
}

- (id)subscribe:(id<UVModelDelegate>)delegate {
    NSString *path = [UVSuggestion apiPath:[NSString stringWithFormat:@"/forums/%d/suggestions/%d/watch.json", (int)self.forumId, (int)self.suggestionId]];
    NSDictionary *params = @{ @"subscribe" : @"true" };
    return [[self class] postPath:path
                       withParams:params
                           target:delegate
                         selector:@selector(didSubscribe:)
                          rootKey:@"suggestion"];
}

- (id)unsubscribe:(id<UVModelDelegate>)delegate {
    NSString *path = [UVSuggestion apiPath:[NSString stringWithFormat:@"/forums/%d/suggestions/%d/watch.json", (int)self.forumId, (int)self.suggestionId]];
    NSDictionary *params = @{ @"subscribe" : @"false" };
    return [[self class] postPath:path
                       withParams:params
                           target:delegate
                         selector:@selector(didUnsubscribe:)
                          rootKey:@"suggestion"];
}

- (UIColor *)statusColor {
    return self.statusHexColor ? [UVUtils parseHexColor:self.statusHexColor] : [UIColor clearColor];
}

- (NSString *)rankString {
    NSString *suffix;
    if (_rank % 100 > 10 && _rank % 100 < 14) {
        suffix = @"th";
    } else {
        switch (_rank % 10) {
        case 1:
            suffix = @"st";
            break;
        case 2:
            suffix = @"nd";
            break;
        case 3:
            suffix = @"rd";
            break;
        default:
            suffix = @"th";
        }
    }
    return [NSString stringWithFormat:@"%d%@", (int)_rank, suffix];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if ((self = [super init])) {
        _suggestionId = [(NSNumber *)[dict objectForKey:@"id"] integerValue];
        _commentsCount = [(NSNumber *)[dict objectForKey:@"comments_count"] integerValue];
        _subscriberCount = [(NSNumber *)[dict objectForKey:@"subscriber_count"] integerValue];
        _title = [self objectOrNilForDict:dict key:@"title"];
        _abstract = [self objectOrNilForDict:dict key:@"abstract"];
        _text = [UVUtils decodeHTMLEntities:[self objectOrNilForDict:dict key:@"text"]];
        _createdAt = [self parseJsonDate:[dict objectForKey:@"created_at"]];
        _subscribed = [(NSNumber *)[self objectOrNilForDict:dict key:@"subscribed"] boolValue];
        _weight = [(NSNumber *)[self objectOrNilForDict:dict key:@"normalized_weight"] integerValue];
        _rank = [(NSNumber *)[self objectOrNilForDict:dict key:@"rank"] integerValue];
        NSDictionary *statusDict = [self objectOrNilForDict:dict key:@"status"];
        if (statusDict) {
            _status = [statusDict objectForKey:@"name"];
            _statusHexColor = [statusDict objectForKey:@"hex_color"];
        }
        NSDictionary *creator = [self objectOrNilForDict:dict key:@"creator"];
        if (creator) {
            _creatorName = [creator objectForKey:@"name"];
            _creatorId = [(NSNumber *)[creator objectForKey:@"id"] integerValue];
        }
        NSDictionary *response = [self objectOrNilForDict:dict key:@"response"];
        if (response) {
            _responseText = [UVUtils decodeHTMLEntities:[self objectOrNilForDict:response key:@"text"]];
            NSDictionary *responseCreator = [self objectOrNilForDict:response key:@"creator"];
            if (responseCreator) {
                _responseUserName = [self objectOrNilForDict:responseCreator key:@"name"];
                _responseUserAvatarUrl = [self objectOrNilForDict:responseCreator key:@"avatar_url"];
                _responseUserId = [(NSNumber *)[self objectOrNilForDict:responseCreator key:@"id"] integerValue];
                _responseUserTitle = [self objectOrNilForDict:responseCreator key:@"title"];
            }
            _responseCreatedAt = [self parseJsonDate:[response objectForKey:@"created_at"]];
        }

        NSDictionary *topic = [self objectOrNilForDict:dict key:@"topic"];
        if (topic) {
            NSDictionary *forum = [self objectOrNilForDict:topic key:@"forum"];
            if (forum) {
                _forumId = [(NSNumber *)[forum objectForKey:@"id"] integerValue];
                _forumName = [UVUtils decodeHTMLEntities:[self objectOrNilForDict:forum key:@"name"]];
            }
        }

        NSDictionary *categoryDict = [self objectOrNilForDict:dict key:@"category"];
        if (categoryDict) {
            _category = [[UVCategory alloc] initWithDictionary:categoryDict];
        }
    }
    return self;
}

- (NSString *)responseUserWithTitle {
    if ([_responseUserTitle length] > 0) {
        return [NSString stringWithFormat:@"%@, %@", _responseUserName, _responseUserTitle];
    } else {
        return _responseUserName;
    }
}

@end
