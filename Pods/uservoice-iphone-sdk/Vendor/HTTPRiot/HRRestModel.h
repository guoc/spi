//
//  HRRestModel.h
//  HTTPRiot
//
//  Created by Justin Palmer on 1/28/09.
//  Copyright 2009 LabratRevenge LLC.. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "HRGlobal.h"

/**
 * This class allows you to easily interact with RESTful resources.  Responses are automatically
 * converted to the proper Objective-C type.  You can use this class directly or subclass it.
 * 
 * Using this class directly means that all requests share the same configuration 
 * (including delegate).  This works fine for simple situations but when you start dealing 
 * with different resource types it's best to subclass HRRestModel, giving each class its 
 * own set of configuation options.
 *
 *
 * In the code below all requests originating from <tt>Person</tt> will have an <tt>api_key</tt> 
 * default parameter, the same base url, and the same delegate.  See HRResponseDelegate for the 
 * the delegate methods available to you.
 *
 * @code
 *  @implementation Person
 *  + (void)initialize {
 *     [self setDelegate:self];
 *     NSDictionary *params = [NSDictionary dictionaryWithObject:@"1234567" forKey:@"api_key"];
 *     [self setBaseURL:[NSURL URLWithString:@"http://localhost:1234/api"]];    
 *     [self setDefaultParameters:params];
 *  }
 *
 * + (void)restConnection:(NSURLConnection *)connection didReturnResource:(id)resource object:(id)object {
 *      for(id person in resource) {
 *          // do something with a person dictionary   
 *      }  
 *  }
 *  @end
 *
 *  // Would send a request to http://localhost:1234/api/people/1?api_key=1234567
 *  [Person getPath:@"/people/1" withOptions:nil object:nil];
 * @endcode
 *
 * <h3>A note on default properties and subclassing</h3>
 * Each subclass has its own set of unique properties and these properties <em>are not</em>
 * inherited by any additional subclasses.
 */
@interface HRRestModel : NSObject {

}

/**
 * @name Setting default request options
 * Set the default options that can be used in every request made from the model 
 * that sets them.
 * @{ 
 */
 
/**
 * Returns the HRResponseDelegate
 */
+ (NSObject *)delegate;

/**
* Set the HRResponseDelegate
* @param del The HRResponseDelegate responsible for handling callbacks 
*/
+ (void)setDelegate:(NSObject *)del;

/**
 * The base url to use in every request
 */
+ (NSURL *)baseURL;

/** 
 * Set the base URL to be used in every request.
 *
 * Instead of providing a URL for every request you can set the base
 * url here.  You can also provide a path and port if you wish.  This 
 * url is prepended to the path argument of the request methods.
 *
 * @param url The base uri used in all request
 */
+ (void)setBaseURL:(NSURL *)url;

/**
 * Default headers sent with every request
 */
+ (NSDictionary *)headers;

/**
 * Set the default headers sent with every request.
 * @param hdrs An NSDictionary of headers.  For example you can 
 * set this up.
 *
 * @code
 * NSDictionary *hdrs = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"Accept"];
 * [self setHeaders:hdrs];
 * @endcode
 */
+ (void)setHeaders:(NSDictionary *)hdrs;

/**
 * Returns a dictionary containing the username and password used for basic auth.
 */
+ (NSDictionary *)basicAuth;

/**
 * Set the username and password used in requests that require basic authentication.
 *
 * The username and password privded here will be Base64 encoded and sent as an 
 * <code>Authorization</code> header.
 * @param username user name used to authenticate
 * @param password Password used to authenticate
 */
+ (void)setBasicAuthWithUsername:(NSString *)username password:(NSString *)password;

/**
 * Default params sent with every request.
 */
+ (NSDictionary *)defaultParams;

/**
 * Set the defaul params sent with every request.
 * If you need to send something with every request this is the perfect way to do it.
 * For GET request, these parameters will be appended to the query string.  For 
 * POST request these parameters are sent with the body.
 */
+ (void)setDefaultParams:(NSDictionary *)params;

/**
 * The format used to decode and encode request and responses.
 * Supported formats are JSON and XML.
 */
+ (HRDataFormat)format;

/**
 * Set the format used to decode and encode request and responses.
 */
+ (void)setFormat:(HRDataFormat)format;
//@}

/** 
 * @name Sending Requests
 * These methods allow you to send GET, POST, PUT and DELETE requetsts.
 *
 * <h3>Request Options</h3>
 * All requests can take numerous types of options passed as the second argument.
 * @li @b headers <tt>NSDictionary</tt> - The headers to send with the request
 * @li @b params <tt>NSDictionary</tt> - The query or body parameters sent with the request.
 * @li @b body <tt>NSData</tt>, <tt>NSString</tt> or <tt>NSDictionary</tt> - This option is used only during POST and PUT
 *     requests.  This option is eventually transformed into an NSData object before it is sent.
 *     If you supply the body as an NSDictionary it's turned to a query string &foo=bar&baz=boo and 
 *     then it's encoded as an NSData object.  If you supply an NSString, it's encoded as an NSData 
 *     object and sent.  
 * @{
 */
 
/**
 * Send a GET request
 * @param path The path to get.  If you haven't setup the baseURL option you'll need to provide a 
 *        full url. 
 * @param options The options for this request.
 * @param object An object to be passed to the delegate methods
 *
 */
+ (NSOperation *)getPath:(NSString *)path withOptions:(NSDictionary *)options object:(id)object;

/**
 * Send a POST request
 * @param path The path to POST to.  If you haven't setup the baseURL option you'll need to provide a 
 *        full url. 
 * @param options The options for this request.
 * @param object An object to be passed to the delegate methods
 *
 * <strong>Note:</strong> If you'd like to post raw data like JSON or XML you'll need to set the <tt>body</tt> option.
 *
 */
+ (NSOperation *)postPath:(NSString *)path withOptions:(NSDictionary *)options object:(id)object;

/**
 * Send a PUT request
 * @param path The path to PUT to.  If you haven't setup the baseURL option you'll need to provide a 
 *        full url. 
 * @param options The options for this request.
 * @param object An object to be passed to the delegate methods
 *
 * @remarks <strong>Note:</strong>  All data found in the <tt>body</tt> option will be PUT.  Setting the <tt>body</tt>
 * option will cause the <tt>params</tt> option to be ignored.
 *
 */
+ (NSOperation *)putPath:(NSString *)path withOptions:(NSDictionary *)options object:(id)object;

/**
 * Send a DELETE request
 * @param path The path to DELETE.  If you haven't setup the baseURL option you'll need to provide a 
 *        full url. 
 * @param options The options for this request.
 * @param object An object to be passed to the delegate methods
 *
 */
+ (NSOperation *)deletePath:(NSString *)path withOptions:(NSDictionary *)options object:(id)object;
//@}
//

// UV added so we can override some things
+ (NSMutableDictionary *)mergedOptions:(NSDictionary *)options;
@end
