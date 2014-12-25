//
//  UVInstantAnswersViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 10/18/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVBaseViewController.h"
#import "UVInstantAnswerManager.h"

@interface UVInstantAnswersViewController : UVBaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL articlesFirst;
@property (nonatomic, retain) UVInstantAnswerManager *instantAnswerManager;
@property (nonatomic, retain) NSString *deflectingType;

@end
