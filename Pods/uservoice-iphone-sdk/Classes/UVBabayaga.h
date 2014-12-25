//
//  UVBabayaga.h
//  UserVoice
//
//  Created by Austin Taylor on 8/27/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRResponseDelegate.h"

#define CHANNEL @"i"
#define EXTERNAL_CHANNEL @"x"

#define VIEW_APP        @"g"
#define VIEW_FORUM      @"m"
#define VIEW_TOPIC      @"c"
#define VIEW_KB         @"k"
#define VIEW_CHANNEL    @"o"
#define VIEW_IDEA       @"i"
#define VIEW_ARTICLE    @"f"
#define AUTHENTICATE    @"u"
#define SEARCH_IDEAS    @"s"
#define SEARCH_ARTICLES @"r"
#define VOTE_IDEA       @"v"
#define VOTE_ARTICLE    @"z"
#define SUBMIT_TICKET   @"t"
#define SUBMIT_IDEA     @"d"
#define SUBSCRIBE_IDEA  @"b"
#define IDENTIFY        @"y"
#define COMMENT_IDEA    @"h"

@interface UVBabayaga : NSObject <HRResponseDelegate>

+ (UVBabayaga *)instance;
+ (void)track:(NSString *)event props:(NSDictionary *)props;
+ (void)track:(NSString *)event;
+ (void)track:(NSString *)event id:(NSInteger)id;
+ (void)track:(NSString *)event searchText:(NSString *)text ids:(NSArray *)results;

@property (nonatomic, retain) NSString *uvts;
@property (nonatomic, retain) NSDictionary *userTraits;

@end
