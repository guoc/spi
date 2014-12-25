//
//  UVValueSelectViewController.m
//  UserVoice
//
//  Created by UserVoice on 6/9/11.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//

#import "UVValueSelectViewController.h"
#import "UVSession.h"
#import "UVClientConfig.h"
#import "UVSubdomain.h"

#define LABEL 100

@implementation UVValueSelectViewController

- (id)initWithField:(NSDictionary *)theField valueDictionary:dictionary {
    if (self = [super init]) {
        self.field = theField;
        self.valueDictionary = dictionary;
    }
    return self;
}

#pragma mark ===== table cells =====

- (void)initCellForValue:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.tag = LABEL;
    [self configureView:cell.contentView
               subviews:NSDictionaryOfVariableBindings(label)
            constraints:@[@"|-16-[label]-|", @"V:|-10-[label]"]
         finalCondition:(indexPath == nil)
        finalConstraint:@"V:[label]-10-|"];
}

- (void)customizeCellForValue:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    UILabel *label = (UILabel *)[cell viewWithTag:LABEL];
    NSDictionary *value = _field[@"values"][indexPath.row];
    NSDictionary *selectedValue = _valueDictionary[_field[@"name"]];
    label.text = value[@"label"];
    cell.accessoryType = [value[@"id"] isEqualToString:selectedValue[@"id"]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

#pragma mark ===== UITableViewDataSource Methods =====

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self createCellForIdentifier:@"Value" tableView:theTableView indexPath:indexPath style:UITableViewCellStyleDefault selectable:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_field[@"values"] count];
}

#pragma mark ===== UITableViewDelegate Methods =====

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _valueDictionary[_field[@"name"]] = _field[@"values"][indexPath.row];
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForDynamicRowWithReuseIdentifier:@"Value" indexPath:indexPath];
}

#pragma mark ===== Basic View Methods =====

- (void)loadView {
    [super loadView];
    self.navigationItem.title = _field[@"name"];
    UITableView *theTableView = [[UITableView alloc] initWithFrame:[self contentFrame] style:UITableViewStylePlain];
    theTableView.dataSource = self;
    theTableView.delegate = self;
    self.view = theTableView;
}

@end
