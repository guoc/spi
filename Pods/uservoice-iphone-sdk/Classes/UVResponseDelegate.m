//
//  UVResponseDelegate.m
//  UserVoice
//
//  Created by UserVoice on 10/23/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVResponseDelegate.h"
#import "UVBaseModel.h"
#import "UVAccessToken.h"
#import "UVSession.h"
#import "UVCustomField.h"
#import "UVRequestContext.h"
#import "UVForum.h"

@implementation UVResponseDelegate

#pragma mark - HRResponseDelegate Methods

- (void)restConnection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response object:(id)object {
    //HttpRiot ignores the status code if a JSON body is present and sends didReturnResource"
    UVRequestContext *requestContext = (UVRequestContext *)object;
    requestContext.statusCode = [response statusCode];
}

- (void)restConnection:(NSURLConnection *)connection didReturnResource:(id)resource object:(id)object {
    UVRequestContext *requestContext = (UVRequestContext *)object;
    if (requestContext.statusCode >= 400) {
        NSDictionary *userInfo = nil;

        if ([resource respondsToSelector:@selector(objectForKey:)])
            userInfo = [resource objectForKey:@"errors"];

        NSError *error = [NSError errorWithDomain:@"uservoice" code:requestContext.statusCode userInfo:userInfo];
        [requestContext.modelClass didReceiveError:error context:object];

    } else {
        if ([resource respondsToSelector:@selector(objectForKey:)]) {
            NSDictionary *dict = (NSDictionary *)resource;
            
            if ([requestContext.context isEqualToString:@"suggestions_load"]) {
                // update the forum suggestions count. hopefully have better pagination.
                [UVSession currentSession].forum.suggestionsCount = [dict[@"response_data"][@"total_records"] intValue];
            }

            if ([dict objectForKey:@"token"] && ![requestContext.context isEqualToString:@"request-token"]) {
                // check for any tokens returned and set a current on session
                // we will not persist them here though leave that to the calling controller
                // only really useful for user creation and this SUCKS, refactor
                NSDictionary *token = [dict objectForKey:@"token"];
                [UVSession currentSession].accessToken = [[UVAccessToken alloc] initWithDictionary:token];
            }

            id root = [dict objectForKey:requestContext.rootKey];

            if ([root isKindOfClass:[NSArray class]]) {
                NSMutableArray *models = [NSMutableArray array];
                for (id item in root) {
                    [models addObject:[requestContext.modelClass modelForDictionary:item]];
                }
                [requestContext.modelClass didReturnModels:models context:object];
            } else {
                [requestContext.modelClass didReturnModel:[requestContext.modelClass modelForDictionary:root] context:object];
            }
        }
    }
}

- (void)restConnection:(NSURLConnection *)connection didFailWithError:(NSError *)error object:(id)object {
    // Handle connection errors.  Failures to connect to the server, etc.
    NSLog(@"Error (HTTP connection failed): %@", error);
    UVRequestContext *requestContext = (UVRequestContext *)object;
    [requestContext.modelClass didReceiveError:error context:object];
}

- (void)restConnection:(NSURLConnection *)connection didReceiveParseError:(NSError *)error responseBody:(NSString *)string object:(id)object {
    // Request was successful, but couldn't parse the data returned by the server.
    NSLog(@"Error parsing response: %@", error);
    NSLog(@"Response Body: %@\n", string);
    UVRequestContext *requestContext = (UVRequestContext *)object;
    [requestContext.modelClass didReceiveError:error context:object];
}

@end
