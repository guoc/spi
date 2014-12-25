//
//  UVCallback.m
//  UserVoice
//
//  Created by Rafael Baggio on 8/9/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVCallback.h"

@implementation UVCallback

- (id)initWithTarget:(id)target selector:(SEL)selector {
    self = [super init];
    
    if (self) {
        self.target = target;
        self.selector = selector;
    }
    
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)invokeCallback:(id)argument {
    if (self.target && self.selector) {
        if ([self.target respondsToSelector:self.selector]) {
            [self.target performSelector:self.selector withObject:argument];
        }
    }
}
#pragma clang diagnostic pop


- (void)invalidate {
    self.target = nil;
    self.selector = nil;
}

@end
