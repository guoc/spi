//
//  UVTruncatingLabel.h
//  UserVoice
//
//  Created by Austin Taylor on 12/4/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UVTruncatingLabelDelegate;

@interface UVTruncatingLabel : UIView

@property (nonatomic, retain) NSString *fullText;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, assign) CGFloat preferredMaxLayoutWidth;
@property (nonatomic, weak) id<UVTruncatingLabelDelegate> delegate;

- (void)expand;

@end

@protocol UVTruncatingLabelDelegate <NSObject>
- (void)labelExpanded:(UVTruncatingLabel *)label;
@end
