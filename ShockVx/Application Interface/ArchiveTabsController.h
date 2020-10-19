//
//  project: ShockVx
//     file: ArchiveTabsController.h
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SensorDevice.h"

// The tab items in the storyboard have tag numbers set
// their index.

typedef NS_ENUM( NSUInteger, ArchiveTabIndex ) {

    kArchiveTabIndexAmbient,
    kArchiveTabIndexSurface,

};

@interface ArchiveTabsController : UITabBarController

@property (nonatomic, weak)     SensorDevice *              sensor;

@end
