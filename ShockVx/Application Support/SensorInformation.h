//
//  project: Shock Vx
//     file: SensorInformation.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define kSensorInformationServiceUUID   @"180A"

#define kSensorInformationMakeUUID      @"2A29"
#define kSensorInformationModelUUID     @"2A24"
#define kSensorInformationNumberUUID    @"2A25"
#define kSensorInformationVersionUUID   @"2A27"
#define kSensorInformationFirmwareUUID  @"2A26"
#define kSensorInformationSoftwareUUID  @"2A28"

@protocol SensorInformationDelegate;
@interface SensorInformation : NSObject

+ (CBUUID *) serviceIdentifier;
+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate;

@property (nonatomic, readonly)     NSString *  make;
@property (nonatomic, readonly)     NSString *  model;
@property (nonatomic, readonly)     NSString *  number;
@property (nonatomic, readonly)     NSString *  version;
@property (nonatomic, readonly)     NSString *  firmware;
@property (nonatomic, readonly)     NSString *  software;

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic;
- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic;

@end

@protocol SensorInformationDelegate <NSObject>

- (void) sensorInformation:(SensorInformation *)information;

@end
