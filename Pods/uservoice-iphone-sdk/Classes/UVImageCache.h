//
//  UVImageCache.h
//  UserVoice
//
//  Created by Austin Taylor on 12/29/11.
//  Copyright (c) 2011 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UVImageCache : NSObject {
    NSInteger maxItems;
    NSMutableDictionary *cache;
    NSMutableArray *mostRecentlyUsed;
}

+ (UVImageCache *)sharedInstance;
- (void)setImage:(UIImage *)image forURL:(NSString *)url;
- (UIImage *)imageForURL:(NSString *)url;
- (void)flush;

@end
