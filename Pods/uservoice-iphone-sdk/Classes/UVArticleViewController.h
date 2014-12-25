//
//  UVArticleViewController.h
//  UserVoice
//
//  Created by Austin Taylor on 5/8/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVBaseViewController.h"
#import "UVArticle.h"

@interface UVArticleViewController : UVBaseViewController<UIActionSheetDelegate>

@property (nonatomic, retain) UVArticle *article;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSString *helpfulPrompt;
@property (nonatomic, retain) NSString *returnMessage;
@property (nonatomic, retain) NSString *deflectingType;

@end
