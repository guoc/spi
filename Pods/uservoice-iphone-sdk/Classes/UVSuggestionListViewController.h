//
//  UVSuggestionListViewController.h
//  UserVoice
//
//  Created by UserVoice on 10/22/09.
//  Copyright 2009 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"
#import "UVPostIdeaViewController.h"

@class UVForum;

@interface UVSuggestionListViewController : UVBaseViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UVPostIdeaDelegate>

@property (nonatomic, retain) UVForum *forum;
@property (nonatomic, retain) UITextField *textEditor;
@property (nonatomic, retain) NSArray *searchResults;
@property (nonatomic, retain) UISearchDisplayController *searchController;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, assign) BOOL searching;

@end
