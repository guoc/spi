//
//  UVTicket.m
//  UserVoice
//
//  Created by Scott Rutherford on 26/04/2011.
//  Copyright 2011 UserVoice Inc. All rights reserved.
//


// format                String - xml, json
// ticket[custom_field_values][_field_name_] String - Replace _field_name_ with the name of your custom field
// ticket[lang]          String
// ticket[message]       String - required
// ticket[referrer]      String
// ticket[subject]       String - required
// ticket[submitted_via] String - Your name for where this ticket came from (ex: web, email)
// ticket[user_agent]    String
// ticket[attachments]   Array  - Strings for 'name', 'data' (base64 encoded) and 'contentType'

#import "UVTicket.h"
#import "UVCustomField.h"
#import "UVSession.h"
#import "UVConfig.h"
#import "UVBabayaga.h"
#import "UVDeflection.h"
#import "UVAttachment.h"

@implementation UVTicket

+ (id)createWithMessage:(NSString *)message
  andEmailIfNotLoggedIn:(NSString *)email
                andName:(NSString *)name
        andCustomFields:(NSDictionary *)fields
            andDelegate:(id<UVModelDelegate>)delegate {
    NSString *path = [self apiPath:@"/tickets.json"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        message == nil ? @"" : message, @"ticket[message]",
        email   == nil ? @"" : email,   @"email",
        name    == nil ? @"" : name,    @"display_name",
        [NSString stringWithFormat:@"%d", (int)[UVDeflection interactionIdentifier]], @"interaction_identifier",
        nil];
    
    for (NSString *scope in [UVSession currentSession].externalIds) {
        NSString *identifier = [[UVSession currentSession].externalIds valueForKey:scope];
        [params setObject:identifier forKey:[NSString stringWithFormat:@"created_by[external_ids][%@]", scope]];
    }

    NSDictionary *defaultFields = [UVSession currentSession].config.customFields;
    for (NSString *key in [defaultFields keyEnumerator]) {
        [params setObject:[defaultFields objectForKey:key] forKey:[NSString stringWithFormat:@"ticket[custom_field_values][%@]", key]];
    }

    for (NSString *key in [fields keyEnumerator]) {
        [params setObject:[fields objectForKey:key] forKey:[NSString stringWithFormat:@"ticket[custom_field_values][%@]", key]];
    }

    if ([UVSession currentSession].config.extraTicketInfo != nil) {
        NSString *messageText = [NSString stringWithFormat:@"%@\n\n%@", message, [UVSession currentSession].config.extraTicketInfo];
        [params setObject:messageText forKey:@"ticket[message]"];
    }

    if ([UVBabayaga instance].uvts) {
        [params setObject:[UVBabayaga instance].uvts forKey:@"uvts"];
    }
    
    if ([UVSession currentSession].config.attachments) {
        NSArray *attachments = [UVSession currentSession].config.attachments;
        NSInteger index = 0;
        for (UVAttachment *attachment in attachments) {
            [params setObject:attachment.fileName forKey:[NSString stringWithFormat:@"ticket[attachments][%li][name]", (long)index]];
            
            [params setObject:attachment.base64EncodedData forKey:[NSString stringWithFormat:@"ticket[attachments][%li][data]", (long)index]];
            
            [params setObject:attachment.contentType forKey:[NSString stringWithFormat:@"ticket[attachments][%li][content_type]", (long)index]];
            index++;
        }
    }

    return [[self class] postPath:path
                       withParams:params
                           target:delegate
                         selector:@selector(didCreateTicket:)
                          rootKey:@"ticket"];
}

@end
