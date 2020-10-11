//
//  project: Shock Vx
//     file: DeviceInformation.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

// Device information service (SiG defined)

#define kDeviceInformationServiceUUID   @"180A"

// Device make, model and serial number (SiG defined)

#define kDeviceInformationMakeUUID      @"2A29"
#define kDeviceInformationModelUUID     @"2A24"
#define kDeviceInformationNumberUUID    @"2A25"

// Device hardware, firmware and software revisions (SiG defined)

#define kDeviceInformationVersionUUID   @"2A27"
#define kDeviceInformationFirmwareUUID  @"2A26"
#define kDeviceInformationSoftwareUUID  @"2A28"

//
// Device information service
@interface DeviceInformation : NSObject

+ (CBUUID *) serviceIdentifier;
+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate;

// Service characteristics

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic;
- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic;

@property (nonatomic, readonly)     NSString *  make;
@property (nonatomic, readonly)     NSString *  model;
@property (nonatomic, readonly)     NSString *  number;

@property (nonatomic, readonly)     NSString *  version;
@property (nonatomic, readonly)     NSString *  firmware;
@property (nonatomic, readonly)     NSString *  software;

@end

//
// Device information delegate
@protocol DeviceInformationDelegate <NSObject>

- (void) deviceInformation:(DeviceInformation *)information;

@end
