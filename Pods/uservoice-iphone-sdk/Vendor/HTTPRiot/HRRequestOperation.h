//
//  HRRequestOperation.h
//  HTTPRiot
//
//  Created by Justin Palmer on 1/30/09.
//  Copyright 2009 LabratRevenge LLC.. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "HRGlobal.h"
#import "HRResponseDelegate.h"

/**
 * The object which all requests are routed through.  You shouldn't need to use 
 * this class directly, but instead use HRRestModel which wraps the method 
 * of this class neatly.
 */
@interface HRRequestOperation : NSOperation {
    /// Connection object
    NSURLConnection *_connection;
    
    /// Data received from response
    NSMutableData   *_responseData;
    
    /// The object passed to all delegate methods
    id              _object;
    
    /// Determines whether the operation is finished
    BOOL _isFinished;
    
    /// Determines whether the operation is executing
    BOOL _isExecuting;
    
    /// Determines whether the connection is cancelled
    BOOL _isCancelled;
}

/// The HRResponseDelegate
/**
 * The HRResponseDelegate responsible for handling the success and failure of 
 * a request.
 */
@property (nonatomic, readonly) NSObject <HRResponseDelegate>*delegate;
 
/// The lenght of time in seconds before the request times out.
/**
 * Sets the length of time in seconds before a request will timeout.
 * This defaults to <tt>30.0</tt>.
 */
@property (nonatomic, assign) NSTimeInterval timeout;

/// The REST method to use when performing a request
/**
 * This defaults to HRRequestMethodGet.  Valid options are ::HRRequestMethod.
 */
@property (nonatomic, assign) HRRequestMethod requestMethod;

/// The relative path or url string used in a request
/**
 If you provide a relative path here, you must set the baseURL option.
 If given a full url this will overide the baseURL option.
 */
@property (nonatomic, copy) NSString *path;

/// An NSDictionary containing all the options for a request.
/**
 This needs documented
 */
@property (nonatomic, retain) NSDictionary *options;

/// The formatter used to decode the response body.
/**
 Currently, only JSON is supported.
 */
@property (nonatomic, readonly, retain) id formatter;

/**
 * Returns an HRRequestOperation
 */
+ (HRRequestOperation *)requestWithMethod:(HRRequestMethod)method path:(NSString*)urlPath options:(NSDictionary*)requestOptions object:(id)obj;
@end
