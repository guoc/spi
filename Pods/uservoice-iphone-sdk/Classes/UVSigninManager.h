//
//  UVSigninManager.h
//  UserVoice
//
//  Created by Austin Taylor on 11/20/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVCallback.h"
#import "UVModelDelegate.h"

#define STATE_EMAIL 1
#define STATE_PASSWORD 2
#define STATE_FAILED 3

@protocol UVSigninManagerDelegate;

@interface UVSigninManager : NSObject<UITextFieldDelegate, UIAlertViewDelegate, UVModelDelegate>

+ (UVSigninManager *)manager;

- (void)signInWithCallback:(UVCallback *)callback;
- (void)signInWithEmail:(NSString *)theEmail name:(NSString *)theName callback:(UVCallback *)callback;

@property (nonatomic, assign) id<UVSigninManagerDelegate> delegate;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) UIAlertView *alertView;

@end


@protocol UVSigninManagerDelegate <NSObject>

@optional

- (void)signinManagerDidSignIn:(UVUser *)user;
- (void)signinManagerDidFail;

@end
