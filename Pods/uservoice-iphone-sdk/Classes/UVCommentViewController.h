//
//  UVCommentViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 11/15/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"

@class UVSuggestion;

@interface UVCommentViewController : UVBaseViewController<UITextViewDelegate, UVSigninManagerDelegate>

@property (nonatomic,retain) UVSuggestion *suggestion;

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion;
- (void)doComment;

@end
