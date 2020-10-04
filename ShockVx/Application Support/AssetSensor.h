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

#import "SensorTelemetry.h"
#import "SensorHandling.h"
#import "SensorRecords.h"

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
#define kSensorNotificationTelemetryValues          @"sensorTelemetryValues"
#define kSensorNotificationTelemetryLimits          @"sensorTelemetryLimits"

#define kSensorNotificationHandlingValues           @"sensorHandlingValues"
#define kSensorNotificationHandlingLimits           @"sensorHandlingLimits"

#define kSensorNotificationTelemetryRecord          @"sensorTelemetryRecord"
#define kSensorNotificationRecordsInterval          @"sensorRecordsInterval"

@interface AssetSensor : NSObject

<CBPeripheralDelegate, SensorAccessDelegate, SensorControlDelegate,
 SensorBatteryDelegate, SensorInformationDelegate, SensorRecordsDelegate,
 SensorTelemetryDelegate, SensorHandlingDelegate >

+ (instancetype) sensorForPeripheral:(CBPeripheral *)peripheral withIdentifier:(AssetIdentifier *)identifier accessKey:(NSUUID *)key;

@property (nonatomic, strong)   SensorAccess *      access;
@property (nonatomic, strong)   SensorControl *     control;
@property (nonatomic, strong)   SensorBattery *     battery;
@property (nonatomic, strong)   SensorInformation * information;

@property (nonatomic, readonly) AssetIdentifier *   identifier;

@property (nonatomic, strong)   SensorTelemetry *   telemetry;
@property (nonatomic, strong)   SensorHandling *    handling;
@property (nonatomic, strong)   SensorRecords *     records;

- (bool) attachPeripheral:(CBPeripheral *)perihpheral toManager:(CBCentralManager *)manager;
- (void) detachFromManager;

@property (nonatomic, readonly) NSNumber *          signal;

@end
