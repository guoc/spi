//
//  UVImageCache.m
//  UserVoice
//
//  Created by Austin Taylor on 12/29/11.
//  Copyright (c) 2011 UserVoice Inc. All rights reserved.
//

#import "UVImageCache.h"

@implementation UVImageCache

+ (UVImageCache *)sharedInstance {
    static UVImageCache *instance;
    @synchronized(self) {
        if (!instance) {
            instance = [UVImageCache new];
        }
    }
    return instance;
}

- (UVImageCache *)init {
    if (self = [super init]) {
        maxItems = 20;
        cache = [[NSMutableDictionary alloc] initWithCapacity:maxItems];
        mostRecentlyUsed = [[NSMutableArray alloc] initWithCapacity:maxItems];
    }
    return self;
}

- (UIImage *)imageForURL:(NSString *)url {
    UIImage *image = [cache objectForKey:url];
    if (image) {
        [mostRecentlyUsed removeObject:url];
        [mostRecentlyUsed insertObject:url atIndex:0];
    } else {
    }
    return image;
}

- (void)setImage:(UIImage *)image forURL:(NSString *)url {
    if ([cache objectForKey:url]) {
        [cache setObject:image forKey:url];
        [mostRecentlyUsed removeObject:url];
        [mostRecentlyUsed insertObject:url atIndex:0];
    } else {
        if ([cache count] == maxItems) {
            id lru = [mostRecentlyUsed lastObject];
            [cache removeObjectForKey:lru];
            [mostRecentlyUsed removeObject:lru];
        }
        [cache setObject:image forKey:url];
        [mostRecentlyUsed insertObject:url atIndex:0];
    }
}

- (void)flush {
    [cache removeAllObjects];
    [mostRecentlyUsed removeAllObjects];
}

@end
