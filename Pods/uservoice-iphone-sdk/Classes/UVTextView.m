//
//  UVTextView.m
//  UserVoice
//
//  Created by UserVoice on 10/12/12.
//  Copyright 2012 UserVoice Inc. All rights reserved.
//

#import "UVTextView.h"
#import "UVDefines.h"

@implementation UVTextView {
    BOOL _constraintsAdded;
    BOOL _added;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
        
        self.contentSize = CGSizeMake(0, 20);
        self.font = [UIFont systemFontOfSize:15];
        _placeholderLabel = [UILabel new];
        _placeholderLabel.font = self.font;
        _placeholderLabel.textColor = IOS7 ? [UIColor colorWithRed:0.78f green:0.78f blue:0.80f alpha:1.0f] : [UIColor colorWithWhite:0.702f alpha:1.0f];
        _placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_constraintsAdded && _placeholderLabel.superview) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[placeholder]" options:0 metrics:nil views:@{@"placeholder":_placeholderLabel}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:(IOS7 ? @"|-4-[placeholder]" : @"|-8-[placeholder]") options:0 metrics:nil views:@{@"placeholder":_placeholderLabel}]];
        _constraintsAdded = YES;
    }
    [super layoutSubviews];
}

- (void)setPlaceholder:(NSString *)newPlaceholder {
    _placeholderLabel.text = newPlaceholder;
    [self updateShouldDrawPlaceholder];
}

- (NSString *)placeholder {
    return _placeholderLabel.text;
}

- (void)updateShouldDrawPlaceholder {
    if (_added && self.text.length != 0) {
        [_placeholderLabel removeFromSuperview];
        _added = NO;
        _constraintsAdded = NO;
    } else if (!_added && self.text.length == 0) {
        [self addSubview:_placeholderLabel];
        _added = YES;
        [self layoutSubviews];
    }
}

- (void)setText:(NSString *)string {
    [super setText:string];
    [self updateShouldDrawPlaceholder];
}

- (void)textChanged:(NSNotification *)notification {
    [self updateShouldDrawPlaceholder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

@end
