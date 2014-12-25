//
//  HROperationQueue.h
//  HTTPRiot
//
//  Created by Justin Palmer on 7/2/09.
//  Copyright 2009 LabratRevenge LLC.. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Gives you access to the shared operation queue used to manage all connections.
 */
@interface HROperationQueue : NSOperationQueue {

}

/**
 * Shared operation queue.
 */
+ (HROperationQueue *)sharedOperationQueue;
@end
