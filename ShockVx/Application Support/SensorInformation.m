//
//  project: Shock Vx
//     file: SensorInformation.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "SensorInformation.h"

@interface SensorInformation ( )

@property (nonatomic, weak)     CBPeripheral *                  peripheral;
@property (nonatomic, weak)     id <SensorInformationDelegate>  delegate;
@property (nonatomic)           bool                            updates;

@end

@implementation SensorInformation

+ (CBUUID *) serviceIdentifier { return [CBUUID UUIDWithString:kSensorInformationServiceUUID]; }

+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate { return [[SensorInformation alloc] initWithPeripheral:peripheral delegate:delegate]; }

- (instancetype) initWithPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate {

    if ( (self = [super init]) ) { _peripheral = peripheral; _delegate = delegate; }

    return ( self );

}

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic {
    
}

- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorInformationMakeUUID]] ) { _make = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]; [self updatedCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorInformationModelUUID]] ) { _model = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]; [self updatedCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorInformationNumberUUID]] ) { _number = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]; [self updatedCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorInformationVersionUUID]] ) { _version = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]; [self updatedCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorInformationFirmwareUUID]] ) { _firmware = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]; [self updatedCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorInformationSoftwareUUID]] ) { _software = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]; [self updatedCharacteristic:characteristic]; }

}

//
// An information characteristic has been changed.
- (void) updatedCharacteristic:(CBCharacteristic *)characteristic {

    // If the information has changed, trigger a delayed dispatch to the
    // delegate, informing it of the changes.
    
    if ( ! self.updates ) dispatch_after( dispatch_time( DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC ), dispatch_get_main_queue( ), ^{ [self setUpdates:false]; [self.delegate sensorInformation:self]; });
    if ( ! self.updates ) [self setUpdates:true];

}

@end
