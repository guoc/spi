//
//  UVRequestContext.h
//  UserVoice
//
//  Created by Austin Taylor on 3/12/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UVRequestContext : NSObject

@property (nonatomic, assign) Class modelClass;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, retain) NSString *context;
@property (nonatomic, retain) NSInvocation *callback;
@property (nonatomic, retain) NSString *rootKey;

@end
