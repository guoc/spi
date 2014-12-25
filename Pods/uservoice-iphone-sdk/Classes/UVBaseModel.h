//
//  UVBaseModel.h
//  UserVoice
//
//  Created by UserVoice on 10/21/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPRiot.h"
#import "UVModelDelegate.h"

@class UVRequestContext;

@interface UVBaseModel : HRRestModel {

}

+ (NSString *)apiPrefix;
+ (NSString *)apiPath:(NSString *)path;

// Perform a GET, POST, and PUT respectively
+ (id)getPath:(NSString *)path withParams:(NSDictionary *)params target:(id)target selector:(SEL)selector rootKey:(NSString *)rootKey;
+ (id)postPath:(NSString *)path withParams:(NSDictionary *)params target:(id)target selector:(SEL)selector rootKey:(NSString *)rootKey;
+ (id)putPath:(NSString *)path withParams:(NSDictionary *)params target:(id)target selector:(SEL)selector rootKey:(NSString *)rootKey;
+ (id)putPath:(NSString *)path withJSON:(NSDictionary *)payload target:(id)target selector:(SEL)selector rootKey:(NSString *)rootKey;

+ (id)getPath:(NSString *)path withParams:(NSDictionary *)params target:(id)target selector:(SEL)selector rootKey:(NSString *)rootKey context:(NSString *)context;
+ (id)postPath:(NSString *)path withParams:(NSDictionary *)params target:(id)target selector:(SEL)selector rootKey:(NSString *)rootKey context:(NSString *)context;
+ (id)putPath:(NSString *)path withParams:(NSDictionary *)params target:(id)target selector:(SEL)selector rootKey:(NSString *)rootKey context:(NSString *)context;
+ (id)putPath:(NSString *)path withJSON:(NSDictionary *)payload target:(id)target selector:(SEL)selector rootKey:(NSString *)rootKey context:(NSString *)context;

// Exposed for subclasses that need to implement their own requests
+ (NSMutableDictionary *)headersForPath:(NSString *)path params:(NSDictionary *)params method:(NSString *)method;

// Override in subclasses if neccessary
+ (UVBaseModel *)modelForDictionary:(NSDictionary *)dict;

// Processes the returned model(s) and invokes the specified callback. Should not
// need to be overridden in subclasses.
+ (void)didReturnModel:(id)model context:(UVRequestContext *)requestContext;
+ (void)didReturnModels:(NSArray *)models context:(UVRequestContext *)requestContext;

// Any of the different types of HTTPRiot errors result in this method being
// called. Invokes the didReceiveError: selector on the callback target. Can be
// overridden in subclasses that need more specific error handling.
+ (void)didReceiveError:(NSError *)error context:(UVRequestContext *)requestContext;

// Should be overriden in subclasses to populate themselves based on the
// returned resource.
- (id)initWithDictionary:(NSDictionary *)dict;

// Returns the dictionary object for the specified key, or nil if it does not
// exist or is NSNull.
- (id)objectOrNilForDict:(NSDictionary *)dict key:(id)key;

- (NSArray *)arrayForJSONArray:(NSArray *)array withClass:(Class)klass;

// Parses an ISO-8601 date string (as returned by our Rails apps) into an NSDate.
- (NSDate *)parseJsonDate:(NSString *)str;


@end
