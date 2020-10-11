//
//  project: ShockVx
//     file: AssetTabsController.h
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SensorDevice.h"

#import "AssetSettingsTabController.h"
#import "AssetTrackingTabController.h"
#import "AssetTelemetryTabController.h"

// The tab items in the storyboard have tag numbers set
// their index.

typedef NS_ENUM( NSUInteger, TabIndex ) {

    kTabIndexTracking,
    kTabIndexTelemetry,
    kTabIndexSettings,
    
};

//
// Tab bar controller interface
@interface AssetTabsController : UITabBarController <AssetTrackingDelegate, AssetSettingsDelegate>

@property (nonatomic, strong)   SensorDevice *      sensor;

@property (nonatomic)           NSString *          assetDescription;
@property (nonatomic)           NSString *          assetLocale;

@end
