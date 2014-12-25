//
//  YOAuthSignatureMethod_HMAC-SHA1.m
//  YOAuth
//
//  Created by Zach Graves on 2/14/09.
//  Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//  
//  The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import "YOAuthSignatureMethod_HMAC-SHA1.h"

#import <CommonCrypto/CommonHMAC.h>

#include "Crypto/Base64Transcoder.h"

@implementation YOAuthSignatureMethod_HMAC_SHA1

#pragma mark Public

- (NSString *)name
{
	return @"HMAC-SHA1";
}

- (NSString *)buildSignatureWithRequest:(NSString *)aSignableString andSecrets:(NSString *)aSecret
{
	NSData *secretData = [aSecret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [aSignableString dataUsingEncoding:NSUTF8StringEncoding];
	
    uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
	
	CCHmacContext hmacContext;
    CCHmacInit(&hmacContext, kCCHmacAlgSHA1, secretData.bytes, secretData.length);
    CCHmacUpdate(&hmacContext, clearTextData.bytes, clearTextData.length);
    CCHmacFinal(&hmacContext, digest);
    
    //Base64 Encoding
    char base64Result[32];
    size_t theResultLength = 32;
    UVBase64EncodeData(digest, CC_SHA1_DIGEST_LENGTH, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    
    return base64EncodedResult;
}

- (BOOL)checkSignature:(NSString *)aSignature withSignableString:(NSString *)aSignableString andSecrets:(NSString *)aSecret
{
	NSString *theGeneratedSignature = [self buildSignatureWithRequest:aSignableString andSecrets:aSecret];
	return [aSignature isEqualToString:theGeneratedSignature];
}

@end
