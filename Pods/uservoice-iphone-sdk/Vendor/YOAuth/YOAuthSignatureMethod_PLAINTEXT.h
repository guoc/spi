//
//  YOAuthSignatureMethod_PLAINTEXT.h
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
 * YOAuthSignatureMethod_PLAINTEXT is a sub-class of YOAuthSignatureMethod that provides plain text signature generation.
 * @see http://oauth.net/core/1.0#anchor22 
 * @see http://oauth.net/core/1.0#anchor35
 */
@interface YOAuthSignatureMethod_PLAINTEXT : NSObject <YOAuthSignatureMethod> {

}

@end
