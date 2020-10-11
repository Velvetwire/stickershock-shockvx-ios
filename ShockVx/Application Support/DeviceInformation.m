//
//  project: Shock Vx
//     file: DeviceInformation.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "DeviceInformation.h"

//
// Service interface
@interface DeviceInformation ( )

@property (nonatomic, weak)     CBPeripheral *                  peripheral;
@property (nonatomic, weak)     id <DeviceInformationDelegate>  delegate;

@property (nonatomic)           bool                            updates;

@end

//
// Service implementation
@implementation DeviceInformation

#pragma mark - Service instantiation

+ (CBUUID *) serviceIdentifier { return [CBUUID UUIDWithString:kDeviceInformationServiceUUID]; }

+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate { return [[DeviceInformation alloc] initWithPeripheral:peripheral delegate:delegate]; }

- (instancetype) initWithPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate {

    if ( (self = [super init]) ) { _peripheral = peripheral; _delegate = delegate; }
    
    return ( self );

}

#pragma mark - Service characteristics

//
// Discovered a reference to a service characteristic.
- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic {
    
    // No need to keep references to characteristics.
    
}

//
// Retreived the value for a characteristic.
- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic {

    // Retreived make, model and serial number information.
    
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kDeviceInformationMakeUUID]] ) { _make = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]; [self updatedCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kDeviceInformationModelUUID]] ) { _model = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]; [self updatedCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kDeviceInformationNumberUUID]] ) { _number = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]; [self updatedCharacteristic:characteristic]; }

    // Retrieved hardware, firmware and software revision information.
    
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kDeviceInformationVersionUUID]] ) { _version = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]; [self updatedCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kDeviceInformationFirmwareUUID]] ) { _firmware = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]; [self updatedCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kDeviceInformationSoftwareUUID]] ) { _software = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]; [self updatedCharacteristic:characteristic]; }

}

//
// An information characteristic has been received.
- (void) updatedCharacteristic:(CBCharacteristic *)characteristic {

    // If the information has been receieved, trigger a delayed dispatch
    // to the delegate, indicating and information update.
    
    if ( ! self.updates ) dispatch_after( dispatch_time( DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC ), dispatch_get_main_queue( ), ^{ [self setUpdates:false]; [self.delegate deviceInformation:self]; });
    if ( ! self.updates ) [self setUpdates:true];

}

@end
