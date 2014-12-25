//
//  UVPostIdeaViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 10/23/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVPostIdeaViewController.h"
#import "UVDetailsFormViewController.h"
#import "UVSuccessViewController.h"
#import "UVTextView.h"
#import "UVSession.h"
#import "UVForum.h"
#import "UVCategory.h"
#import "UVUtils.h"
#import "UVSuggestion.h"
#import "UVBabayaga.h"
#import "UVTextWithFieldsView.h"

@implementation UVPostIdeaViewController {
    BOOL _proceed;
    BOOL _sending;
    BOOL _canceled;
    UVDetailsFormViewController *_detailsController;
    UVTextWithFieldsView *_fieldsView;
}

- (void)loadView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    view.frame = [self contentFrame];
    _instantAnswerManager = [UVInstantAnswerManager new];
    _instantAnswerManager.delegate = self;
    _instantAnswerManager.articleHelpfulPrompt = NSLocalizedStringFromTableInBundle(@"Do you still want to post your own idea?", @"UserVoice", [UserVoice bundle], nil);
    _instantAnswerManager.articleReturnMessage = NSLocalizedStringFromTableInBundle(@"Yes, I want to post my idea", @"UserVoice", [UserVoice bundle], nil);
    _instantAnswerManager.deflectingType = @"Suggestion";

    self.navigationItem.title = NSLocalizedStringFromTableInBundle(@"Post an idea", @"UserVoice", [UserVoice bundle], nil);
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Back", @"UserVoice", [UserVoice bundle], nil) style:UIBarButtonItemStylePlain target:nil action:nil];

    _fieldsView = [UVTextWithFieldsView new];
    _titleField = [_fieldsView addFieldWithLabel:NSLocalizedStringFromTableInBundle(@"Title", @"UserVoice", [UserVoice bundle], nil)];
    if (_initialText) {
        _titleField.text = _initialText;
    }
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:_titleField queue:nil usingBlock:^(NSNotification *note) {
        NSString *text = [self->_titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self->_instantAnswerManager.searchText = text;
        self.navigationItem.rightBarButtonItem.enabled = (text.length > 0);
    }];

    _fieldsView.textView.placeholder = NSLocalizedStringFromTableInBundle(@"Description (optional)", @"UserVoice", [UserVoice bundle], nil);

    UIView *sep = [UIView new];
    sep.backgroundColor = [UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:1.f];

    UIView *bg = [UIView new];
    bg.backgroundColor = [UIColor colorWithRed:0.937f green:0.937f blue:0.957f alpha:1.f];

    UILabel *desc = [UILabel new];
    desc.backgroundColor = [UIColor clearColor];
    desc.text = NSLocalizedStringFromTableInBundle(@"When you post an idea on our forum, others will be able to subscribe to it and make comments. When we respond to the idea, you'll get notified.", @"UserVoice", [UserVoice bundle], nil);
    desc.textColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f];
    desc.numberOfLines = 0;
    desc.font = [UIFont systemFontOfSize:12];
    self.desc = desc;

    NSArray *constraints = @[
        @"|[_fieldsView]|",
        @"|[sep]|",
        @"|-[desc]-|",
        @"|[bg]|",
        @"V:[_fieldsView][sep(==1)]-[desc]",
        @"V:[sep][bg]|"
    ];

    [self configureView:view
               subviews:NSDictionaryOfVariableBindings(_fieldsView, sep, desc, bg)
            constraints:constraints];
    [view bringSubviewToFront:desc];

    self.keyboardConstraint = [NSLayoutConstraint constraintWithItem:desc
                                                           attribute:NSLayoutAttributeBottom
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:view
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1.0
                                                            constant:-_kbHeight-10];
    [view addConstraint:_keyboardConstraint];
    self.topConstraint = [NSLayoutConstraint constraintWithItem:_fieldsView
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:view
                                                      attribute:NSLayoutAttributeTop
                                                     multiplier:1.0
                                                       constant:64];
    [view addConstraint:_topConstraint];
    self.descConstraint = [NSLayoutConstraint constraintWithItem:desc
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1
                                                       constant:0];
    self.view = view;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", @"UserVoice", [UserVoice bundle], nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismiss)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Next", @"UserVoice", [UserVoice bundle], nil)
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(next)];
    self.navigationItem.rightBarButtonItem.enabled = ([_titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
    [self registerForKeyboardNotifications];
    _didAuthenticateCallback = [[UVCallback alloc] initWithTarget:self selector:@selector(createSuggestion)];
    [self updateLayout];
}

- (void)updateLayout {
    _topConstraint.constant = (IOS7 ? (IPAD ? 44 : (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 64 : 52)) : 0);
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) || IPAD) {
        _desc.hidden = NO;
        [self.view removeConstraint:_descConstraint];
    } else {
        _desc.hidden = YES;
        [self.view addConstraint:_descConstraint];
    }
    if (!IOS7) {
        _desc.preferredMaxLayoutWidth = 0;
        [self.view layoutIfNeeded];
        _desc.preferredMaxLayoutWidth = _desc.frame.size.width;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self updateLayout];
    [_fieldsView performSelector:@selector(updateLayout) withObject:nil afterDelay:0];
}

- (void)keyboardDidShow:(NSNotification *)note {
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) || IPAD) {
        _keyboardConstraint.constant = -_kbHeight-10;
    } else {
        _keyboardConstraint.constant = -_kbHeight+10;
    }
    [self.view layoutIfNeeded];
    [_fieldsView updateLayout];
}

- (void)keyboardDidHide:(NSNotification *)note {
    _keyboardConstraint.constant = -10;
    [self.view layoutIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_titleField becomeFirstResponder];
}

- (void)dismiss {
    _instantAnswerManager.delegate = nil;
    [super dismiss];
}

- (void)didUpdateInstantAnswers {
    if (_proceed) {
        _proceed = NO;
        [self hideActivityIndicator];
        [_instantAnswerManager pushInstantAnswersViewForParent:self articlesFirst:NO];
    }
}

- (void)next {
    if (_proceed) return;
    [self showActivityIndicator];
    _proceed = YES;
    [_instantAnswerManager search];
    if (!_instantAnswerManager.loading) {
        [self didUpdateInstantAnswers];
    }
}

- (void)showActivityIndicator {
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.color = [UVStyleSheet instance].navigationBarActivityIndicatorColor;
    [activityView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
}

- (void)hideActivityIndicator {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Next", @"UserVoice", [UserVoice bundle], nil) style:UIBarButtonItemStyleDone target:self action:@selector(next)];
}

- (void)skipInstantAnswers {
    _detailsController = [UVDetailsFormViewController new];
    _detailsController.delegate = self;
    _detailsController.helpText = NSLocalizedStringFromTableInBundle(@"When you post an idea on our forum, others will be able to subscribe to it and make comments. When we respond to the idea, you'll get notified.", @"UserVoice", [UserVoice bundle], nil);
    _detailsController.sendTitle = NSLocalizedStringFromTableInBundle(@"Post", @"UserVoice", [UserVoice bundle], nil);
    UVForum *forum = [UVSession currentSession].forum;
    if (forum.categories && forum.categories.count > 0) {
        NSMutableArray *values = [NSMutableArray array];
        [values addObject:@{ @"id" : @"", @"label" : NSLocalizedStringFromTableInBundle(@"(none)", @"UserVoice", [UserVoice bundle], nil) }];
        for (UVCategory *category in forum.categories) {
            [values addObject:@{ @"id" : [NSString stringWithFormat:@"%d", (int)category.categoryId], @"label" : category.name }];
        }
        _detailsController.fields = @[ @{
            @"name" : NSLocalizedStringFromTableInBundle(@"Category", @"UserVoice", [UserVoice bundle], nil),
            @"values" : values
        } ];
        _detailsController.selectedFieldValues = [NSMutableDictionary dictionary];
    }
    [self.navigationController pushViewController:_detailsController animated:YES];
}

- (void)sendWithEmail:(NSString *)email name:(NSString *)name fields:(NSDictionary *)fields {
    if (_sending) return;
    self.userEmail = email;
    self.userName = name;
    if (email.length == 0) {
        [self alertError:NSLocalizedStringFromTableInBundle(@"Please enter your email address before submitting your ticket.", @"UserVoice", [UserVoice bundle], nil)];
    } else {
        [_detailsController showActivityIndicator];
        _selectedCategoryId = [fields[@"Category"][@"id"] integerValue];
        [self requireUserAuthenticated:email name:name callback:_didAuthenticateCallback];
    }
}

- (void)signinManagerDidFail {
    _sending = NO;
    [_detailsController hideActivityIndicator];
}

- (void)didReceiveError:(NSError *)error {
    _sending = NO;
    [_detailsController hideActivityIndicator];
    if ([UVUtils isUVRecordInvalid:error forField:@"title" withMessage:@"is not allowed."]) {
        [self alertError:NSLocalizedStringFromTableInBundle(@"A suggestion with this title already exists. Please change the title.", @"UserVoice", [UserVoice bundle], nil)];
    } else {
        [super didReceiveError:error];
    }
}

- (void)createSuggestion {
    _sending = YES;
    [UVSuggestion createWithForum:[UVSession currentSession].forum
                         category:_selectedCategoryId
                            title:_titleField.text
                             text:_fieldsView.textView.text
                         delegate:self];
}

- (void)cancel {
    _canceled = YES;
}

- (void)didCreateSuggestion:(UVSuggestion *)theSuggestion {
    [UVBabayaga track:SUBMIT_IDEA];
    UVSuccessViewController *next = [UVSuccessViewController new];
    next.titleText = NSLocalizedStringFromTableInBundle(@"Thank you!", @"UserVoice", [UserVoice bundle], nil);
    next.text = NSLocalizedStringFromTableInBundle(@"Your feedback has been posted to our feedback forum.", @"UserVoice", [UserVoice bundle], nil);
    [self.navigationController setViewControllers:@[next] animated:YES];
    // force forum view to reload suggestions
    if (!_canceled) {
        [UVSession currentSession].forum.suggestions = nil;
    }
    _sending = NO;
}

@end
