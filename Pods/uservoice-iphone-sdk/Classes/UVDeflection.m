//
//  UVDeflection.m
//  UserVoice
//
//  Created by Austin Taylor on 9/19/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVDeflection.h"
#import "UVArticle.h"
#import "UVSuggestion.h"
#import "UVBabayaga.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVSubdomain.h"
#import "UVUtils.h"

@implementation UVDeflection

static NSString *searchText;
static NSInteger interactionIdentifier;

+ (void)trackDeflection:(NSString *)kind deflectingType:(NSString *)deflectingType deflector:(UVBaseModel *)model {
    NSMutableDictionary *params = [self deflectionParams];
    [params setObject:kind forKey:@"kind"];
    [params setObject:deflectingType forKey:@"deflecting_type"];
    if ([model isKindOfClass:[UVArticle class]]) {
        UVArticle *article = (UVArticle *)model;
        [params setObject:@"Faq" forKey:@"deflector_type"];
        [params setObject:[NSString stringWithFormat:@"%d", (int)article.articleId] forKey:@"deflector_id"];
    } else if ([model isKindOfClass:[UVSuggestion class]]) {
        UVSuggestion *suggestion = (UVSuggestion *)model;
        [params setObject:@"Suggestion" forKey:@"deflector_type"];
        [params setObject:[NSString stringWithFormat:@"%d", (int)suggestion.suggestionId] forKey:@"deflector_id"];
    }
    [self sendDeflection:@"/clients/widgets/omnibox/deflections/upsert.json" params:params];
}

+ (void)trackSearchDeflection:(NSArray *)results deflectingType:(NSString *)deflectingType {
    NSMutableDictionary *params = [self deflectionParams];
    [params setObject:@"list" forKey:@"kind"];
    [params setObject:deflectingType forKey:@"deflecting_type"];
    NSInteger articleResults = 0;
    NSInteger suggestionResults = 0;
    NSInteger index = 0;
    for (id model in results) {
        NSString *prefix = [NSString stringWithFormat:@"results[%d]", (int)index];
        [params setObject:[NSString stringWithFormat:@"%d", (int)index++] forKey:[prefix stringByAppendingString:@"[position]"]];
        [params setObject:[NSString stringWithFormat:@"%d", (int)[model weight]] forKey:[prefix stringByAppendingString:@"[weight]"]];
        if ([model isKindOfClass:[UVArticle class]]) {
            articleResults += 1;
            UVArticle *article = (UVArticle *)model;
            [params setObject:[NSString stringWithFormat:@"%d", (int)article.articleId] forKey:[prefix stringByAppendingString:@"[deflector_id]"]];
            [params setObject:@"Faq" forKey:[prefix stringByAppendingString:@"[deflector_type]"]];
        } else if ([model isKindOfClass:[UVSuggestion class]]) {
            suggestionResults += 1;
            UVSuggestion *suggestion = (UVSuggestion *)model;
            [params setObject:[NSString stringWithFormat:@"%d", (int)suggestion.suggestionId] forKey:[prefix stringByAppendingString:@"[deflector_id]"]];
            [params setObject:@"Suggestion" forKey:[prefix stringByAppendingString:@"[deflector_type]"]];
        }
        index += 1;
    }
    [params setObject:[NSString stringWithFormat:@"%d", (int)articleResults] forKey:@"faq_results"];
    [params setObject:[NSString stringWithFormat:@"%d", (int)suggestionResults] forKey:@"suggestion_results"];
    [self sendDeflection:@"/clients/widgets/omnibox/deflections/list_view.json" params:params];
}

+ (void)setSearchText:(NSString *)query {
    if ([query isEqualToString:searchText]) return;
    searchText = query;
    interactionIdentifier = [self interactionIdentifier] + 1;
}

+ (void)sendDeflection:(NSString *)path params:(NSDictionary *)params {
    NSDictionary *opts = @{
        kHRClassAttributesBaseURLKey  : [UVBaseModel baseURL],
        kHRClassAttributesDelegateKey : self,
        @"headers" : @{ @"Content-Type" : @"application/json" },
        @"params" : params
    };
    [HRRequestOperation requestWithMethod:HRRequestMethodGet path:path options:opts object:nil];
}

+ (NSInteger)interactionIdentifier {
    if (!interactionIdentifier) {
        interactionIdentifier = [[[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] substringFromIndex:4] integerValue];
    }
    return interactionIdentifier;
}

+ (NSMutableDictionary *)deflectionParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if ([UVBabayaga instance].uvts) {
        // there should be one, but don't crash if there isn't!
        [params setObject:[UVBabayaga instance].uvts forKey:@"uvts"];
    }
    [params setObject:@"ios" forKey:@"channel"];
    [params setObject:searchText forKey:@"search_term"];
    [params setObject:[NSString stringWithFormat:@"%d", (int)[self interactionIdentifier]] forKey:@"interaction_identifier"];
    [params setObject:[NSString stringWithFormat:@"%d", (int)[UVSession currentSession].clientConfig.subdomain.subdomainId] forKey:@"subdomain_id"];
    return params;
}

@end
