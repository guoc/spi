//
//  UVDelegate.h
//  UserVoice
//
//  Created by Austin Taylor on 1/13/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UVDelegate <NSObject>
@optional

/*
 * Called after the user dismisses the UserVoice interface.
 */
- (void)userVoiceWasDismissed;

/*
 * If this is defined, UserVoice will not dismiss itself. You will receive this
 * message and can remove the UserVoice UI yourself. For use with
 * +[UserVoice getUserVoiceContactUsFormForModalDisplay].
 */
- (void)userVoiceRequestsDismissal;

@end
