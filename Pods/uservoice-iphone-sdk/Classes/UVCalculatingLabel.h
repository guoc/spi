//
//  UVCalculatingLabel.h
//  UserVoice
//
//  Created by Austin Taylor on 12/4/12.
//  Copyright (c) 2012 UserVoice Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UVCalculatingLabel : UILabel

- (NSArray *)breakString:(CGFloat)frameWidth;
- (CGRect)rectForLetterAtIndex:(NSUInteger)index lines:(NSArray *)lines width:(CGFloat)frameWidth;

@end
