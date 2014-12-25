//
//  UVHelpTopicViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 11/16/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVHelpTopicViewController.h"
#import "UVHelpTopic.h"
#import "UVArticle.h"
#import "UVArticleViewController.h"
#import "UVContactViewController.h"
#import "UVStyleSheet.h"
#import "UVSession.h"
#import "UVConfig.h"
#import "UVBabayaga.h"
#import "UVClientConfig.h"

#define LABEL 100
#define TOPIC 101
#define LOADING 200

#define ARTICLE_PAGE_SIZE 10

@implementation UVHelpTopicViewController {
    BOOL _allArticlesLoaded;
    BOOL _loading;
    NSInteger _page;
    NSMutableArray *_articles;
}

- (id)initWithTopic:(UVHelpTopic *)theTopic {
    if (self = [super init]) {
        _topic = theTopic;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [UVSession currentSession].config.showContactUs ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? ([_articles count] + (_allArticlesLoaded ? 0 : 1)) : 1;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row < _articles.count) {
        UVArticle *article = (UVArticle *)[_articles objectAtIndex:indexPath.row];
        UVArticleViewController *next = [UVArticleViewController new];
        next.article = article;
        [self.navigationController pushViewController:next animated:YES];
    } else if (indexPath.section == 0) {
        if (!_loading) {
            [self retrieveMoreArticles];
        }
    } else {
        [self presentModalViewController:[UVContactViewController new]];
    }
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row < _articles.count) {
        return [self createCellForIdentifier:@"Article" tableView:theTableView indexPath:indexPath style:UITableViewCellStyleDefault selectable:YES];
    } else if (indexPath.section == 0) {
        return [self createCellForIdentifier:@"Load" tableView:theTableView indexPath:indexPath style:UITableViewCellStyleDefault selectable:YES];
    } else {
        return [self createCellForIdentifier:@"Contact" tableView:theTableView indexPath:indexPath style:UITableViewCellStyleDefault selectable:YES];
    }
}

- (void)initCellForContact:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Send us a message", @"UserVoice", [UserVoice bundle], nil);
    if (IOS7) {
        cell.textLabel.textColor = cell.textLabel.tintColor;
    }
}

- (void)initCellForArticle:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.tag = LABEL;
    if (_topic) {
        [self configureView:cell.contentView
                   subviews:NSDictionaryOfVariableBindings(label)
                constraints:@[@"|-16-[label]-|", @"V:|-12-[label]-12-|"]];
    } else {
        UILabel *topic = [UILabel new];
        topic.font = [UIFont systemFontOfSize:12];
        topic.textColor = [UIColor grayColor];
        topic.tag = TOPIC;
        [self configureView:cell.contentView
                   subviews:NSDictionaryOfVariableBindings(label, topic)
                constraints:@[@"|-16-[label]-|", @"|-16-[topic]-|", @"V:|-12-[label]-6-[topic]"]
             finalCondition:indexPath == nil
            finalConstraint:@"V:[topic]-12-|"];
    }
}

- (void)customizeCellForArticle:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UVArticle *article = [_articles objectAtIndex:indexPath.row];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:LABEL];
    label.text = article.question;
    if (!_topic) {
        UILabel *topic = (UILabel *)[cell.contentView viewWithTag:TOPIC];
        topic.text = article.topicName;
    }
}

- (void)initCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:cell.frame];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = LOADING;
    [cell addSubview:label];
}

- (void)customizeCellForLoad:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UILabel *label = (UILabel *)[cell viewWithTag:LOADING];
    label.text = _loading ? NSLocalizedStringFromTableInBundle(@"Loading...", @"UserVoice", [UserVoice bundle], nil) : NSLocalizedStringFromTableInBundle(@"Load more", @"UserVoice", [UserVoice bundle], nil);
}

- (void)showActivityIndicator {
    _loading = YES;
    [_tableView reloadData];
}

- (void)hideActivityIndicator {
    _loading = NO;
}

- (void)didRetrieveArticles:(NSArray *)theArticles {
    [self hideActivityIndicator];
    [_articles addObjectsFromArray:theArticles];
    if (theArticles.count < ARTICLE_PAGE_SIZE || (_topic && _articles.count >= _topic.articleCount)) {
        _allArticlesLoaded = YES;
    }
    [_tableView reloadData];
}

- (void)retrieveMoreArticles {
    _page += 1;
    [self showActivityIndicator];
    if (_topic) {
        [UVArticle getArticlesWithTopicId:_topic.topicId page:_page delegate:self];
    } else {
        [UVArticle getArticlesWithPage:_page delegate:self];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row < _articles.count) {
        CGFloat height = [self heightForDynamicRowWithReuseIdentifier:@"Article" indexPath:indexPath];
        UVArticle *article = [_articles objectAtIndex:indexPath.row];
        if (!_topic && article.topicName.length == 0) {
            height -= 6;
        }
        return height;
    } else {
        return 44;
    }
}

- (void)loadView {
    [self setupGroupedTableView];
    if (![UVSession currentSession].clientConfig.whiteLabel) {
        _tableView.tableFooterView = self.poweredByView;
    }
    _page = 1;
    if (_topic) {
        self.navigationItem.title = _topic.name;
        [self showActivityIndicator];
        [UVBabayaga track:VIEW_TOPIC id:_topic.topicId];
        [UVArticle getArticlesWithTopicId:_topic.topicId page:1 delegate:self];
        _articles = [NSMutableArray new];
    } else {
        self.navigationItem.title = NSLocalizedStringFromTableInBundle(@"All Articles", @"UserVoice", [UserVoice bundle], nil);
        _articles = [[UVSession currentSession].articles mutableCopy];
        [_tableView reloadData];
    }
}

@end
