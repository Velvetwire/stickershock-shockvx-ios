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

// Telemetry values and limits characteristics

#define kSensorTelemetryValueUUID       @"54654D76-5657-5353-2020-56454C564554"
#define kSensorTelemetryLowerUUID       @"54654C6C-5657-5353-2020-56454C564554"
#define kSensorTelemetryUpperUUID       @"5465556C-5657-5353-2020-56454C564554"

typedef struct __attribute__ (( packed )) {

    float       surface;                // Surface temperature (deg C)
    float       ambient;                // Ambient temperature (deg C)
    float       humidity;               // Humidity (saturation)
    float       pressure;               // Air pressure (bars)

} telemetry_values_t;

// Telemetry interval setting

#define kSensorTelemetryIntervalUUID    @"54654D69-5657-5353-2020-56454C564554"

//
// Sensor telemetry service
@interface SensorTelemetry : NSObject

+ (CBUUID *) serviceIdentifier;
+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate;

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic;
- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic;

@property (nonatomic, strong)   NSNumber *      interval;

@property (readonly, strong)    NSNumber *      pressure;
@property (nonatomic, strong)   NSNumber *      pressureMinimum;
@property (nonatomic, strong)   NSNumber *      pressureMaximum;

@property (readonly, strong)    NSNumber *      humidity;
@property (nonatomic, strong)   NSNumber *      humidityMinimum;
@property (nonatomic, strong)   NSNumber *      humidityMaximum;

@property (readonly, strong)    NSNumber *      ambient;
@property (nonatomic, strong)   NSNumber *      ambientMinimum;
@property (nonatomic, strong)   NSNumber *      ambientMaximum;

@property (readonly, strong)    NSNumber *      surface;
@property (nonatomic, strong)   NSNumber *      surfaceMinimum;
@property (nonatomic, strong)   NSNumber *      surfaceMaximum;

@end

//
// Sensor telemetry delegate
@protocol SensorTelemetryDelegate <NSObject>

- (void) sensorTelemetry:(SensorTelemetry *)telemetry;
- (void) sensorTelemetry:(SensorTelemetry *)telemetry interval:(NSNumber *)interval;

- (void) sensorMinimumTelemetry:(SensorTelemetry *)telemetry;
- (void) sensorMaximumTelemetry:(SensorTelemetry *)telemetry;

@end
