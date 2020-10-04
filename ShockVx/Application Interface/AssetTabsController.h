//
//  project: ShockVx
//     file: AssetTabsController.h
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetSensor.h"

// The tab items in the storyboard have tag numbers set
// their index.

typedef NS_ENUM( NSUInteger, TabIndex ) {

    kTabIndexTracking,
    kTabIndexTelemetry,
    kTabIndexSettings,
    
};

//
// Tab bar controller interface
@interface AssetTabsController : UITabBarController

@property (nonatomic, strong)   AssetSensor *       sensor;

@property (nonatomic)           NSString *          assetDescription;
@property (nonatomic)           NSString *          assetLocale;

@end
