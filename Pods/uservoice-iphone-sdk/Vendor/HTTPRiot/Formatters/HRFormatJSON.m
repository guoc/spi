//
//  HRFormatJSON.m
//  HTTPRiot
//
//  Created by Justin Palmer on 2/8/09.
//  Copyright 2009 Alternateidea. All rights reserved.
//

#import "HRFormatJSON.h"
#import "UVUtils.h"

@implementation HRFormatJSON
+ (NSString *)extension {
    return @"json";
}

+ (NSString *)mimeType {
    return @"application/json";
}

+ (id)decode:(NSData *)data error:(NSError * __autoreleasing *)error {
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
}

+ (NSString *)encode:(id)data error:(NSError * __autoreleasing *)error {
    return [UVUtils encodeJSON:data];
}
@end
