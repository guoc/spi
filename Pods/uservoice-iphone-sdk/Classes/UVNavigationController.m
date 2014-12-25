//
//  UVNavigationController.m
//  UserVoice
//
//  Created by Austin Taylor on 11/1/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVNavigationController.h"
#import "UVStyleSheet.h"

@implementation UVNavigationController

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [UVStyleSheet instance].preferredStatusBarStyle;
}

@end