//
//  project: ShockVx
//     file: AssetTrackingTabController.h
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "SensorDevice.h"

@protocol AssetTrackingDelegate;

@interface AssetTrackingTabController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak)     SensorDevice *              sensor;
@property (nonatomic, weak)     id <AssetTrackingDelegate>  delegate;

@property (nonatomic, strong)   CLLocation *                location;
@property (nonatomic, strong)   CLPlacemark *               placemark;

@property (nonatomic, strong)   NSNumber *                  signal;
@property (nonatomic, strong)   NSNumber *                  battery;

@property (nonatomic, strong)   NSString *                  assetDescription;
@property (nonatomic, strong)   NSString *                  assetLocale;
@property (nonatomic, strong)   NSString *                  assetNumber;

@property (nonatomic, strong)   NSDate *                    dateOpened;
@property (nonatomic, strong)   NSDate *                    dateClosed;

@end

@protocol AssetTrackingDelegate <NSObject>

- (void) assetTrackingOpened;
- (void) assetTrackingClosed;

@end
