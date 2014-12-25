//
//  HRRestModel.m
//  HTTPRiot
//
//  Created by Justin Palmer on 1/28/09.
//  Copyright 2009 LabratRevenge LLC.. All rights reserved.
//

#import "HRRestModel.h"
#import "HRRequestOperation.h"
#import "HRGlobal.h"

@interface HRRestModel (PrivateMethods)
+ (void)setAttributeValue:(id)attr forKey:(NSString *)key;
+ (NSMutableDictionary *)classAttributes;
+ (NSMutableDictionary *)mergedOptions:(NSDictionary *)options;
+ (NSOperation *)requestWithMethod:(HRRequestMethod)method path:(NSString *)path options:(NSDictionary *)options object:(id)obj;
@end

@implementation HRRestModel
static NSMutableDictionary *attributes;
+ (void)initialize {    
    if(!attributes)
        attributes = [NSMutableDictionary new];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class Attributes

// Given that we want to allow classes to define default attributes we need to create 
// a classname-based dictionary store that maps a subclass name to a dictionary 
// containing its attributes.
+ (NSMutableDictionary *)classAttributes {
    NSString *className = NSStringFromClass([self class]);
    
    NSMutableDictionary *newDict;
    NSMutableDictionary *dict = [attributes objectForKey:className];
    
    if(dict) {
        return dict;
    } else {
        newDict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:HRDataFormatJSON] forKey:@"format"];
        [attributes setObject:newDict forKey:className];
    }
    
    return newDict;
}

+ (NSObject *)delegate {
   return [[self classAttributes] objectForKey:kHRClassAttributesDelegateKey];
}

+ (void)setDelegate:(NSObject *)del {
    [self setAttributeValue:del forKey:kHRClassAttributesDelegateKey];
}

+ (NSURL *)baseURL {
   return [[self classAttributes] objectForKey:kHRClassAttributesBaseURLKey];
}

+ (void)setBaseURL:(NSURL *)uri {
    [self setAttributeValue:uri forKey:kHRClassAttributesBaseURLKey];
}

+ (NSDictionary *)headers {
    return [[self classAttributes] objectForKey:kHRClassAttributesHeadersKey];
}

+ (void)setHeaders:(NSDictionary *)hdrs {
    [self setAttributeValue:hdrs forKey:kHRClassAttributesHeadersKey];
}

+ (NSDictionary *)basicAuth {
    return [[self classAttributes] objectForKey:kHRClassAttributesBasicAuthKey];
}

+ (void)setBasicAuthWithUsername:(NSString *)username password:(NSString *)password {
    NSDictionary *authDict = [NSDictionary dictionaryWithObjectsAndKeys:username, kHRClassAttributesUsernameKey, password, kHRClassAttributesPasswordKey, nil];
    [self setAttributeValue:authDict forKey:kHRClassAttributesBasicAuthKey];
}

+ (HRDataFormat)format {
    return [[[self classAttributes] objectForKey:kHRClassAttributesFormatKey] intValue];
}

+ (void)setFormat:(HRDataFormat)format {
    [[self classAttributes] setValue:[NSNumber numberWithInt:format] forKey:kHRClassAttributesFormatKey];
}

+ (NSDictionary *)defaultParams {
    return [[self classAttributes] objectForKey:kHRClassAttributesDefaultParamsKey];
}

+ (void)setDefaultParams:(NSDictionary *)params {
    [self setAttributeValue:params forKey:kHRClassAttributesDefaultParamsKey];
}

+ (void)setAttributeValue:(id)attr forKey:(NSString *)key {
    [[self classAttributes] setObject:attr forKey:key];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - REST Methods

+ (NSOperation *)getPath:(NSString *)path withOptions:(NSDictionary *)options object:(id)obj {
    return [self requestWithMethod:HRRequestMethodGet path:path options:options object:obj];               
}

+ (NSOperation *)postPath:(NSString *)path withOptions:(NSDictionary *)options object:(id)obj {
    return [self requestWithMethod:HRRequestMethodPost path:path options:options object:obj];                
}

+ (NSOperation *)putPath:(NSString *)path withOptions:(NSDictionary *)options object:(id)obj {
    return [self requestWithMethod:HRRequestMethodPut path:path options:options object:obj];              
}

+ (NSOperation *)deletePath:(NSString *)path withOptions:(NSDictionary *)options object:(id)obj {
    return [self requestWithMethod:HRRequestMethodDelete path:path options:options object:obj];        
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

+ (NSOperation *)requestWithMethod:(HRRequestMethod)method path:(NSString *)path options:(NSDictionary *)options object:(id)obj {
    NSMutableDictionary *opts = [self mergedOptions:options];
    return [HRRequestOperation requestWithMethod:method path:path options:opts object:obj];
}

+ (NSMutableDictionary *)mergedOptions:(NSDictionary *)options {
    NSMutableDictionary *defaultParams = [NSMutableDictionary dictionaryWithDictionary:[self defaultParams]];
    [defaultParams addEntriesFromDictionary:[options valueForKey:kHRClassAttributesParamsKey]];
    
    options = [NSMutableDictionary dictionaryWithDictionary:options];
    [(NSMutableDictionary *)options setObject:defaultParams forKey:kHRClassAttributesParamsKey];
    NSMutableDictionary *opts = [NSMutableDictionary dictionaryWithDictionary:[self classAttributes]];
    [opts addEntriesFromDictionary:options];
    [opts removeObjectForKey:kHRClassAttributesDefaultParamsKey];

    return opts;
}
@end
