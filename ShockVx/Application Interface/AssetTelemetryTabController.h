//
//  project: ShockVx
//     file: AssetTelemetryTabController.h
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetSensor.h"

typedef NS_ENUM( NSUInteger, TelemetryGroup ) {

    kTelemetryGroupEnvironment,
    kTelemetryGroupHandling,
    nTelemetryGroups
    
};

typedef NS_ENUM( NSUInteger, EnvironmentItem ) {

    kEnvironmentItemSurface,
    kEnvironmentItemAmbient,
    kEnvironmentItemHumidity,
    kEnvironmentItemPressure,
    nEnvrionmentItems

};

typedef NS_ENUM( NSUInteger, HandlingItem ) {

    kHandlingItemAngle,
    kHandlingItemForce,
    nHandlingItems

};

@interface AssetTelemetryTabController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak)     AssetSensor *       sensor;

// Pressure values
@property (nonatomic, strong)   NSNumber *          pressure;
@property (nonatomic, strong)   NSNumber *          pressureMinimum;
@property (nonatomic, strong)   NSNumber *          pressureMaximum;

// Humidity values
@property (nonatomic, strong)   NSNumber *          humidity;
@property (nonatomic, strong)   NSNumber *          humidityMinimum;
@property (nonatomic, strong)   NSNumber *          humidityMaximum;

// Ambient temperature values
@property (nonatomic, strong)   NSNumber *          ambient;
@property (nonatomic, strong)   NSNumber *          ambientMinimum;
@property (nonatomic, strong)   NSNumber *          ambientMaximum;

// Surface temperature values
@property (nonatomic, strong)   NSNumber *          surface;
@property (nonatomic, strong)   NSNumber *          surfaceMinimum;
@property (nonatomic, strong)   NSNumber *          surfaceMaximum;

// Tilt angle and orientation values
@property (nonatomic, strong)   NSNumber *          orientation;
@property (nonatomic, strong)   NSNumber *          angle;
@property (nonatomic, strong)   NSNumber *          angleMaximum;

// Forces
@property (nonatomic, strong)   NSNumber *          force;
@property (nonatomic, strong)   NSNumber *          forceMaximum;

@end
