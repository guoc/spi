//
//  UserVoice.m
//  UserVoice
//
//  Created by UserVoice on 10/19/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import "UserVoice.h"
#import "UVConfig.h"
#import "UVClientConfig.h"
#import "UVWelcomeViewController.h"
#import "UVRootViewController.h"
#import "UVSession.h"
#import "UVSuggestionListViewController.h"
#import "UVNavigationController.h"
#import "UVUtils.h"
#import "UVBabayaga.h"

@implementation UserVoice

static id<UVDelegate> userVoiceDelegate;
static NSBundle *userVoiceBundle;

+ (void)initialize:(UVConfig *)config {
    [[UVSession currentSession] clear];
    [UVBabayaga instance].userTraits = [config traits];
    [UVSession currentSession].config = config;
    [UVBabayaga track:VIEW_APP];
}

+ (NSBundle *)bundle {
    if (!userVoiceBundle) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"UserVoice" withExtension:@"bundle"];
        if (url) {
            userVoiceBundle = [NSBundle bundleWithURL:url];
        }
    }
    if (!userVoiceBundle) {
        userVoiceBundle = [NSBundle mainBundle];
    }
    return userVoiceBundle;
}

+ (UINavigationController *)getNavigationControllerForUserVoiceControllers:(NSArray *)viewControllers {
    [UVSession currentSession].isModal = YES;
    UINavigationController *navigationController = [UVNavigationController new];
    [UVUtils applyStylesheetToNavigationController:navigationController];
    navigationController.viewControllers = viewControllers;
    return navigationController;
}

+ (void)presentUserVoiceControllers:(NSArray *)viewControllers forParentViewController:(UIViewController *)parentViewController {
    UINavigationController *navigationController = [self getNavigationControllerForUserVoiceControllers:viewControllers];
    BOOL useFormSheet;
    if (IOS8) {
#ifdef __IPHONE_8_0
        useFormSheet = parentViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular && parentViewController.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular;
#endif
    } else {
        useFormSheet = IPAD;
    }
    if (useFormSheet) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    } else {
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [parentViewController presentViewController:navigationController animated:YES completion:nil];
}

+ (void)presentUserVoiceController:(UIViewController *)viewController forParentViewController:(UIViewController *)parentViewController {
    [self presentUserVoiceControllers:[NSArray arrayWithObject:viewController] forParentViewController:parentViewController];
}

+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)parentViewController andSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret {
    UVConfig *config = [UVConfig configWithSite:site andKey:key andSecret:secret];
    [self presentUserVoiceInterfaceForParentViewController:parentViewController andConfig:config];
}

+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)parentViewController andSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret andSsoToken:(NSString *)token {
    UVConfig *config = [UVConfig configWithSite:site andKey:key andSecret:secret andSSOToken:token];
    [self presentUserVoiceInterfaceForParentViewController:parentViewController andConfig:config];
}

+ (void)presentUserVoiceModalViewControllerForParent:(UIViewController *)parentViewController andSite:(NSString *)site andKey:(NSString *)key andSecret:(NSString *)secret andEmail:(NSString *)email andDisplayName:(NSString *)displayName andGUID:(NSString *)guid {
    UVConfig *config = [UVConfig configWithSite:site andKey:key andSecret:secret andEmail:email andDisplayName:displayName andGUID:guid];
    [self presentUserVoiceInterfaceForParentViewController:parentViewController andConfig:config];
}

+ (UIViewController *)getUserVoiceInterface {
    return [[UVRootViewController alloc] initWithViewToLoad:@"welcome"];
}

+ (void)presentUserVoiceInterfaceForParentViewController:(UIViewController *)parentViewController {
    [self presentUserVoiceController:[self getUserVoiceInterface] forParentViewController:parentViewController];
}

+ (UIViewController *)getUserVoiceContactUsForm {
    return [[UVRootViewController alloc] initWithViewToLoad:@"new_ticket"];
}

+ (UIViewController *)getUserVoiceContactUsFormForModalDisplay {
    return [self getNavigationControllerForUserVoiceControllers:@[[self getUserVoiceContactUsForm]]];
}

+ (void)presentUserVoiceContactUsFormForParentViewController:(UIViewController *)parentViewController {
    [self presentUserVoiceController:[self getUserVoiceContactUsForm] forParentViewController:parentViewController];
}

+ (void)presentUserVoiceNewIdeaFormForParentViewController:(UIViewController *)parentViewController {
    UIViewController *viewController = [[UVRootViewController alloc] initWithViewToLoad:@"new_suggestion"];
    [self presentUserVoiceController:viewController forParentViewController:parentViewController];
}

+ (void)presentUserVoiceForumForParentViewController:(UIViewController *)parentViewController {
    UIViewController *viewController = [[UVRootViewController alloc] initWithViewToLoad:@"suggestions"];
    [self presentUserVoiceController:viewController forParentViewController:parentViewController];
}

+ (void)presentUserVoiceInterfaceForParentViewController:(UIViewController *)parentViewController andConfig:(UVConfig *)config {
    [self initialize:config];
    [self presentUserVoiceInterfaceForParentViewController:parentViewController];
}

+ (void)presentUserVoiceContactUsFormForParentViewController:(UIViewController *)parentViewController andConfig:(UVConfig *)config {
    [self initialize:config];
    [self presentUserVoiceContactUsFormForParentViewController:parentViewController];
}

+ (void)presentUserVoiceNewIdeaFormForParentViewController:(UIViewController *)parentViewController andConfig:(UVConfig *)config {
    [self initialize:config];
    [self presentUserVoiceNewIdeaFormForParentViewController:parentViewController];
}

+ (void)presentUserVoiceForumForParentViewController:(UIViewController *)parentViewController andConfig:(UVConfig *)config {
    [self initialize:config];
    [self presentUserVoiceForumForParentViewController:parentViewController];
}

+ (void)setExternalId:(NSString *)identifier forScope:(NSString *)scope {
    [[UVSession currentSession] setExternalId:identifier forScope:scope];
}

+ (void)track:(NSString *)event properties:(NSDictionary *)properties {
    [UVBabayaga track:event props:properties];
}

+ (void)track:(NSString *)event {
    [UVBabayaga track:event];
}

+ (void)setDelegate:(id<UVDelegate>)delegate {
    userVoiceDelegate = delegate;
}

+ (id<UVDelegate>)delegate {
    return userVoiceDelegate;
}

+ (NSString *)version {
    return @"3.2.2";
}


@end
