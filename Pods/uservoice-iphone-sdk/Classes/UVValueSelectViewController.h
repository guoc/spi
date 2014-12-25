//
//  UVValueSelectViewController.h
//  UserVoice
//
//  Created by UserVoice on 6/9/11.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVBaseViewController.h"

@interface UVValueSelectViewController : UVBaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSMutableDictionary *valueDictionary;
@property (nonatomic, retain) NSDictionary *field;

- (id)initWithField:(NSDictionary *)theField valueDictionary:(NSMutableDictionary *)valueDictionary;

@end
