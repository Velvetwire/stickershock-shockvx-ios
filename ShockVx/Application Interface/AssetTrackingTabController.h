//
//  project: ShockVx
//     file: AssetTrackingTabController.h
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetSensor.h"

@interface AssetTrackingTabController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak)     AssetSensor *       sensor;

@property (nonatomic, strong)   NSNumber *          signal;
@property (nonatomic, strong)   NSNumber *          battery;

@property (nonatomic, strong)   NSString *          assetDescription;
@property (nonatomic, strong)   NSString *          assetLocale;
@property (nonatomic, strong)   NSString *          assetNumber;

@property (nonatomic, strong)   NSDate *            dateOpened;
@property (nonatomic, strong)   NSDate *            dateClosed;

@end
