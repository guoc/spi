//
//  YOAuthToken.h
//  YOAuth
//
//  Created by Zach Graves on 2/14/09.
//  Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//  
//  The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import <Foundation/Foundation.h>

/**
 * Contains an OAuth token key and secret provided by the service provider for an application to access private information.
 * <p>This class should be extended to add any additional token information returned by the service provider.</p>
 */
@interface YOAuthToken : NSObject

@property(nonatomic, readwrite, retain) NSString *key;
@property(nonatomic, readwrite, retain) NSString *secret;

/**
 * Creates a token with the specified key and secret.
 * @param aKey			The token key
 * @param aSecret		The token secret
 * @return				The initialized token.
 */
+ (YOAuthToken *)tokenWithKey:(NSString *)aKey andSecret:(NSString *)aSecret;

/**
 * Creates a token with the specified dictionary containing OAuth response. 
 * @param aDictionary	The dictionary containing the OAuth response.
 * @return				The initialized token.
 */
+ (YOAuthToken *)tokenWithDictionary:(NSDictionary *)aDictionary;

/**
 * Initializes a token with the specified key and secret.
 * @param aKey			The token key
 * @param aSecret		The token secret
 * @return				The initialized token.
 */
- (id)initWithKey:(NSString *)aKey andSecret:(NSString *)aSecret;

@end
