//
//  UVInstantAnswersViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/18/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVInstantAnswersViewController.h"
#import "UVArticle.h"
#import "UVSuggestion.h"
#import "UVDeflection.h"

@implementation UVInstantAnswersViewController

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [self setupGroupedTableView];
    self.navigationItem.title = NSLocalizedStringFromTableInBundle(@"Are any of these helpful?", @"UserVoice", [UserVoice bundle], nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Skip", @"UserVoice", [UserVoice bundle], nil)
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(next)];

    NSArray *visibleIdeas = [_instantAnswerManager.ideas subarrayWithRange:NSMakeRange(0, MIN(3, _instantAnswerManager.ideas.count))];
    NSArray *visibleArticles = [_instantAnswerManager.articles subarrayWithRange:NSMakeRange(0, MIN(3, _instantAnswerManager.articles.count))];
    [UVDeflection trackSearchDeflection:[visibleIdeas arrayByAddingObjectsFromArray:visibleArticles] deflectingType:_deflectingType];
}

#pragma mark ===== UITableViewDataSource Methods =====

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return (_instantAnswerManager.ideas.count > 0 && _instantAnswerManager.articles.count > 0) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return MIN([self resultsForSection:section].count, 3);
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self sectionIsArticles:indexPath.section] ? @"Article" : @"Suggestion";
    return [self createCellForIdentifier:identifier tableView:theTableView indexPath:indexPath style:UITableViewCellStyleSubtitle selectable:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self sectionIsArticles:section] ? NSLocalizedStringFromTableInBundle(@"Related articles", @"UserVoice", [UserVoice bundle], nil) : NSLocalizedStringFromTableInBundle(@"Related feedback", @"UserVoice", [UserVoice bundle], nil);
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    NSArray *results = [self resultsForSection:indexPath.section];
    if (indexPath.row >= results.count) return;
    id model = [results objectAtIndex:indexPath.row];
    [_instantAnswerManager pushViewFor:model parent:self];
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)initCellForArticle:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [_instantAnswerManager initCellForArticle:cell finalCondition:indexPath == nil];
}

- (void)customizeCellForArticle:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVArticle *article = (UVArticle *)[[self resultsForSection:indexPath.section] objectAtIndex:indexPath.row];
    [_instantAnswerManager customizeCell:cell forArticle:article];
}

- (void)initCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [_instantAnswerManager initCellForSuggestion:cell finalCondition:indexPath == nil];
}

- (void)customizeCellForSuggestion:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVSuggestion *suggestion = (UVSuggestion *)[[self resultsForSection:indexPath.section] objectAtIndex:indexPath.row];
    [_instantAnswerManager customizeCell:cell forSuggestion:suggestion];
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self sectionIsArticles:indexPath.section]) {
        return [self heightForDynamicRowWithReuseIdentifier:@"Article" indexPath:indexPath];
    } else {
        return [self heightForDynamicRowWithReuseIdentifier:@"Suggestion" indexPath:indexPath];
    }
}

#pragma mark ===== Misc =====

- (void)next {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Back", @"UserVoice", [UserVoice bundle], nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    [_instantAnswerManager skipInstantAnswers];
}

- (NSArray *)resultsForSection:(NSInteger)section {
    return [self sectionIsArticles:section] ? _instantAnswerManager.articles : _instantAnswerManager.ideas;
}

- (BOOL)sectionIsArticles:(NSInteger)section {
    return (_articlesFirst && _instantAnswerManager.articles.count > 0) || _instantAnswerManager.ideas.count == 0 ? section == 0 : section == 1;
}

@end
