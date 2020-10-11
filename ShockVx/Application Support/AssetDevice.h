//
//  project: Shock Vx
//     file: AssetDevice.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

// Expected primary UUID for a generic Systemshock device

#define kLoaderControlServiceUUID                   @"00004655-0000-1000-8000-00805F9B34FB"

// Expected primary and control UUIDs for a Stickershock device

#define kDeviceAccessServiceUUID                    @"00004143-5657-5353-2020-56454C564554"
#define kUpdateControlServiceUUID                   @"00004655-5657-5353-2020-56454C564554"


// Expected UUIDs for sensor and tracker primary services

#define kSensorControlServiceUUID                   @"56780000-5657-5353-2020-56454C564554"
#define kTrackerControlServiceUUID                  @"54780000-5657-5353-2020-56454C564554"

// Bluetooth peripheral connection, drop and name change notices

#define kDeviceNotificationConnect                  @"deviceConnect"
#define kDeviceNotificationFailure                  @"deviceFailure"
#define kDeviceNotificationDropped                  @"deviceDropped"
#define kDeviceNotificationRenamed                  @"deviceRenamed"
#define kDeviceNotificationSignal                   @"deviceSignal"

// Device information service

#import "DeviceInformation.h"

#define kDeviceNotificationInformation              @"deviceInformation"

// Battery level service

#import "DeviceBattery.h"

#define kDeviceNotificationBattery                  @"deviceBattery"

// Access control service

#import "DeviceAccess.h"

#define kDeviceNotificationAccessRestricted         @"deviceAccessRestricted"
#define kDeviceNotificationAccessUnlocked           @"deviceAccessUnlocked"
#define kDeviceNotificationAccessResponse           @"deviceAccessResponse"

// Asset identification

#import "AssetIdentifier.h"
#import "AssetTag.h"

//
// Asset device reference object
@interface AssetDevice : NSObject <CBPeripheralDelegate, DeviceAccessDelegate, DeviceBatteryDelegate, DeviceInformationDelegate>

+ (instancetype) deviceWithUnit:(AssetIdentifier *)unit node:(AssetIdentifier *)node controlService:(NSUUID *)control primaryService:(NSUUID *)primary;
- (instancetype) initWithUnit:(AssetIdentifier *)unit node:(AssetIdentifier *)node controlService:(NSUUID *)control primaryService:(NSUUID *)primary;

// Identifying information (unit identifier and optional node identifier)

@property (nonatomic, strong)   AssetIdentifier *   unitIdentifier;
@property (nonatomic, strong)   AssetIdentifier *   nodeIdentifier;

// Service access and security

@property (nonatomic, readonly) NSUUID *            controlService;
@property (nonatomic, readonly) NSUUID *            primaryService;
@property (nonatomic, readonly) NSUUID *            accessKey;

// Bluetooth peripheral connection and signal

- (void) assignPeripheral:peripheral;

- (bool) attachWithManager:(CBCentralManager *)manager usingKey:(NSUUID *)key;
- (void) detachFromManager;

@property (nonatomic, readonly) NSNumber *          signal;

// Services and characteristics

- (void) peripheral:(CBPeripheral *)peripheral service:(CBService *)service;
- (void) peripheral:(CBPeripheral *)peripheral service:(CBService *)service characteristic:(CBCharacteristic *)characteristic;
- (void) peripheral:(CBPeripheral *)peripheral retrievedCharacteristic:(CBCharacteristic *)characteristic;
- (void) peripheral:(CBPeripheral *)peripheral confirmedCharacteristic:(CBCharacteristic *)characteristic;

@property (nonatomic, strong)   DeviceInformation * information;
@property (nonatomic, strong)   DeviceBattery *     battery;
@property (nonatomic, strong)   DeviceAccess *      access;

@end

