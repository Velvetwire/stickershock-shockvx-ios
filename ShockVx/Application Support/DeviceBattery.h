//
//  project: Shock Vx
//     file: DeviceBattery.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

// Device battery status service (SiG defined)

#define kDeviceBatteryServiceUUID       @"180F"

// Battery state and charge level characteristics (SiG defined)

#define kDeviceBatteryStateUUID         @"2A1A"
#define kDeviceBatteryLevelUUID         @"2A19"

//
// Device battery status service
@interface DeviceBattery : NSObject

+ (CBUUID *) serviceIdentifier;
+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate;

// Service characteristics

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic;
- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic;

@property (nonatomic, readonly)     bool            batteryCharging;
@property (nonatomic, readonly)     NSNumber *      batteryLevel;

@end

//
// Device battery status delegate
@protocol DeviceBatteryDelegate <NSObject>

- (void) deviceBattery:(DeviceBattery *)battery charging:(bool)charging;
- (void) deviceBattery:(DeviceBattery *)battery level:(NSNumber *)level;

@end
