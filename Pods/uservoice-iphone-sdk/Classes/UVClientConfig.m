//
//  UVClientConfig.m
//  UserVoice
//
//  Created by UserVoice on 10/21/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "HTTPRiot.h"
#import "UVClientConfig.h"
#import "UVSession.h"
#import "UVUser.h"
#import "UVSubdomain.h"
#import "UVCustomField.h"
#import "UVSuggestion.h"
#import "UVArticle.h"
#import "UVConfig.h"

@implementation UVClientConfig

+ (id)getWithDelegate:(id<UVModelDelegate>)delegate {
    NSString *path = ([UVSession currentSession].config.key == nil) ? @"/clients/default.json" : @"/client.json";
    return [self getPath:[self apiPath:path]
              withParams:nil
                  target:delegate
                selector:@selector(didRetrieveClientConfig:)
                 rootKey:@"client"];
}

+ (CGFloat)getScreenWidth {
    UIViewController *root = [[UIApplication sharedApplication] keyWindow].rootViewController;
    return root.presentedViewController.view.bounds.size.width;
}

+ (CGFloat)getScreenHeight {
    UIViewController *root = [[UIApplication sharedApplication] keyWindow].rootViewController;
    return root.presentedViewController.view.bounds.size.height;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if ((self = [super init])) {
        if ([dict objectForKey:@"tickets_enabled"] != [NSNull null]) {
            _ticketsEnabled = [(NSNumber *)[dict objectForKey:@"tickets_enabled"] boolValue];
        }
        if ([dict objectForKey:@"feedback_enabled"] != [NSNull null]) {
            _feedbackEnabled = [(NSNumber *)[dict objectForKey:@"feedback_enabled"] boolValue];
        }
        if ([dict objectForKey:@"white_label"] != [NSNull null]) {
            _whiteLabel = [(NSNumber *)[dict objectForKey:@"white_label"] boolValue];
        }
        if ([dict objectForKey:@"display_suggestions_by_rank"] != [NSNull null]) {
            _displaySuggestionsByRank = [(NSNumber *)[dict objectForKey:@"display_suggestions_by_rank"] boolValue];
        }

        NSDictionary *subdomainDict = [self objectOrNilForDict:dict key:@"subdomain"];
        _subdomain = [[UVSubdomain alloc] initWithDictionary:subdomainDict];

        _defaultForumId = [[[self objectOrNilForDict:dict key:@"forum"] objectForKey:@"id"] intValue];
        _customFields = [self arrayForJSONArray:[self objectOrNilForDict:dict key:@"custom_fields"] withClass:[UVCustomField class]];
        _clientId = [(NSNumber *)[self objectOrNilForDict:dict key:@"id"] integerValue];
        _key = [self objectOrNilForDict:dict key:@"key"];
        // secret is only available if we are using the default client
        _secret = [self objectOrNilForDict:dict key:@"secret"];
    }
    return self;
}

@end
