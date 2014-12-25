//
//  UVTextWithFieldsView.h
//  UserVoice
//
//  Created by Austin Taylor on 12/10/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UVTextView;

@interface UVTextWithFieldsView : UIScrollView<UITextViewDelegate>

@property (nonatomic, retain) UVTextView *textView;
@property (nonatomic, retain) id<UITextViewDelegate>textViewDelegate;

- (UITextField *)addFieldWithLabel:(NSString *)label;
- (void)updateLayout;

@end
