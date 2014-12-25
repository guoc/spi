//
//  UVImageView.h
//  UserVoice
//
//  Created by Scott Rutherford on 29/06/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import "UVImageView.h"
#import "UVImageCache.h"
#import <QuartzCore/QuartzCore.h>

@implementation UVImageView

- (void)drawRect:(CGRect)rect {
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.masksToBounds = YES;
    if (_image) {
        [_image drawInRect:rect];
    } else {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        if (ctx) {
            CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1.f].CGColor);
            CGContextFillRect(ctx, self.bounds);
            CGContextFlush(ctx);
        }
    }
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    [_payload appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    UIImage *anImage = [UIImage imageWithData:_payload];

    if (anImage) {
        _image = anImage;
        [self setNeedsDisplay];
        [[UVImageCache sharedInstance] setImage:_image forURL:_URL];
    }

    _connection = nil;
    _payload = nil;
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    _payload = nil;
    _connection = nil;
}

- (void)setURL:(NSString*)URL {
    if (_image && _URL && [URL isEqualToString:_URL])
        return;

    [self stopLoading];
    _URL = URL;

    if (_URL && _URL.length) {
        _image = [[UVImageCache sharedInstance] imageForURL:_URL];
        [self setNeedsDisplay];
        if (!_image)
            [self reload];
    }
}

- (void)setImage:(UIImage*)image {
    _image = image;
}

- (void)reload {
    if (_URL) {
        NSURL *url = [NSURL URLWithString:_URL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];

        [self stopLoading];
        _connection = [NSURLConnection connectionWithRequest:request delegate:self];

        if (_connection) {
            _payload = [NSMutableData data];
            _image = nil;
        } else {
            NSLog(@"Unable to start download.");
        }
    }
}

- (void)stopLoading {
    [_connection cancel];
    _connection = nil;
    _payload = nil;
}

- (void)dealloc {
    [self stopLoading];
}

@end
