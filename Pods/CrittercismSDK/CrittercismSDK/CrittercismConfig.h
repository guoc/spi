//
//  CrittercismConfig.h
//  Crittercism-iOS
//
//  Created by David Shirley 2 on 1/8/15.
//  Copyright (c) 2015 Crittercism. All rights reserved.
//
//  This object is used to specify various configuration options to Crittercism.
//  Once this object is setup, you can pass it to [Crittercism enableWithAppID].
//  After Crittercism is initialized, changes to this object will have no affect.

#import <Foundation/Foundation.h>
#import "CrittercismDelegate.h"

@interface CrittercismConfig : NSObject

// Determines whether Service Monitoring should capture network performance
// information for network calls made through NSURLConnection.
// Default value: YES
@property (assign) BOOL monitorNSURLConnection;

// Determines whether Service Monitoring should capture network performance
// information for network calls made through NSURLSession.
// Default value: YES
@property (assign) BOOL monitorNSURLSession;

// Determines whether Service Monitoring should capture network performance
// information for network calls made through a UIWebView. Currently only page
// loads and page transitions are captured. Calls made via javascript are currently
// not captured.
//
// The default value is "disabled" because use of the UIWebView
// class has the side effect of calling [UIWebView initialize], which causes a
// new thread to get spawned to manage UIWebViews. Because we cannot prevent
// this side effect from happening, and many apps do not use web views we would
// rather not spawn threads that you don't want. Hence this service monitoring
// for UIWebViews must be explicitly enabled.
//
// Default value: NO
@property (assign) BOOL monitorUIWebView;

// This flag determines wither Crittercism service monitoring is enabled at all.
// If this flag is set to NO, then no instrumentation will be installed AND
// the thread that sends service monitoring data will be disabled.
// Default value: YES (enabled)
@property (assign) BOOL enableServiceMonitoring;

// An array of CRFilter objects. These filters are used to make it so certain
// network performance information is not reported to Crittercism, for example
// URLs that may contain sensitive information. These filters can also be used
// to prevent URL query parameters from being stripped out (by default all query
// parameters are removed before being sent to Crittercism).
@property (nonatomic, retain) NSArray *urlFilters;

// This object provides a callback that Crittercism will use to notify an app
// that the app crashed on the last load.
@property (retain) id<CrittercismDelegate> delegate;

// Creates a new CrittercismConfig object with the default values for the above
// properties. You can modify the config values and pass this object into
// [Crittercism enableWithAppID:andConfig]
+ (CrittercismConfig *)defaultConfig;

- (NSString *)description;

@end
