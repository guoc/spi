//
//  YOAuthUtil.h
//  YOAuth
//
//  Created by Zach Graves on 2/14/09.
//  Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//  
//  The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import <Foundation/Foundation.h>

/**
 * A utility providing methods to create OAuth parameters for 
 * <code>oauth_nonce</code>, <code>timestamp</code> and <code>version</code>.
 */
@interface YOAuthUtil : NSObject {

}

/**
 * Returns an unique <code>oauth_nonce</code> parameter.
 */
+ (NSString *)oauth_nonce;

/**
 * Returns the current timestamp usable as the <code>oauth_timestamp</code> parameter.
 */
+ (NSString *)oauth_timestamp;

/**
 * Returns the <code>oauth_version</code> parameter.
 */
+ (NSString *)oauth_version;

@end
