//
//  project: ShockVx
//     file: AssetSettingsTabController.h
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetSensor.h"

// The telemetry measurement interval can be either
// set to fast or slow.

#define kTelemetryIntervalFast  ((float) 15.0)
#define kTelemetryIntervalSlow  ((float) 60.0)

typedef NS_ENUM ( NSUInteger, MeasurementSetting ) {

    kMeasurementSettingFast,
    kMeasurementSettingSlow,
    
};

// The telemetry recording interval can be either
// set to fast or slow.

#define kRecordingIntervalFast  ((float) 900.0)
#define kRecordingIntervalSlow  ((float) 3600.0)

typedef NS_ENUM ( NSUInteger, RecordSetting ) {

    kRecordSettingFast,
    kRecordSettingSlow,
    
};

// Force limits are grouped into care settings: either
// careful or fragile.

#define kForceLimitCareful      ((float) 6.0)
#define kForceLimitFragile      ((float) 3.0)

typedef NS_ENUM ( NSUInteger, CareSetting ) {

    kCareSettingNone,
    kCareSettingCareful,
    kCareSettingFragile,
    
};

// Preferred orientation is either flat or upright.

typedef NS_ENUM ( NSUInteger, PreferredOrientation ) {

    kPreferredOrientationFlat,
    kPreferredOrientationUpright,
    
};

@interface AssetSettingsTabController : UITableViewController

@property (nonatomic, weak)     AssetSensor *       sensor;

@property (nonatomic, strong)   NSNumber *          telemetryInterval;
@property (nonatomic, strong)   NSNumber *          recordingInterval;

@property (nonatomic, strong)   NSNumber *          surfaceMinimum;
@property (nonatomic, strong)   NSNumber *          surfaceMaximum;

@property (nonatomic, strong)   NSNumber *          ambientMinimum;
@property (nonatomic, strong)   NSNumber *          ambientMaximum;

@property (nonatomic, strong)   NSNumber *          humidityMinimum;
@property (nonatomic, strong)   NSNumber *          humidityMaximum;

@property (nonatomic, strong)   NSNumber *          pressureMinimum;
@property (nonatomic, strong)   NSNumber *          pressureMaximum;

@property (nonatomic, strong)   NSNumber *          angleMaximum;
@property (nonatomic, strong)   NSNumber *          forceMaximum;

@property (nonatomic)           OrientationFace     orientation;

@end
