//
//  UVTextWithFieldsView.m
//  UserVoice
//
//  Created by Austin Taylor on 12/10/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVTextWithFieldsView.h"
#import "UVTextView.h"
#import "UVUtils.h"
#import "UVDefines.h"

@implementation UVTextWithFieldsView {
    NSLayoutConstraint *_heightConstraint;
    NSLayoutConstraint *_topConstraint;
    UIView *_lastContainer;
}

- (id)init {
    self = [super init];
    if (self) {
        _textView = [UVTextView new];
        _textView.delegate = self;
        _textView.scrollEnabled = NO;
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        [UVUtils configureView:self
                      subviews:NSDictionaryOfVariableBindings(_textView)
                   constraints:@[@"|-12-[_textView]-|"]];
        _heightConstraint = [NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:500];
        _topConstraint = [NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:4.0];
        [self addConstraints:@[_heightConstraint, _topConstraint]];
    }
    return self;
}

- (void)didMoveToSuperview {
    for (UIView *view in self.subviews) {
        CGFloat constant = (view == _textView) ? -32.0 : 0;
        [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeWidth multiplier:1.0 constant:constant]];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (!IOS7) {
        [self updateLayout];
    }
    [_textViewDelegate textViewDidChange:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    [self updateLayout];
}

- (void)setContentInset:(UIEdgeInsets)insets {
    [super setContentInset:insets];
    [self updateLayout];
}

- (void)updateLayout {
    CGSize contentSize = [_textView sizeThatFits:CGSizeMake(_textView.frame.size.width, MAXFLOAT)];
    CGFloat height = MAX(60.0f, MAX(contentSize.height, self.bounds.size.height - self.contentInset.top - self.contentInset.bottom - _textView.frame.origin.y));
    _heightConstraint.constant = height;
    self.contentSize = CGSizeMake(0, _textView.frame.origin.y + height);
    CGRect rect = [_textView caretRectForPosition:_textView.selectedTextRange.end];
    if (rect.origin.x == INFINITY || rect.size.height < 2) {
        // caretRectForPosition: gives wonky results sometimes. let's just scroll to the bottom.
        // also, when this happens, sizeThatFits: will be off by about a line. (WHY)
        self.contentSize = CGSizeMake(0, self.contentSize.height + _textView.font.lineHeight);
        rect = CGRectMake(0, _textView.contentSize.height + _textView.font.lineHeight - 1, 1, 1);
    }
    CGFloat top = rect.origin.y + _textView.frame.origin.y;
    CGFloat bottom = top + rect.size.height;
    if (top < self.contentOffset.y + self.contentInset.top) {
        [self setContentOffset:CGPointMake(0, top - self.contentInset.top) animated:NO];
    } else if (bottom > self.contentOffset.y + self.bounds.size.height - self.contentInset.bottom) {
        // if you type really fast sometimes the rect returned is way too far down (WHYWHYWHY)
        CGFloat offset = bottom - self.bounds.size.height + self.contentInset.bottom;
        CGFloat maxOffset = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom;
        [self setContentOffset:CGPointMake(0, MIN(offset, maxOffset)) animated:NO];
    }
}

- (UITextField *)addFieldWithLabel:(NSString *)labelText {
    [self removeConstraint:_topConstraint];
    UIView *container = [UIView new];
    UITextField *field = [UITextField new];
    [field setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    UILabel *label = [UILabel new];
    label.text = [NSString stringWithFormat:@"%@:", labelText];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    [label setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    UIView *separator = [UIView new];
    separator.backgroundColor = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.f];
    [UVUtils configureView:container
                  subviews:NSDictionaryOfVariableBindings(field, label, separator)
               constraints:@[@"|-16-[label]-[field]-|", @"|-16-[separator]|", @"V:|-12-[label]", @"V:|-12-[field]", @"V:[separator(==1)]|"]];
    [UVUtils configureView:self
                  subviews:NSDictionaryOfVariableBindings(container)
               constraints:@[@"|[container]", @"V:[container(==44)]"]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:container attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:(_lastContainer ? _lastContainer : self) attribute:(_lastContainer ? NSLayoutAttributeBottom : NSLayoutAttributeTop) multiplier:1.0 constant:0]];
    _topConstraint = [NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeBottom multiplier:1.0 constant:4.0];
    [self addConstraint:_topConstraint];
    _lastContainer = container;
    return field;
}

- (void)dealloc {
    if (_textView) {
        _textView.delegate = nil;
    }
}

@end
