//
//  UVAttachment.h
//  UserVoice
//
//  Created by Adrian Schoenig on 19/05/2014.
//  Copyright (c) 2014 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UVAttachment : NSObject

@property (nonatomic, strong) NSString *base64EncodedData;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *contentType; // e.g., "image/jpeg"

@end
