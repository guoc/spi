//
//  YOAuthSignatureMethod_HMAC-SHA1.h
//  YOAuth
//
//  Created by Zach Graves on 2/14/09.
//  Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//  
//  The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import <Foundation/Foundation.h>
#import "YOAuthSignatureMethod.h"

/**
 * YOAuthSignatureMethod_HMAC_SHA1 is a sub-class of YOAuthSignatureMethod that provides HMAC-SHA1 signature generation.
 * @see http://oauth.net/core/1.0#anchor16
 */
@interface YOAuthSignatureMethod_HMAC_SHA1 : NSObject <YOAuthSignatureMethod> {

}

@end
