//
//  UVDefines.h
//  UserVoice
//
//  Created by Austin Taylor on 8/27/13.
//  Copyright (c) 2013 UserVoice Inc. All rights reserved.
//

#define IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define FORMSHEET (self.parentViewController.view.frame.size.width < [UIScreen mainScreen].bounds.size.width)

#ifdef __IPHONE_7_0
#define IOS7 ([UIDevice currentDevice].systemVersion.floatValue >= 7)
#else
#define IOS7 (NO)
#endif


#ifdef __IPHONE_8_0
#define IOS8 ([UIDevice currentDevice].systemVersion.floatValue >= 8)
#else
#define IOS8 (NO)
#endif

#define UIColorFromRGB(rgbValue) [UIColor \
  colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
         green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
          blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
