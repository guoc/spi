//
//  UVInitialLoadManager.h
//  UserVoice
//
//  Created by Austin Taylor on 12/10/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVUser.h"
#import "UVModelDelegate.h"

@class UVBaseViewController;

@interface UVInitialLoadManager : NSObject<UIAlertViewDelegate, UVModelDelegate> {
    UVBaseViewController *_delegate;
    SEL _action;
    BOOL _userDone;
    BOOL _topicsDone;
    BOOL _articlesDone;
    BOOL _configDone;
    BOOL _forumDone;
}

+ (UVInitialLoadManager *)loadWithDelegate:(UVBaseViewController *)delegate action:(SEL)action;

@property (nonatomic, assign) BOOL dismissed;

@end
