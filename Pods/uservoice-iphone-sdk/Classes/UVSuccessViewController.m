//
//  UVSuccessViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/23/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVSuccessViewController.h"
#import "UVSession.h"
#import "UVClientConfig.h"

@implementation UVSuccessViewController

- (void)loadView {
    [super loadView];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.view = [UIView new];
    self.view.frame = [self contentFrame];
    self.view.backgroundColor = [UIColor colorWithRed:0.26f green:0.31f blue:0.35f alpha:1.0f];
    UILabel *title = [UILabel new];
    title.text = _titleText;
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:26];
    title.textAlignment = NSTextAlignmentCenter;
    title.backgroundColor = [UIColor clearColor];
    UILabel *text = [UILabel new];
    text.text = _text;
    text.textColor = [UIColor whiteColor];
    text.font = [UIFont systemFontOfSize:15];
    text.numberOfLines = 0;
    text.textAlignment = NSTextAlignmentCenter;
    text.backgroundColor = [UIColor clearColor];
    UIButton *button = [UIButton new];
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.3f].CGColor;
    button.layer.cornerRadius = 14.0;
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:NSLocalizedStringFromTableInBundle(@"Close", @"UserVoice", [UserVoice bundle], nil) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    UILabel *power = [UILabel new];
    power.text = NSLocalizedStringFromTableInBundle(@"Powered by UserVoice", @"UserVoice", [UserVoice bundle], nil);
    power.textColor = [UIColor grayColor];
    power.font = [UIFont systemFontOfSize:13];
    power.textAlignment = NSTextAlignmentCenter;
    power.backgroundColor = [UIColor clearColor];
    if ([UVSession currentSession].clientConfig.whiteLabel) {
        power.hidden = YES;
    }
    [self configureView:self.view
               subviews:NSDictionaryOfVariableBindings(title, text, button, power)
            constraints:@[@"|-[title]-|", @"|-40-[text]-40-|", @"[button(>=90)]", @"|-[power]-|", @"V:|-(>=20)-[title]-16-[text]-40-[button(==28)]-(>=40)-[power]-20-|"]];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:title attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:160];
    constraint.priority = UILayoutPriorityDefaultLow;
    [self.view addConstraint:constraint];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
