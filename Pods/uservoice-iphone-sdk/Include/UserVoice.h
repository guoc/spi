//
//  UserVoice.h
//  UserVoice
//
//  Created by UserVoice on 10/19/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVStyleSheet.h"
#import "UVDelegate.h"
#import "UVConfig.h"
#import "UVStyleSheet.h"

@interface UserVoice : NSObject 

// Initialize UserVoice with a config
// This should be called on app launch so that UserVoice can provide accurate
// analytics. You can call it again later if you need to change the config.
+ (void)initialize:(UVConfig *)config;

// Modally present the UserVoice portal view
+ (void)presentUserVoiceInterfaceForParentViewController:(UIViewController *)parentViewController;

// Modally present the UserVoice contact form
+ (void)presentUserVoiceContactUsFormForParentViewController:(UIViewController *)parentViewController;

// Modally present the UserVoice new idea form
+ (void)presentUserVoiceNewIdeaFormForParentViewController:(UIViewController *)parentViewController;

// Modally present the UserVoice forum view
+ (void)presentUserVoiceForumForParentViewController:(UIViewController *)parentViewController;

// Returns the UserVoice contact form which can then be presented modally
+ (UIViewController *)getUserVoiceContactUsFormForModalDisplay;

// Set a <UVDelegate> to receive callbacks
+ (void)setDelegate:(id<UVDelegate>)delegate;

// Get the current <UVDelegate>
+ (id<UVDelegate>)delegate;

// Get the UserVoice resource bundle
+ (NSBundle *)bundle;

// Get the current version number of the iOS SDK
+ (NSString *)version;

// For integration with other services
+ (void)setExternalId:(NSString *)identifier forScope:(NSString *)scope;

// Tell UserVoice to track an event
+ (void)track:(NSString *)event;

// Tell UserVoice to track an event with properties
+ (void)track:(NSString *)event properties:(NSDictionary *)properties;

/**
 * @deprecated Use [UserVoice presentUserVoiceModalInterfaceForParentViewController:andConfig:] instead.
 */
+ (void)presentUserVoiceInterfaceForParentViewController:(UIViewController *)parentViewController andConfig:(UVConfig *)config;
+ (void)presentUserVoiceContactUsFormForParentViewController:(UIViewController *)parentViewController andConfig:(UVConfig *)config;
+ (void)presentUserVoiceNewIdeaFormForParentViewController:(UIViewController *)parentViewController andConfig:(UVConfig *)config;
+ (void)presentUserVoiceForumForParentViewController:(UIViewController *)parentViewController andConfig:(UVConfig *)config;
+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)viewController andSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret;
+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)viewController andSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret andSsoToken:(NSString *)token;
+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)viewController andSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret andEmail:(NSString *)email andDisplayName:(NSString *)displayName andGUID:(NSString *)guid;

@end
