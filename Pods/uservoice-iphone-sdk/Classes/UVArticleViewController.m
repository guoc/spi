//
//  UVArticleViewController.m
//  UserVoice
//
//  Created by Austin Taylor on 5/8/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UVArticleViewController.h"
#import "UVSession.h"
#import "UVContactViewController.h"
#import "UVStyleSheet.h"
#import "UVBabayaga.h"
#import "UVDeflection.h"
#import "UVUtils.h"

@implementation UVArticleViewController {
    UILabel *_footerLabel;
    UIButton *_yes;
    UIButton *_no;
}

- (void)loadView {
    [super loadView];
    [UVBabayaga track:VIEW_ARTICLE id:_article.articleId];
    self.view = [[UIView alloc] initWithFrame:[self contentFrame]];
    self.navigationItem.title = @"";

    CGFloat footerHeight = 46;
    _webView = [UIWebView new];
    NSString *section = _article.topicName ? [NSString stringWithFormat:@"%@ / %@", NSLocalizedStringFromTableInBundle(@"Knowledge Base", @"UserVoice", [UserVoice bundle], nil), _article.topicName] : NSLocalizedStringFromTableInBundle(@"Knowledge base", @"UserVoice", [UserVoice bundle], nil);
    NSString *linkColor;
    if (IOS7) {
        linkColor = [UVUtils colorToCSS:self.view.tintColor];
    } else {
        linkColor = @"default";
    }
    NSString *html = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"http://cdn.uservoice.com/stylesheets/vendor/typeset.css\"/><style>a { color: %@; }</style></head><body class=\"typeset\" style=\"font-family: HelveticaNeue; margin: 1em; font-size: 15px\"><h5 style='font-weight: normal; color: #999; font-size: 13px'>%@</h5><h3 style='margin-top: 10px; margin-bottom: 20px; font-size: 18px; font-family: HelveticaNeue-Medium; font-weight: normal; line-height: 1.3'>%@</h3>%@</body></html>", linkColor, section, _article.question, _article.answerHTML];
    _webView.backgroundColor = [UIColor whiteColor];
    for (UIView* shadowView in [[_webView scrollView] subviews]) {
        if ([shadowView isKindOfClass:[UIImageView class]]) {
            [shadowView setHidden:YES];
        }
    }
    [_webView loadHTMLString:html baseURL:nil];
    _webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, footerHeight, 0);
    _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, footerHeight, 0);

    UIView *footer = [UIView new];
    footer.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.0f];
    UIView *border = [UIView new];
    border.backgroundColor = [UIColor colorWithRed:0.85f green:0.85f blue:0.85f alpha:1.0f];
    UILabel *label = [UILabel new];
    label.text = NSLocalizedStringFromTableInBundle(@"Was this article helpful?", @"UserVoice", [UserVoice bundle], nil);
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor colorWithRed:0.41f green:0.42f blue:0.43f alpha:1.0f];
    label.backgroundColor = [UIColor clearColor];
    _footerLabel = label;
    UIButton *yes = [UIButton new];
    [yes setTitle:NSLocalizedStringFromTableInBundle(@"Yes!", @"UserVoice", [UserVoice bundle], nil) forState:UIControlStateNormal];
    [yes setTitleColor:(IOS7 ? yes.tintColor : [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0]) forState:UIControlStateNormal];
    [yes addTarget:self action:@selector(yesButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    _yes = yes;
    UIButton *no = [UIButton new];
    [no setTitle:NSLocalizedStringFromTableInBundle(@"No", @"UserVoice", [UserVoice bundle], nil) forState:UIControlStateNormal];
    [no setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [no addTarget:self action:@selector(noButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    _no = no;
    NSArray *constraints = @[
        @"|[border]|", @"|-[label]-(>=10)-[yes]-30-[no]-30-|",
        @"V:|[border(==1)]", @"V:|-15-[label]", (IOS7 ? @"V:|-6-[yes]" : @"V:|-12-[yes]"), (IOS7 ? @"V:|-6-[no]" : @"V:|-12-[no]")
    ];
    [self configureView:footer
               subviews:NSDictionaryOfVariableBindings(border, label, yes, no)
            constraints:constraints];

    [self configureView:self.view
               subviews:NSDictionaryOfVariableBindings(_webView, footer)
            constraints:@[@"V:|[_webView]|", @"V:[footer]|", @"|[_webView]|", @"|[footer]|"]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:footer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:footerHeight]];
    [self.view bringSubviewToFront:footer];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (_helpfulPrompt) {
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        } else if (buttonIndex == 1) {
            [self dismiss];
        }
    } else {
        if (buttonIndex == 0) {
            [self presentModalViewController:[UVContactViewController new]];
        }
    }
}

- (void)yesButtonTapped {
    [UVBabayaga track:VOTE_ARTICLE id:_article.articleId];
    if (_deflectingType) {
        [UVDeflection trackDeflection:@"helpful" deflectingType:_deflectingType deflector:_article];
    }
    if (_helpfulPrompt) {
        // Do you still want to contact us?
        // Yes, go to my message
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:_helpfulPrompt
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", @"UserVoice", [UserVoice bundle], nil)
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:_returnMessage, NSLocalizedStringFromTableInBundle(@"No, I'm done", @"UserVoice", [UserVoice bundle], nil), nil];
        [actionSheet showInView:self.view];
    } else {
        _yes.hidden = YES;
        _no.hidden = YES;
        _footerLabel.text = NSLocalizedStringFromTableInBundle(@"Great! Glad we could help.", @"UserVoice", [UserVoice bundle], nil);
    }
}

- (void)noButtonTapped {
    if (_deflectingType) {
        [UVDeflection trackDeflection:@"not_helpful" deflectingType:_deflectingType deflector:_article];
    }
    if (_helpfulPrompt) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Would you like to contact us?", @"UserVoice", [UserVoice bundle], nil)
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"No", @"UserVoice", [UserVoice bundle], nil)
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedStringFromTableInBundle(@"Yes", @"UserVoice", [UserVoice bundle], nil), nil];
        [actionSheet showInView:self.view];
    }
}

@end
