//
//  UVKeyboardUtils.h
//  UserVoice
//
//  Created by Austin Taylor on 11/7/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UVKeyboardUtils : NSObject {
    BOOL visible;
    CGFloat kbHeight;
}

+ (BOOL)visible;
+ (CGFloat)height;

@end
