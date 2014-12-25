//
//  UVInstantAnswerManager.m
//  UserVoice
//
//  Created by Austin Taylor on 10/17/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVInstantAnswerManager.h"
#import "UVArticle.h"
#import "UVSuggestion.h"
#import "UVDeflection.h"
#import "UVBabayaga.h"
#import "UVArticleViewController.h"
#import "UVSuggestionDetailsViewController.h"
#import "UVInstantAnswersViewController.h"
#import "UVUtils.h"
#import "UVSession.h"
#import "UVClientConfig.h"

#define TITLE 20
#define SUBSCRIBER_COUNT 21
#define STATUS 22
#define STATUS_COLOR 23
#define SECTION 24

@implementation UVInstantAnswerManager

- (void)setSearchText:(NSString *)newText {
    if ([_searchText.lowercaseString isEqualToString:newText.lowercaseString]) {
        return;
    }
    _searchText = newText;
    [self invalidateTimer];
    if (_searchText == nil || _searchText.length == 0) {
        self.instantAnswers = self.ideas = self.articles = [NSArray array];
        [_delegate didUpdateInstantAnswers];
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(doSearch:) userInfo:nil repeats:NO];
    }
}

- (void)search {
    [_timer fire];
    [self invalidateTimer];
}

- (void)invalidateTimer {
    [_timer invalidate];
    self.timer = nil;
}

- (void)doSearch:(NSTimer *)timer {
    _loading = YES;
    self.runningQuery = _searchText;
    if (_deflectingType) {
        [UVDeflection setSearchText:_searchText];
    }
    [UVArticle getInstantAnswers:_searchText delegate:self];
}

- (void)didRetrieveInstantAnswers:(NSArray *)theInstantAnswers {
    self.instantAnswers = theInstantAnswers;
    self.ideas = [theInstantAnswers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class == %@", [UVSuggestion class]]];
    self.articles = [theInstantAnswers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class == %@", [UVArticle class]]];
    _loading = NO;
    [_delegate didUpdateInstantAnswers];
    
    NSMutableArray *articleIds = [NSMutableArray arrayWithCapacity:_articles.count];
    for (id answer in _articles) {
        [articleIds addObject:@(((UVArticle *)answer).articleId)];
    }
    [UVBabayaga track:SEARCH_ARTICLES searchText:_runningQuery ids:articleIds];
    
    NSMutableArray *ideaIds = [NSMutableArray arrayWithCapacity:_ideas.count];
    for (id answer in _ideas) {
        [ideaIds addObject:@(((UVSuggestion *)answer).suggestionId)];
    }
    [UVBabayaga track:SEARCH_IDEAS searchText:_runningQuery ids:ideaIds];
    // note: UVDeflection should be called later with the actual objects displayed to the user
}

- (void)skipInstantAnswers {
    if ([_delegate respondsToSelector:@selector(skipInstantAnswers)])
        [_delegate skipInstantAnswers];
}

- (void)pushInstantAnswersViewForParent:(UIViewController *)parent articlesFirst:(BOOL)articlesFirst {
    if (_instantAnswers.count > 0) {
        UVInstantAnswersViewController *next = [UVInstantAnswersViewController new];
        next.instantAnswerManager = self;
        next.articlesFirst = articlesFirst;
        next.deflectingType = _deflectingType;
        [parent.navigationController pushViewController:next animated:YES];
    } else {
        [self skipInstantAnswers];
    }
}

- (void)pushViewFor:(id)instantAnswer parent:(UIViewController *)parent {
    if (_deflectingType) {
        [UVDeflection trackDeflection:@"show" deflectingType:_deflectingType deflector:instantAnswer];
    }
    if ([instantAnswer isMemberOfClass:[UVArticle class]]) {
        UVArticleViewController *next = [UVArticleViewController new];
        next.article = (UVArticle *)instantAnswer;
        next.helpfulPrompt = _articleHelpfulPrompt;
        next.returnMessage = _articleReturnMessage;
        next.deflectingType = _deflectingType;
        [parent.navigationController pushViewController:next animated:YES];
    } else {
        UVSuggestion *suggestion = (UVSuggestion *)instantAnswer;
        UVSuggestionDetailsViewController *next = [[UVSuggestionDetailsViewController alloc] initWithSuggestion:suggestion];
        next.helpfulPrompt = _articleHelpfulPrompt;
        next.returnMessage = _articleReturnMessage;
        next.deflectingType = _deflectingType;
        next.instantAnswers = (_deflectingType != nil);
        [parent.navigationController pushViewController:next animated:YES];
    }
}

- (void)didReceiveError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(didReceiveError:)]) {
        [_delegate didReceiveError:error];
    }
}

- (void)initCellForSuggestion:(UITableViewCell *)cell finalCondition:(BOOL)final {
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (IOS7) {
        cell.separatorInset = UIEdgeInsetsMake(0, 58, 0, 0);
    }
    UIImageView *icon = [UVUtils imageViewWithImageNamed:@"uv_idea.png"];
    UIImageView *heart = [UVUtils imageViewWithImageNamed:@"uv_heart.png"];
    UILabel *subs = [UILabel new];
    subs.font = [UIFont systemFontOfSize:14];
    subs.textColor = [UIColor grayColor];
    subs.tag = SUBSCRIBER_COUNT;
    UILabel *title = [UILabel new];
    title.numberOfLines = 0;
    title.tag = TITLE;
    title.font = [UIFont systemFontOfSize:17];
    UILabel *status = [UILabel new];
    status.font = [UIFont systemFontOfSize:11];
    status.tag = STATUS;
    UIView *statusColor = [UIView new];
    statusColor.tag = STATUS_COLOR;
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 9, 9);
    [statusColor.layer addSublayer:layer];
    NSArray *constraints = @[
        @"|-15-[icon(==28)]-15-[title]-|",
        @"|-58-[heart(==9)]-3-[subs]-10-[statusColor(==9)]-5-[status]",
        @"V:|-15-[icon(==28)]",
        @"V:|-12-[title]-6-[heart(==9)]",
        @"V:[title]-6-[statusColor(==9)]",
        @"V:[title]-4-[status]",
        @"V:[title]-2-[subs]"
    ];
    [UVUtils configureView:cell.contentView
                  subviews:NSDictionaryOfVariableBindings(icon, subs, title, heart, statusColor, status)
               constraints:constraints
            finalCondition:final
           finalConstraint:@"V:[heart]-14-|"];
}

- (void)customizeCell:(UITableViewCell *)cell forSuggestion:(UVSuggestion *)suggestion {
    UILabel *title = (UILabel *)[cell.contentView viewWithTag:TITLE];
    UILabel *subs = (UILabel *)[cell.contentView viewWithTag:SUBSCRIBER_COUNT];
    UILabel *status = (UILabel *)[cell.contentView viewWithTag:STATUS];
    UIView *statusColor = [cell.contentView viewWithTag:STATUS_COLOR];
    title.text = suggestion.title;
    if ([UVSession currentSession].clientConfig.displaySuggestionsByRank) {
        subs.text = suggestion.rankString;
    } else {
        subs.text = [NSString stringWithFormat:@"%d", (int)suggestion.subscriberCount];
    }
    [(CALayer *)statusColor.layer.sublayers.lastObject setBackgroundColor:suggestion.statusColor.CGColor];
    status.textColor = suggestion.statusColor;
    status.text = [suggestion.status uppercaseString];
}

- (void)initCellForArticle:(UITableViewCell *)cell finalCondition:(BOOL)final {
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (IOS7) {
        cell.separatorInset = UIEdgeInsetsMake(0, 58, 0, 0);
    }
    UIImageView *icon = [UVUtils imageViewWithImageNamed:@"uv_article.png"];
    UILabel *title = [UILabel new];
    title.font = [UIFont systemFontOfSize:18];
    title.numberOfLines = 0;
    title.tag = TITLE;
    UILabel *section = [UILabel new];
    section.font = [UIFont systemFontOfSize:12];
    section.textColor = [UIColor grayColor];
    section.tag = SECTION;
    NSArray *constraints = @[
        @"|-15-[icon(==28)]-15-[title]-|",
        @"|-58-[section]",
        @"V:|-15-[icon(==28)]",
        @"V:|-12-[title]-6-[section]"
    ];
    [UVUtils configureView:cell.contentView
                  subviews:NSDictionaryOfVariableBindings(icon, title, section)
               constraints:constraints
            finalCondition:final
           finalConstraint:@"V:[section]-14-|"];
}

- (void)customizeCell:(UITableViewCell *)cell forArticle:(UVArticle *)article {
    UILabel *title = (UILabel *)[cell.contentView viewWithTag:TITLE];
    UILabel *section = (UILabel *)[cell.contentView viewWithTag:SECTION];
    title.text = article.question;
    section.text = article.topicName;
}


- (void)dealloc {
    [self invalidateTimer];
}

@end
