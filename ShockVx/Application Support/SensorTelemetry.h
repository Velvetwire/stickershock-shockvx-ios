//
//  project: Shock Vx
//     file: SensorTelemetry.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol SensorTelemetryDelegate;

// Telemetry data service

#define kSensorTelemetryServiceUUID     @"54650000-5657-5353-2020-56454C564554"

// Telemetry interval settings

#define kSensorTelemetryIntervalUUID    @"54654D69-5657-5353-2020-56454C564554"
#define kSensorTelemetryArchivalUUID    @"54654169-5657-5353-2020-56454C564554"

//
// Sensor telemetry service
@interface SensorTelemetry : NSObject

+ (CBUUID *) serviceIdentifier;
+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate;

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic;
- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic;

@property (nonatomic, strong)   NSNumber *      interval;
@property (nonatomic, strong)   NSNumber *      archival;

@end

//
// Sensor telemetry delegate
@protocol SensorTelemetryDelegate <NSObject>

- (void) sensorTelemetry:(SensorTelemetry *)telemetry interval:(NSNumber *)interval;
- (void) sensorTelemetry:(SensorTelemetry *)telemetry archival:(NSNumber *)archival;

@end
