//
//  UVTicket.h
//  UserVoice
//
//  Created by Scott Rutherford on 26/04/2011.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UVBaseModel.h"

@class UVCustomField;

@interface UVTicket : UVBaseModel {
}

+ (id)createWithMessage:(NSString *)message
  andEmailIfNotLoggedIn:(NSString *)email
                andName:(NSString *)name
        andCustomFields:(NSDictionary *)customFields
            andDelegate:(id<UVModelDelegate>)delegate;

@end
