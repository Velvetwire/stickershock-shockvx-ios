//
//  project: Shock Vx
//     file: SensorDevice.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AssetDevice.h"
#import "AssetBroadcast.h"

// Sensor control and settings service.

#import "SensorControl.h"

#define kSensorNotificationControlSettings          @"sensorControlSettings"

// Sensor telemetry settings service.

#import "SensorTelemetry.h"

#define kSensorNotificationMeasureInterval          @"sensorMeasureInterval"
#define kSensorNotificationArchiveInterval          @"sensorArchiveInterval"

// Sensor telemetry services.

#import "SensorAtmosphere.h"
#import "SensorHandling.h"
#import "SensorSurface.h"

#define kSensorNotificationAtmosphericValues        @"sensorAtmosphericValues"
#define kSensorNotificationAtmosphericLimits        @"sensorAtmosphericLimits"

#define kSensorNotificationHandlingValues           @"sensorHandlingValues"
#define kSensorNotificationHandlingLimits           @"sensorHandlingLimits"

#define kSensorNotificationSurfaceValues            @"sensorSurfaceValues"
#define kSensorNotificationSurfaceLimits            @"sensorSurfaceLimits"

//
// Sensor device reference object
@interface SensorDevice : AssetDevice <SensorControlDelegate, SensorTelemetryDelegate, SensorAtmosphereDelegate, SensorHandlingDelegate, SensorSurfaceDelegate>

+ (instancetype) sensorWithUnit:(AssetIdentifier *)unit node:(AssetIdentifier *)node controlService:(NSUUID *)control primaryService:(NSUUID *)primary;

// Sensor control services

@property (nonatomic, strong)   SensorControl *     control;
@property (nonatomic, strong)   SensorTelemetry *   telemetry;

// Sensor telemetry services

@property (nonatomic, strong)   SensorAtmosphere *  atmosphere;
@property (nonatomic, strong)   SensorHandling *    handling;
@property (nonatomic, strong)   SensorSurface *     surface;

@end
