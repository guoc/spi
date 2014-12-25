//
//  UVHelpTopicViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 11/16/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseViewController.h"

@class UVHelpTopic;

@interface UVHelpTopicViewController : UVBaseViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) UVHelpTopic *topic;

- (id)initWithTopic:(UVHelpTopic *)theTopic;

@end
