//
//  UVCallback.h
//  UserVoice
//
//  Created by Rafael Baggio on 8/9/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UVCallback : NSObject

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selector;

- (id)initWithTarget:(id)target selector:(SEL)selector;
- (void)invokeCallback:(id)argument;
- (void)invalidate;

@end
