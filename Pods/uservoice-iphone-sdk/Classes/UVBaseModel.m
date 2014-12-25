//
//  UVBaseModel.m
//  UserVoice
//
//  Created by UserVoice on 10/21/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "YOAuth.h"
#import "UVBaseModel.h"
#import "UVConfig.h"
#import "UVSession.h"
#import "UVAccessToken.h"
#import "YOAuthToken.h"
#import "UserVoice.h"
#import "UVResponseDelegate.h"
#import "UVRequestContext.h"
#import "UVUtils.h"

@implementation UVBaseModel

+ (void)initialize {
    [self setDelegate:[UVResponseDelegate new]];
}

+ (NSURL *)siteURLWithHTTPS:(BOOL)https {
    UVConfig *config = [UVSession currentSession].config;
    NSString *protocol = https ? @"https" : @"http";
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", protocol, config.site]];
}

+ (NSURL *)baseURL {
    NSRange range = [[UVSession currentSession].config.site rangeOfString:@".uservoice.com"];
    BOOL useHttps = range.location != NSNotFound;
    return [self siteURLWithHTTPS:useHttps];
}

+ (NSMutableDictionary *)mergedOptions:(NSDictionary *)options {
    NSMutableDictionary *_options = [super mergedOptions:options];
    [_options setValue:[self baseURL] forKey:kHRClassAttributesBaseURLKey];
    return _options;
}

+ (NSString *)apiPrefix {
    return @"/api/v1";
}

+ (NSString *)apiPath:(NSString *)path {
    return [[self apiPrefix] stringByAppendingString:path];
}

+ (NSMutableDictionary *)headersForPath:(NSString *)path params:(NSDictionary *)params method:(NSString *)method {
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];

    // Contrary to the docs, HTTPRiot doesn't automatically set the right content
    // type for (form-encoded) HTTP POST requests. Also note that we can't send
    // json or xml data, because the current OAuth spec only covers form-encoded
    // HTTP bodies. A new draft spec is trying to change this:
    // http://oauth.googlecode.com/svn/spec/ext/body_hash/1.0/drafts/3/spec.html
    // Last not least, our production server seems to have an issue with GET requests
    // without a content type, even though it should be irrelevant for GET.
    [headers setObject:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    [headers setObject:[NSString stringWithFormat:@"uservoice-ios-%@", [UserVoice version]] forKey:@"API-Client"];
    [headers setObject:[[NSLocale preferredLanguages] objectAtIndex:0] forKey:@"Accept-Language"];

    if ([UVSession currentSession].yOAuthConsumer != nil) {
        YOAuthToken *token = nil;
        if ([UVAccessToken exists]) {
            token = [UVSession currentSession].accessToken.oauthToken;
        }
        NSURL *url = [NSURL URLWithString:path relativeToURL:[self baseURL]];
        YOAuthRequest *yReq = [[YOAuthRequest alloc] initWithConsumer:[[UVSession currentSession] yOAuthConsumer]
                                                               andUrl:url
                                                        andHTTPMethod:method
                                                             andToken:token
                                                   andSignatureMethod:nil];
        if (![@"PUT" isEqualToString:method])
            yReq.requestParams = [NSMutableDictionary dictionaryWithDictionary:params];
        [yReq prepareRequest];
        NSString *authHeader = [yReq buildAuthorizationHeaderValue];
        [headers setObject:authHeader forKey:@"Authorization"];
    }

    return headers;
}

+ (NSDictionary *)optionsForPath:(NSString *)path params:(NSDictionary *)params method:(NSString *)method {
    if (!params) {
        params = [NSDictionary dictionary];
    }

    NSMutableDictionary *headers = [self headersForPath:path params:params method:method];
    // Below is a workaround for HTTPRiot. According to the docs, it accepts HTTP
    // POST params in the "params" option and automatically sets the proper content
    // type in that case. In practice, we need to manually set the content type
    // (see headersForPath above) and pass the params in the "body" param.
    NSString *paramsKey = [@"GET" isEqualToString:method] ? @"params" : @"body";
    NSDictionary *opts = [NSDictionary dictionaryWithObjectsAndKeys:params, paramsKey, headers, @"headers", nil];
    return opts;
}

+ (NSDictionary *)optionsForPath:(NSString *)path JSON:(NSDictionary *)payload method:(NSString *)method {
    if (!payload) {
        payload = [NSDictionary dictionary];
    }
    
    NSMutableDictionary *headers = [self headersForPath:path params:@{} method:method];
    [headers setObject:@"application/json" forKey:@"Content-Type"];
    NSDictionary *opts = [NSDictionary dictionaryWithObjectsAndKeys:[UVUtils encodeJSON:payload], @"body", headers, @"headers", nil];
    return opts;
}

+ (NSInvocation *)invocationWithTarget:(id)target selector:(SEL)selector {
    NSMethodSignature *sig = [target methodSignatureForSelector:selector];
    NSInvocation *callback = [NSInvocation invocationWithMethodSignature:sig];
    [callback setTarget:target];
    [callback setSelector:selector];
    [callback retainArguments];
    return callback;
}

+ (UVRequestContext *)requestContextWithTarget:(id<UVModelDelegate>)target selector:(SEL)selector rootKey:(NSString *)rootKey context:(NSString *)context {
    UVRequestContext *requestContext = [UVRequestContext new];
    requestContext.modelClass = self;
    requestContext.rootKey = rootKey;
    requestContext.context = context;
    requestContext.callback = [self invocationWithTarget:target selector:selector];
    return requestContext;
}

+ (id)getPath:(NSString *)path withParams:(NSDictionary *)params target:(id<UVModelDelegate>)target selector:(SEL)selector rootKey:(NSString *)rootKey {
    return [self getPath:path withParams:params target:target selector:selector rootKey:rootKey context:nil];
}

+ (id)getPath:(NSString *)path withParams:(NSDictionary *)params target:(id<UVModelDelegate>)target selector:(SEL)selector rootKey:(NSString *)rootKey context:(NSString *)context {
    UVRequestContext *requestContext = [self requestContextWithTarget:target selector:selector rootKey:rootKey context:context];
    NSDictionary *opts = [self optionsForPath:path params:params method:@"GET"];
    return [self getPath:path withOptions:opts object:requestContext];
}

+ (id)postPath:(NSString *)path withParams:(NSDictionary *)params target:(id<UVModelDelegate>)target selector:(SEL)selector rootKey:(NSString *)rootKey {
    return [self postPath:path withParams:params target:target selector:selector rootKey:rootKey context:nil];
}

+ (id)postPath:(NSString *)path withParams:(NSDictionary *)params target:(id<UVModelDelegate>)target selector:(SEL)selector rootKey:(NSString *)rootKey context:(NSString *)context {
    UVRequestContext *requestContext = [self requestContextWithTarget:target selector:selector rootKey:rootKey context:context];
    NSDictionary *opts = [self optionsForPath:path params:params method:@"POST"];
    return [self postPath:path withOptions:opts object:requestContext];
}

+ (id)putPath:(NSString *)path withParams:(NSDictionary *)params target:(id<UVModelDelegate>)target selector:(SEL)selector rootKey:(NSString *)rootKey {
    return [self putPath:path withParams:params target:target selector:selector rootKey:rootKey context:nil];
}

+ (id)putPath:(NSString *)path withParams:(NSDictionary *)params target:(id<UVModelDelegate>)target selector:(SEL)selector rootKey:(NSString *)rootKey context:(NSString *)context {
    UVRequestContext *requestContext = [self requestContextWithTarget:target selector:selector rootKey:rootKey context:context];
    NSDictionary *opts = [self optionsForPath:path params:params method:@"PUT"];
    return [self putPath:path withOptions:opts object:requestContext];
}

+ (id)putPath:(NSString *)path withJSON:(NSDictionary *)payload target:(id<UVModelDelegate>)target selector:(SEL)selector rootKey:(NSString *)rootKey {
    return [self putPath:path withJSON:payload target:target selector:selector rootKey:rootKey context:nil];
}

+ (id)putPath:(NSString *)path withJSON:(NSDictionary *)payload target:(id<UVModelDelegate>)target selector:(SEL)selector rootKey:(NSString *)rootKey context:(NSString *)context {
    UVRequestContext *requestContext = [self requestContextWithTarget:target selector:selector rootKey:rootKey context:context];
    NSDictionary *opts = [self optionsForPath:path JSON:payload method:@"PUT"];
    return [self putPath:path withOptions:opts object:requestContext];
}

+ (UVBaseModel *)modelForDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

+ (void)didReturnModel:(id)model context:(UVRequestContext *)context {
    if (context.callback.methodSignature.numberOfArguments > 2)
        [context.callback setArgument:&model atIndex:2];

    // TODO it would be nice to optionally pass the context here, but there
    // isn't an easy way to do it with the way the callback is defined

    [context.callback invoke];
}

+ (void)didReturnModels:(NSArray *)models context:(UVRequestContext *)context {
    if (context.callback.methodSignature.numberOfArguments > 2)
        [context.callback setArgument:&models atIndex:2];

    [context.callback invoke];
}

+ (void)didReceiveError:(NSError *)error context:(UVRequestContext *)context {
    NSLog(@"UserVoice SDK network error: %@", error);

    if ([context.callback.target respondsToSelector:@selector(didReceiveError:context:)])
        [context.callback.target performSelector:@selector(didReceiveError:context:) withObject:error withObject:context];
    else if ([context.callback.target respondsToSelector:@selector(didReceiveError:)])
        [context.callback.target performSelector:@selector(didReceiveError:) withObject:error];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    return [super init];
}

- (id)objectOrNilForDict:(NSDictionary *)dict key:(id)key {
    id object = [dict objectForKey:key];
    if ([[NSNull null] isEqual:object]) {
        object = nil;
    }
    return object;
}

- (NSDate *)parseJsonDate:(NSString *)str {
    NSDate *date;

    @synchronized(self) {
        static NSDateFormatter* jsonDateFormatter = nil;
        if (!jsonDateFormatter) {
            jsonDateFormatter = [NSDateFormatter new];
            [jsonDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss zzzzz"];
        }
        date = [jsonDateFormatter dateFromString:str];
    }

    return date;
}

- (NSArray *)arrayForJSONArray:(NSArray *)array withClass:(Class)klass {
    NSMutableArray *outArray = [NSMutableArray arrayWithCapacity:[array count]];
    for (NSDictionary *dict in array) {
        [outArray addObject:[[klass alloc] initWithDictionary:dict]];
    }
    return [NSArray arrayWithArray:outArray];
}

@end
