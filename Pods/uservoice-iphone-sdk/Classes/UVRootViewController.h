//
//  UVRootViewController.h
//  UserVoice
//
//  Created by UserVoice on 12/15/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"

@class UVInitialLoadManager;

@interface UVRootViewController : UVBaseViewController

@property (nonatomic, retain) NSString *viewToLoad;
@property (nonatomic, retain) UVInitialLoadManager *loader;

- (id)initWithViewToLoad:(NSString *)theViewToLoad;

@end
