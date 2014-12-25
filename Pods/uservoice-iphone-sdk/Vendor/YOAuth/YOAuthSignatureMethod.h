//
//  YOAuthSignatureMethod.h
//  YOAuth
//
//  Created by Zach Graves on 2/14/09.
//  Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//  
//  The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import <Foundation/Foundation.h>

/**
 * A base protocol for all signature methods. This cannot be used as a signature method alone; 
 * instead use <code>YOAuthSignatureMethod_PLAINTEXT</code> or <code>YOAuthSignatureMethod_HMAC-SHA1</code>.
 * @see YOAuthSignatureMethod_PLAINTEXT
 * @see YOAuthSignatureMethod_HMAC-SHA1
 */
@protocol YOAuthSignatureMethod <NSObject>

/**
 * Returns the name of the signature method.
 */
- (NSString *)name;

/**
 * Returns a signature generated with the provided signature base string and combined token.
 */
- (NSString *)buildSignatureWithRequest:(NSString *)aSignableString andSecrets:(NSString *)aSecret;

/**
 * Checks the provided signature against one built with the signable string and secrets. 
 * @return			A Boolean, true if the signature provided matches the signature built from the provided strings.
 */
- (BOOL)checkSignature:(NSString *)aSignature withSignableString:(NSString *)aSignableString andSecrets:(NSString *)aSecret;

@end