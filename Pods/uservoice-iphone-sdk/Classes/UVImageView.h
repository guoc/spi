//
//  UVImageView.h
//  UserVoice
//
//  Created by Scott Rutherford on 29/06/2010.
//  Copyright 2010 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UVImageView : UIView

@property (nonatomic, retain) NSString* URL;
@property (nonatomic, retain) UIImage* image;
@property (nonatomic, retain) UIImage* defaultImage;
@property (nonatomic, retain) NSMutableData* payload;
@property (nonatomic, retain) NSURLConnection* connection;

- (void)reload;
- (void)stopLoading;

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)conn;
- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error;

@end
