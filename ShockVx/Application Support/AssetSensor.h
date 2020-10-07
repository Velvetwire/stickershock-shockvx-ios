//
//  project: Shock Vx
//     file: AssetSensor.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "SensorAccess.h"
#import "SensorControl.h"
#import "SensorBattery.h"
#import "SensorInformation.h"

#import "AssetIdentifier.h"

#import "SensorAtmosphere.h"
#import "SensorTelemetry.h"
#import "SensorHandling.h"
#import "SensorSurface.h"

#define kSensorNotificationConnect                  @"sensorConnect"
#define kSensorNotificationDropped                  @"sensorDropped"
#define kSensorNotificationRenamed                  @"sensorRenamed"

#define kSensorNotificationInformationUpdate        @"sensorInformationUpdate"
#define kSensorNotificationAccessRestricted         @"sensorAccessRestricted"
#define kSensorNotificationAccessUnlocked           @"sensorAccessUnlocked"
#define kSensorNotificationAccessResponse           @"sensorAccessResponse"
#define kSensorNotificationBatteryUpdate            @"sensorBatteryUpdate"
#define kSensorNotificationSignalUpdate             @"sensorSignalUpdate"

#define kSensorNotificationControlSettings          @"sensorControlSettings"

#define kSensorNotificationTelemetryInterval        @"sensorTelemetryInterval"
#define kSensorNotificationArchiveInterval          @"sensorArchiveInterval"

#define kSensorNotificationAtmosphericValues        @"sensorAtmosphericValues"
#define kSensorNotificationAtmosphericLimits        @"sensorAtmosphericLimits"

#define kSensorNotificationHandlingValues           @"sensorHandlingValues"
#define kSensorNotificationHandlingLimits           @"sensorHandlingLimits"

#define kSensorNotificationSurfaceValues            @"sensorSurfaceValues"
#define kSensorNotificationSurfaceLimits            @"sensorSurfaceLimits"

@interface AssetSensor : NSObject

<CBPeripheralDelegate, SensorAccessDelegate, SensorControlDelegate,
 SensorBatteryDelegate, SensorInformationDelegate, SensorTelemetryDelegate,
 SensorAtmosphereDelegate, SensorHandlingDelegate, SensorSurfaceDelegate >

+ (instancetype) sensorForPeripheral:(CBPeripheral *)peripheral withIdentifier:(AssetIdentifier *)identifier accessKey:(NSUUID *)key;

@property (nonatomic, strong)   SensorAccess *      access;
@property (nonatomic, strong)   SensorControl *     control;
@property (nonatomic, strong)   SensorBattery *     battery;
@property (nonatomic, strong)   SensorInformation * information;

@property (nonatomic, readonly) AssetIdentifier *   identifier;

@property (nonatomic, strong)   SensorAtmosphere *  atmosphere;
@property (nonatomic, strong)   SensorTelemetry *   telemetry;
@property (nonatomic, strong)   SensorHandling *    handling;
@property (nonatomic, strong)   SensorSurface *     surface;

- (bool) attachPeripheral:(CBPeripheral *)peripheral toManager:(CBCentralManager *)manager;
- (void) detachFromManager;

@property (nonatomic, readonly) NSNumber *          signal;

@end
