//
//  YOAuthSignatureMethod_PLAINTEXT.m
//  YOAuth
//
//  Created by Zach Graves on 2/14/09.
//  Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//  
//  The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import "YOAuthSignatureMethod_PLAINTEXT.h"

@implementation YOAuthSignatureMethod_PLAINTEXT

#pragma mark Public

- (NSString *)name
{
	return @"PLAINTEXT";
}

- (NSString *)buildSignatureWithRequest:(NSString *)aSignableString andSecrets:(NSString *)aSecret
{
	return aSecret;
}

- (BOOL)checkSignature:(NSString *)aSignature withSignableString:(NSString *)aSignableString andSecrets:(NSString *)aSecret
{
	NSString *theGeneratedSignature = [self buildSignatureWithRequest:aSignableString andSecrets:aSecret];
	return [aSignature isEqualToString:theGeneratedSignature];
}

@end
