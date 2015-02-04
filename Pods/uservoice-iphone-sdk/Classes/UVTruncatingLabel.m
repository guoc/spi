//
//  UVTruncatingLabel.m
//  UserVoice
//
//  Created by Austin Taylor on 12/4/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import "UVTruncatingLabel.h"
#import "UserVoice.h"
#import "UVDefines.h"
#import "UVUtils.h"
#import "UVCalculatingLabel.h"

@implementation UVTruncatingLabel {
    BOOL _expanded;
    CGFloat _lastWidth;
    UILabel *_moreLabel;
    UVCalculatingLabel *_label;
    NSString *_fullText;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandAndNotify)]];
        _label = [UVCalculatingLabel new];
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        _label.numberOfLines = 0;
        _moreLabel = [UILabel new];
        _moreLabel.text = NSLocalizedStringFromTableInBundle(@"more", @"UserVoice", [UserVoice bundle], nil);
        _moreLabel.font = [UIFont systemFontOfSize:12];
        _moreLabel.backgroundColor = [UIColor clearColor];
        _moreLabel.hidden = YES;
        if (IOS7) {
            // TODO hardcode blue for ios6 ??
            _moreLabel.textColor = self.tintColor;
        }
        [UVUtils configureView:self subviews:@{@"more":_moreLabel, @"label":_label} constraints:@[@"|[label]|", @"[more]|", @"V:|[label]|", @"V:[more]-(1)-|"]];
    }
    return self;
}

- (void)setFullText:(NSString *)theText {
    _fullText = theText;
    [self update];
}

- (void)setFont:(UIFont *)font {
    _label.font = font;
    [self update];
}

- (UIFont *)font {
    return _label.font;
}

- (void)setTextColor:(UIColor *)textColor {
    _label.textColor = textColor;
}

- (UIColor *)textColor {
    return _label.textColor;
}

- (void)update {
    if (!_fullText || self.effectiveWidth <= 0) return;
    _label.text = _fullText;
    _lastWidth = self.effectiveWidth;
    _label.preferredMaxLayoutWidth = self.effectiveWidth;
    if (_expanded) {
        _moreLabel.hidden = YES;
    } else {
        NSArray *lines = [_label breakString:self.effectiveWidth];
        if ([lines count] > 3) {
            CGSize moreSize = [_moreLabel intrinsicContentSize];
            _label.text = [NSString stringWithFormat:@"%@%@%@", [lines objectAtIndex:0], [lines objectAtIndex:1], [lines objectAtIndex:2]];
            int i = (int)[_label.text length] - 1;
            CGRect r = [_label rectForLetterAtIndex:i lines:lines width:self.effectiveWidth];
            while (self.effectiveWidth - r.origin.x - r.size.width < (34 + moreSize.width) && i > 0) {
                i--;
                r = [_label rectForLetterAtIndex:i lines:lines width:self.effectiveWidth];
            }
            _label.text = [NSString stringWithFormat:@"%@...", [_label.text substringWithRange:NSMakeRange(0, i+1)]];
            _moreLabel.hidden = NO;
        } else {
            _moreLabel.hidden = YES;
        }
    }
}

- (CGSize)intrinsicContentSize {
    if (_lastWidth != self.effectiveWidth) {
        [self update];
    }
    return [_label intrinsicContentSize];
}

- (CGFloat)effectiveWidth {
    return MAX(self.frame.size.width, self.preferredMaxLayoutWidth) - 4;
}

- (void)layoutSubviews {
    if (_lastWidth != self.effectiveWidth) {
        [self update];
    }
    [super layoutSubviews];
}

- (void)expandAndNotify {
    [self expand];
    [_delegate performSelector:@selector(labelExpanded:) withObject:self];
}

- (void)expand {
    _expanded = YES;
    [self update];
}

@end
