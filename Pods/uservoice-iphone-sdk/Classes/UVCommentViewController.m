//
//  UVCommentViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 11/15/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVCommentViewController.h"
#import "UVSuggestion.h"
#import "UVTextView.h"
#import "UVComment.h"
#import "UVSuggestionDetailsViewController.h"
#import "UVBabayaga.h"
#import "UVTextWithFieldsView.h"
#import "UVSession.h"
#import "UVCallback.h"
#import "UVSigninManager.h"

@implementation UVCommentViewController {
    UVTextWithFieldsView *_fieldsView;
    UITextField *_emailField;
    UITextField *_nameField;
    UVCallback *_signInCallback;
    UVSigninManager *_signinManager;
}

- (id)initWithSuggestion:(UVSuggestion *)theSuggestion {
    if ((self = [super init])) {
        _suggestion = theSuggestion;
        _signInCallback = [[UVCallback alloc] initWithTarget:self selector:@selector(doComment)];
        _signinManager = [UVSigninManager manager];
        _signinManager.delegate = self;
    }
    return self;
}

- (void)commentButtonTapped {
    if (_fieldsView.textView.text.length == 0) {
        [self alertError:NSLocalizedStringFromTableInBundle(@"Please enter some text before submitting your comment.", @"UserVoice", [UserVoice bundle], nil)];
    } else {
        if (![UVSession currentSession].user) {
            if (_emailField.text.length > 0) {
                [self disableSubmitButton];
                self.userEmail = _emailField.text;
                self.userName = _nameField.text;
                [self showActivityIndicator];
                [_signinManager signInWithEmail:_emailField.text name:_nameField.text callback:_signInCallback];
            } else {
                [self alertError:NSLocalizedStringFromTableInBundle(@"Please enter your email address before submitting your comment.", @"UserVoice", [UserVoice bundle], nil)];
            }
        } else {
            [self disableSubmitButton];
            [self doComment];
        }
    }
}

- (void)signinManagerDidFail {
    [self hideActivityIndicator];
    [self enableSubmitButton];
}

- (void)showActivityIndicator {
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.color = [UVStyleSheet instance].navigationBarActivityIndicatorColor;
    [activityView startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
}

- (void)hideActivityIndicator {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Comment", @"UserVoice", [UserVoice bundle], nil) style:UIBarButtonItemStyleDone target:self action:@selector(commentButtonTapped)];
}

- (void)doComment {
    [self showActivityIndicator];
    [UVComment createWithSuggestion:_suggestion text:_fieldsView.textView.text delegate:self];
}

- (void)didReceiveError:(NSError *)error {
    [self hideActivityIndicator];
    [self enableSubmitButton];
    [super didReceiveError:error];
}

- (void)didCreateComment:(UVComment *)comment {
    [UVBabayaga track:COMMENT_IDEA id:_suggestion.suggestionId];
    _suggestion.commentsCount = comment.updatedCommentCount;
    UINavigationController *navController = (UINavigationController *)self.presentingViewController;
    UVSuggestionDetailsViewController *previous = (UVSuggestionDetailsViewController *)[navController.viewControllers lastObject];
    [previous commentCreated:comment];
    [self dismiss];
}

- (void)loadView {
    [super loadView];
    self.navigationItem.title = NSLocalizedStringFromTableInBundle(@"Add a comment", @"UserVoice", [UserVoice bundle], nil);
    UIView *view = [UIView new];
    view.frame = [self contentFrame];
    view.backgroundColor = [UIColor whiteColor];

    _fieldsView = [UVTextWithFieldsView new];
    _fieldsView.textView.placeholder = NSLocalizedStringFromTableInBundle(@"Write a comment...", @"UserVoice", [UserVoice bundle], nil);
    if (![UVSession currentSession].user) {
        _emailField = [_fieldsView addFieldWithLabel:NSLocalizedStringFromTableInBundle(@"Email", @"UserVoice", [UserVoice bundle], nil)];
        _emailField.placeholder = NSLocalizedStringFromTableInBundle(@"(required)", @"UserVoice", [UserVoice bundle], nil);
        _emailField.keyboardType = UIKeyboardTypeEmailAddress;
        _emailField.autocorrectionType = UITextAutocorrectionTypeNo;
        _emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _emailField.text = self.userEmail;

        _nameField = [_fieldsView addFieldWithLabel:NSLocalizedStringFromTableInBundle(@"Name", @"UserVoice", [UserVoice bundle], nil)];
        _nameField.placeholder = NSLocalizedStringFromTableInBundle(@"“Anonymous”", @"UserVoice", [UserVoice bundle], nil);
        _nameField.text = self.userName;
    }

    [self configureView:view
               subviews:NSDictionaryOfVariableBindings(_fieldsView)
            constraints:@[@"|[_fieldsView]|", @"V:|[_fieldsView]|"]];

    self.view = view;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", @"UserVoice", [UserVoice bundle], nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismiss)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Comment", @"UserVoice", [UserVoice bundle], nil)
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(commentButtonTapped)];
    [_fieldsView.textView becomeFirstResponder];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [_fieldsView performSelector:@selector(updateLayout) withObject:nil afterDelay:0];
}

- (UIScrollView *)scrollView {
    return _fieldsView;
}

- (void)dealloc {
    if (_fieldsView) {
        _fieldsView.textViewDelegate = nil;
    }
    [_signInCallback invalidate];
}

@end
