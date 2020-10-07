//
//  project: Shock Vx
//     file: SensorSurface.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol SensorSurfaceDelegate;

// Surface temperature data service

#define kSensorSurfaceServiceUUID       @"53740000-5657-5353-2020-56454C564554"

// Surface temperature values and limits characteristics

#define kSensorSurfaceValueUUID         @"53744D76-5657-5353-2020-56454C564554"
#define kSensorSurfaceLowerUUID         @"53744C6C-5657-5353-2020-56454C564554"
#define kSensorSurfaceUpperUUID         @"5374556C-5657-5353-2020-56454C564554"

//
// Sensor surface temperature service
@interface SensorSurface : NSObject

+ (CBUUID *) serviceIdentifier;
+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate;

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic;
- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic;

@property (readonly, strong)    NSNumber *      temperature;
@property (nonatomic, strong)   NSNumber *      temperatureMinimum;
@property (nonatomic, strong)   NSNumber *      temperatureMaximum;

@end

//
// Sensor surface temperature delegate
@protocol SensorSurfaceDelegate <NSObject>

- (void) sensorSurface:(SensorSurface *)surface;
- (void) sensorMinimumSurface:(SensorSurface *)surface;
- (void) sensorMaximumSurface:(SensorSurface *)surface;

@end
