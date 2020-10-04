//
//  project: Shock Vx
//     file: SensorBattery.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define kSensorBatteryServiceUUID       @"180F"

#define kSensorBatteryStateUUID         @"2A1A"
#define kSensorBatteryLevelUUID         @"2A19"

@protocol SensorBatteryDelegate;

@interface SensorBattery : NSObject

+ (CBUUID *) serviceIdentifier;
+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate;

@property (nonatomic, readonly)     NSNumber *      batteryLevel;
@property (nonatomic, readonly)     bool            batteryCharging;

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic;
- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic;

@end

@protocol SensorBatteryDelegate <NSObject>

- (void) sensorBattery:(SensorBattery *)battery level:(NSNumber *)level;
- (void) sensorBattery:(SensorBattery *)battery charging:(bool)charging;

@end
