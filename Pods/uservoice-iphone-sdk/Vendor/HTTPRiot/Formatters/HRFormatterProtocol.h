/**
 * @file HRFormatterProtocol.h Protocol for the formatters.
 */
 
//
//  HRFormatterProtocol.h
//  HTTPRiot
//
//  Created by Justin Palmer on 2/8/09.
//  Copyright 2009 Alternateidea. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 * @protocol HRFormatterProtocol
 * 
 * Formatters used in formatting response data
 * Formatters should be able to encode and decode a specific data type.
 */
@protocol HRFormatterProtocol 

/**
 * The file extension.  Example: json, xml, plist, n3, etc.
 */
+ (NSString *)extension;

/**
 * The mime-type represented by this formatter
 */
+ (NSString *)mimeType;

/**
 * Takes the format and turns it into the appropriate Obj-C data type.
 *
 * @param data Raw data to be decoded.
 * @param error Returns any errors that happened while decoding.
 */
+ (id)decode:(NSData *)data error:(NSError * __autoreleasing *)error;

/**
 * Takes an Obj-C data type and turns it into the proper format.
 *
 * @param object The Obj-C object to be encoded by the formatter.
 * @param error Returns any errors that happened while encoding.
 */
+ (NSString *)encode:(id)object error:(NSError * __autoreleasing *)error;
@end
