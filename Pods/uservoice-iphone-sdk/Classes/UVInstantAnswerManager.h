//
//  UVInstantAnswerManager.h
//  UserVoice
//
//  Created by Austin Taylor on 10/17/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UVModelDelegate.h"

@class UVArticle;
@class UVSuggestion;

@protocol UVInstantAnswersDelegate
/*
 * Called whenever there are new instant answer results
 */
- (void)didUpdateInstantAnswers; 

@optional

- (void)skipInstantAnswers;
- (void)didReceiveError:(NSError *)error;
- (void)sendWithEmail:(NSString *)email name:(NSString *)name fields:(NSDictionary *)fieldValues;
- (void)cancel;

@end

@interface UVInstantAnswerManager : NSObject<UVModelDelegate>

@property (nonatomic, assign) id<UVInstantAnswersDelegate,NSObject> delegate;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSString *runningQuery;
@property (nonatomic, retain) NSString *articleHelpfulPrompt;
@property (nonatomic, retain) NSString *articleReturnMessage;
@property (nonatomic, retain) NSString *deflectingType;

/*
 * An array of interleaved ideas and articles
 */
@property (nonatomic,retain) NSArray *instantAnswers;

/*
 * Just the ideas
 */
@property (nonatomic,retain) NSArray *ideas;

/*
 * Just the articles
 */
@property (nonatomic,retain) NSArray *articles;

/*
 * Text for searching
 * The search will execute 0.5 seconds after this has been changed,
 * unless it is updated again within that time.
 */
@property (nonatomic,retain) NSString *searchText;


/*
 * Call this to force the search to execute immediately
 */
- (void)search;

- (void)pushViewFor:(id)instantAnswer parent:(UIViewController *)parent;
- (void)pushInstantAnswersViewForParent:(UIViewController *)parent articlesFirst:(BOOL)articlesFirst;
- (void)skipInstantAnswers;

/*
 * Cell layout helpers
 */
- (void)initCellForSuggestion:(UITableViewCell *)cell finalCondition:(BOOL)final;
- (void)customizeCell:(UITableViewCell *)cell forSuggestion:(UVSuggestion *)suggestion;
- (void)initCellForArticle:(UITableViewCell *)cell finalCondition:(BOOL)final;
- (void)customizeCell:(UITableViewCell *)cell forArticle:(UVArticle *)article;

@end

