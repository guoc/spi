//
//  HROperationQueue.m
//  HTTPRiot
//
//  Created by Justin Palmer on 7/2/09.
//  Copyright 2009 LabratRevenge LLC.. All rights reserved.
//

#import "HROperationQueue.h"
#import "HRGlobal.h"

static HROperationQueue *sharedOperationQueue = nil;


@implementation HROperationQueue
+ (HROperationQueue *)sharedOperationQueue {
    @synchronized(self) {
        if (sharedOperationQueue == nil) {
                sharedOperationQueue = [HROperationQueue new];
                sharedOperationQueue.maxConcurrentOperationCount = 3;
        }
    }

    return sharedOperationQueue;
}
@end
