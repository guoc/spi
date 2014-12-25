//
//  UVStyleSheet.m
//  UserVoice
//
//  Created by UserVoice on 10/28/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UVStyleSheet.h"

@implementation UVStyleSheet

static UVStyleSheet *instance;

+ (UVStyleSheet *)instance {
    if (instance == nil) {
        instance = [UVStyleSheet new];
        instance.loadingViewBackgroundColor = [UIColor colorWithRed:0.902f green:0.902f blue:0.902f alpha:1.0f];
        instance.preferredStatusBarStyle = UIStatusBarStyleDefault;
        instance.navigationBarTintColor = [UINavigationBar appearance].tintColor;
    }
    return instance;
}

@end
