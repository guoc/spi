//
//  UVUtils.m
//  UserVoice
//
//  Created by Austin Taylor on 4/29/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#import "UVUtils.h"
#import "UVDefines.h"
#import "UVStyleSheet.h"
#import "UserVoice.h"

@implementation UVUtils

+ (NSString *)toQueryString:(NSDictionary *)dict {
    if (dict == nil)
        return nil;
    NSMutableArray *pairs = [NSMutableArray new];
    for (id key in [dict allKeys]) {
        id value = [dict objectForKey:key];
        if ([value isKindOfClass:[NSArray class]]) {
            for (id val in value) {
                [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [self URLEncode:val]]];
            }
        } else {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [self URLEncode:value]]];
        }
    }
    return [pairs componentsJoinedByString:@"&"];
}

+ (NSString *)URLEncode:(NSString *)str {
    if (str == nil)
        return nil;
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)str, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
    return result;
}

+ (NSString *)URLDecode:(NSString *)str {
    if (str == nil)
        return nil;
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (__bridge CFStringRef)str, CFSTR(""), kCFStringEncodingUTF8);
    return result;
}

+ (NSString *)decodeHTMLEntities:(NSString *)str {
    if (str == nil)
        return nil;
    // TODO: Replace this with something more efficient/complete
    NSMutableString *string = [NSMutableString stringWithString:str];
    [string replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&apos;" withString:@"'"  options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&amp;"  withString:@"&"  options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&lt;"   withString:@"<"  options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&gt;"   withString:@">"  options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&#34;" withString:@"\""  options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&#39;" withString:@"'"  options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&#38;" withString:@"&"  options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&#60;" withString:@"<"  options:0 range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&#62;" withString:@">"  options:0 range:NSMakeRange(0, [string length])];
    return string;
}

+ (NSString *)encodeJSON:(id)obj {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:&error];
    if (error) {
        NSLog(@"+encodeJSON failed. Error: %@", error);
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (UIColor *)parseHexColor:(NSString *)str {
    if (str == nil)
        return nil;
    if ([str length] > 0 && [str characterAtIndex:0] == '#') {
        str = [str substringFromIndex:1];
    }
    NSScanner *scanner = [NSScanner scannerWithString:str];
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

+ (NSData *)decode64:(NSString *)string {
	if (string == nil)
		return nil;
	if ([string length] == 0)
		return [NSData data];
	
	static char *decodingTable = NULL;
	if (decodingTable == NULL)
	{
		decodingTable = malloc(256);
		if (decodingTable == NULL)
			return nil;
		memset(decodingTable, CHAR_MAX, 256);
		NSUInteger i;
		for (i = 0; i < 64; i++)
			decodingTable[(short)encodingTable[i]] = (char)i;
	}
	
	const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
	if (characters == NULL)     //  Not an ASCII string!
		return nil;
	char *bytes = malloc((([string length] + 3) / 4) * 3);
	if (bytes == NULL)
		return nil;
	NSUInteger length = 0;
    
	NSUInteger i = 0;
	while (YES)
	{
		char buffer[4];
		short bufferLength;
		for (bufferLength = 0; bufferLength < 4; i++)
		{
			if (characters[i] == '\0')
				break;
			if (isspace(characters[i]) || characters[i] == '=')
				continue;
			buffer[bufferLength] = decodingTable[(short)characters[i]];
			if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
			{
				free(bytes);
				return nil;
			}
		}
		
		if (bufferLength == 0)
			break;
		if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
		{
			free(bytes);
			return nil;
		}
		
		//  Decode the characters in the buffer to bytes.
		bytes[length++] = (char)(buffer[0] << 2) | (buffer[1] >> 4);
		if (bufferLength > 2)
			bytes[length++] = (char)(buffer[1] << 4) | (buffer[2] >> 2);
		if (bufferLength > 3)
			bytes[length++] = (char)(buffer[2] << 6) | buffer[3];
	}
	
	realloc(bytes, length);
	return [NSData dataWithBytesNoCopy:bytes length:length];
}

+ (NSString *)encodeData64:(NSData *)data {
    if (data == nil)
        return nil;
	if ([data length] == 0)
		return @"";
    
    char *characters = malloc((([data length] + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < [data length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [data length])
			buffer[bufferLength++] = ((char *)[data bytes])[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';
	}
	
	NSString *str = [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

+ (NSString *)encode64:(NSString *)data {
    return [self encodeData64:[data dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (BOOL)isConnectionError:(NSError *)error {
    return ([error.domain isEqualToString:NSURLErrorDomain]) && (
        error.code == NSURLErrorTimedOut ||
        error.code == NSURLErrorCannotConnectToHost ||
        error.code == NSURLErrorNetworkConnectionLost ||
        error.code == NSURLErrorNotConnectedToInternet);
}

+ (BOOL)isUVRecordInvalid:(NSError *)error {
    return [[error domain] isEqualToString:@"uservoice"] && [[[error userInfo] objectForKey:@"type"] isEqualToString:@"record_invalid"];
}

+ (BOOL)isUVRecordInvalid:(NSError *)error forField:(NSString *)field withMessage:(NSString *)message {
    if (![UVUtils isUVRecordInvalid:error])
        return NO;

    NSString *errorStr = [[error userInfo] objectForKey:field];
    if (!errorStr)
        return NO;
    return [errorStr rangeOfString:message].location != NSNotFound;
}

+ (BOOL)isAuthError:(NSError *)error {
    return [error code] == 401;
}

+ (BOOL)isNotFoundError:(NSError *)error {
    return [error code] == 404;
}

+ (void)applyStylesheetToNavigationController:(UINavigationController *)navigationController {
    UVStyleSheet *styles = [UVStyleSheet instance];
    if (IOS7) {
        navigationController.navigationBar.tintColor = styles.navigationBarTintColor;
        navigationController.navigationBar.barTintColor = styles.navigationBarBackgroundColor;
    } else {
        navigationController.navigationBar.tintColor = styles.navigationBarBackgroundColor;
    }
    [navigationController.navigationBar setBackgroundImage:styles.navigationBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    NSMutableDictionary *navbarTitleTextAttributes = [[NSMutableDictionary alloc] initWithDictionary:navigationController.navigationBar.titleTextAttributes];
    if (styles.navigationBarTextColor) {
        [navbarTitleTextAttributes setObject:styles.navigationBarTextColor forKey:NSForegroundColorAttributeName];
    }
    if (styles.navigationBarTextShadowColor) {
        NSShadow *shadow = [NSShadow new];
        shadow.shadowColor = styles.navigationBarTextShadowColor;
        shadow.shadowOffset = CGSizeMake(1, 0);
        [navbarTitleTextAttributes setObject:shadow forKey:NSShadowAttributeName];
    }
    if (styles.navigationBarFont) {
        [navbarTitleTextAttributes setObject:styles.navigationBarFont forKey:NSFontAttributeName];
    }
    [navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
}

+ (NSString *)formatInteger:(NSInteger)number {
    NSNumberFormatter *fmt = [NSNumberFormatter new];
    [fmt setNumberStyle:NSNumberFormatterDecimalStyle];
    [fmt setMaximumFractionDigits:0];
    return [fmt stringFromNumber:@(number)];
}

+ (NSString *)colorToCSS:(UIColor *)color {
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"#%02X%02X%02X", (unsigned)round(MAX(0, MIN(r, 1)) * 255), (unsigned)round(MAX(0, MIN(g, 1)) * 255), (unsigned)round(MAX(0, MIN(b, 1)) * 255)];
}

+ (void)configureView:(UIView *)superview subviews:(NSDictionary *)viewsDict constraints:(NSArray *)constraintStrings {
    [self configureView:superview subviews:viewsDict constraints:constraintStrings finalCondition:NO finalConstraint:nil];
}

+ (void)configureView:(UIView *)superview subviews:(NSDictionary *)viewsDict constraints:(NSArray *)constraintStrings finalCondition:(BOOL)includeFinalConstraint finalConstraint:(NSString *)finalConstraint {
    for (NSString *key in [viewsDict keyEnumerator]) {
        UIView *view = viewsDict[key];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [superview addSubview:view];
    }
    for (NSString *constraintString in constraintStrings) {
        [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintString options:0 metrics:nil views:viewsDict]];
    }
    if (includeFinalConstraint) {
        [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:finalConstraint options:0 metrics:nil views:viewsDict]];
    }
}

+ (UIImage *)imageNamed:(NSString *)name {
    return [UIImage imageWithContentsOfFile:[[[UserVoice bundle] resourcePath] stringByAppendingPathComponent:name]];
}

+ (UIImageView *)imageViewWithImageNamed:(NSString *)name {
    return [[UIImageView alloc] initWithImage:[UVUtils imageNamed:name]];
}

+ (CGSize)string:(NSString *)string sizeWithFont:(UIFont *)font {
    CGSize sizeWithFont = CGSizeZero;
    
    if ([string respondsToSelector:@selector(sizeWithAttributes:)]) {
        sizeWithFont = [string sizeWithAttributes:@{NSFontAttributeName: font}];
    } else {
        // this means we are running on a system older than iOS7, since `sizeWithAttributes:` was added in iOS7.
        // so we need to use `sizeWithFont:`
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        sizeWithFont = [string sizeWithFont:font];
#pragma clang diagnostic pop
    }
    
    return sizeWithFont;
}

+ (CGSize)string:(NSString *)string sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
    CGSize sizeWithFont = CGSizeZero;
    
    if ([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = lineBreakMode;
        
        NSDictionary * attributes = @{NSFontAttributeName : font,
                                      NSParagraphStyleAttributeName : [paragraphStyle copy]};
        
        sizeWithFont = [string boundingRectWithSize:size
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                         attributes:attributes
                                            context:nil].size;
    } else {
        // this means we are running on a system older than iOS7, since `sizeWithAttributes:` was added in iOS7.
        // so we need to use `sizeWithFont:`
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        sizeWithFont = [string sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    
    return sizeWithFont;
}


@end
