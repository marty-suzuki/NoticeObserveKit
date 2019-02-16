//
//  NoticeObserveKit.h
//  NoticeObserveKit
//
//  Created by marty-suzuki on 2019/02/16.
//  Copyright © 2019 marty-suzuki. All rights reserved.
//

#import "TargetConditionals.h"

#if TARGET_OS_WATCH
#import <WatchKit/WatchKit.h>
#elif TARGET_OS_IOS || TARGET_OS_TV
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif



//! Project version number for NoticeObserveKit.
FOUNDATION_EXPORT double NoticeObserveKitVersionNumber;

//! Project version string for NoticeObserveKit.
FOUNDATION_EXPORT const unsigned char NoticeObserveKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <NoticeObserveKit/PublicHeader.h>


