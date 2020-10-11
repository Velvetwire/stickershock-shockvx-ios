//
//  project: Shock Vx
//     file: AssetDevice.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//
#import "AssetDevice.h"

//
// Device interface
@interface AssetDevice ( )

// Bluetooth peripheral and central association

@property (nonatomic, strong)   CBPeripheral *      peripheral;
@property (nonatomic, weak)     CBCentralManager *  manager;

@end

//
// Device implementation
@implementation AssetDevice

#pragma mark - Device instantiation

//
// Instantiate a new device.
+ (instancetype) deviceWithUnit:(AssetIdentifier *)unit node:(AssetIdentifier *)node controlService:(NSUUID *)control primaryService:(NSUUID *)primary {

    return [[AssetDevice alloc] initWithUnit:unit node:node controlService:control primaryService:primary];
    
}

//
// Initialize the instance.
- (instancetype) initWithUnit:(AssetIdentifier *)unit node:(AssetIdentifier *)node controlService:(NSUUID *)control primaryService:(NSUUID *)primary {

    // Instantiate the device.
    
    if ( (self = [super init]) ) {
        
        // Set the identifying information.
        
        _unitIdentifier = unit;
        _nodeIdentifier = node;
        
        // Set the published service information.
        
        _controlService = control;
        _primaryService = primary;
        
    }
    
    // Return with the instance.
    
    return ( self );
    
}

#pragma mark - Peripheral connection and disconnection

//
// Assign the peripheral to the device.
- (void) assignPeripheral:peripheral {
    
    if ( (_peripheral = peripheral) ) [peripheral setDelegate:self];

}

//
// Attach the device to an instance of a central manager.
- (bool) attachWithManager:(CBCentralManager *)manager usingKey:(NSUUID *)key {

    if ( (_manager = manager) ) { _accessKey = key; }
    else return ( false );
    
    [self.peripheral discoverServices:nil];
    [self.peripheral readRSSI];
    
    return ( true );
    
}

//
// Detach the device from its central manager.
- (void) detachFromManager {

    if ( self.peripheral.state == CBPeripheralStateConnected ) [self.manager cancelPeripheralConnection:self.peripheral];
    
}

#pragma mark - Peripheral delegate

//
// Service discovery has completed.
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {

    if ( ! error ) for ( CBService * service in peripheral.services ) {

        // Instantiate the service.
        
        [self peripheral:peripheral service:service];
        
        // Discover the characteristics for the service.
        
        [peripheral discoverCharacteristics:nil forService:service];
    
    }
    
}

//
// Service characteristics have been discovered.
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {

    if ( ! error ) for ( CBCharacteristic * characteristic in service.characteristics ) {

        // Register the characteristic with the service.
        
        [self peripheral:peripheral service:service characteristic:characteristic];

        // If the characteristic is notifying, enable notification. If the characteristic
        // can be read, read the characteristic.
        
        if ( characteristic.properties & CBCharacteristicPropertyNotify ) { [peripheral setNotifyValue:YES forCharacteristic:characteristic]; }
        if ( characteristic.properties & CBCharacteristicPropertyRead ) { [peripheral readValueForCharacteristic:characteristic]; }

    }
    
}

//
// A characteristic value has been recevied from the peripheral.
- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {

    // Let the services know that a characteristic has been received.
    
    if ( ! error ) [self peripheral:peripheral retrievedCharacteristic:characteristic];

}

//
// A characteristic value written to the peripheral has been confirmed.
- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {

    // Let the services know that a characteristic has been written.
    
    if ( ! error ) [self peripheral:peripheral confirmedCharacteristic:characteristic];
    
}

//
// The relative signal strength has been received from the peripheral.
- (void) peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {

    // If a valid signal was received, dispatch a notice with the signal level.
    
    if ( ! error && (_signal = RSSI) ) dispatch_async( dispatch_get_main_queue( ), ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNotificationSignal
                                                            object:self
                                                          userInfo:@{@"signal":self.signal}];
        
    });

    // Request a subsequent read of the signal after 5 seconds.
    
    dispatch_after( dispatch_time( DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC ), dispatch_get_main_queue( ), ^{
        
        if ( self.peripheral.state == CBPeripheralStateConnected ) [self.peripheral readRSSI];
        
    });

}

//
// The peripheral name has been updated.
- (void) peripheralDidUpdateName:(CBPeripheral *)peripheral {

}

#pragma mark - Service characteristics

//
// Services have been discovered.
- (void) peripheral:(CBPeripheral *)peripheral service:(CBService *)service {

    // The declared control service for the device is the access service.
    
    if ( [service.UUID isEqual:[CBUUID UUIDWithNSUUID:self.controlService]] && self.access == nil ) [self setAccess:[DeviceAccess accessService:self.controlService forPeripheral:peripheral delegate:self]];

    // Standard services include device and battery information.
    
    if ( [service.UUID isEqual:[DeviceInformation serviceIdentifier]] && self.information == nil ) [self setInformation:[DeviceInformation serviceForPeripheral:peripheral delegate:self]];
    if ( [service.UUID isEqual:[DeviceBattery serviceIdentifier]] && self.battery == nil ) [self setBattery:[DeviceBattery serviceForPeripheral:peripheral delegate:self]];
    
}

//
// Service characteristics have been discovered.
- (void) peripheral:(CBPeripheral *)peripheral service:(CBService *)service characteristic:(CBCharacteristic *)characteristic {

    // If this is a declared control characteristic, forward it to the device access service.
    
    if ( [service.UUID isEqual:[CBUUID UUIDWithNSUUID:self.controlService]] ) [self.access discoveredCharacteristic:characteristic];

    // Check if this is a device information or battery information characteristic.
    
    if ( [service.UUID isEqual:[DeviceInformation serviceIdentifier]] ) [self.information discoveredCharacteristic:characteristic];
    if ( [service.UUID isEqual:[DeviceBattery serviceIdentifier]] ) [self.battery discoveredCharacteristic:characteristic];
    
}

//
// Charactistic value retrieved.
- (void) peripheral:(CBPeripheral *)peripheral retrievedCharacteristic:(CBCharacteristic *)characteristic {

    [self.information retrievedCharacteristic:characteristic];
    [self.battery retrievedCharacteristic:characteristic];
    [self.access retrievedCharacteristic:characteristic];

}

//
// Characteristic write confirmed.
- (void) peripheral:(CBPeripheral *)peripheral confirmedCharacteristic:(CBCharacteristic *)characteristic {

    [self.access confirmedCharacteristic:characteristic];

}

#pragma mark - Device information delegate

//
// Received an update from the device information service.
- (void) deviceInformation:(DeviceInformation *)information {

    // Send a notice that the information has changed.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNotificationInformation
                                                        object:self
                                                      userInfo:@{@"information":self.information}];
    
}

#pragma mark - Device battery information delegate

//
// The battery charge status has changed.
- (void) deviceBattery:battery charging:(bool)charging {

    // Send a notice that the battery charging status has changed.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNotificationBattery
                                                        object:self
                                                      userInfo:nil];

}

//
// The battery charge level has changed.
- (void) deviceBattery:battery level:(NSNumber *)level {

    // Send a notice that the battery charge level has changed.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNotificationBattery
                                                        object:self
                                                      userInfo:@{@"level":level}];

}

#pragma mark - Device access delegate

//
// Received access status from the access service.
- (void) accessStatus:(AccessStatus)status {

    // If access is locked, attept to unlock with the pass key. If there
    // is no key, send a restricted access notice.
    
    if ( status == kAccessStatusLocked ) {
            
        if ( self.accessKey ) {
            
            unsigned char   passkey [ 16 ];
            
            [self.accessKey getUUIDBytes:passkey];
            [self.access useAccessKey:[NSData dataWithBytes:passkey length:sizeof(passkey)]];
        
        } else {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNotificationAccessRestricted
                                                                object:nil];
            
        }
        
    }
    
    // If access is open send an open access notice.
    
    if ( status == kAccessStatusOpened ) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNotificationAccessUnlocked
                                                            object:nil];
        
    }
    
}

//
// Received a response from the access service.
- (void) accessReponse:(AccessResponse)response {

    // Send a notice that the sensor unit information has changed.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceNotificationAccessResponse
                                                        object:self
                                                      userInfo:@{@"response":[NSNumber numberWithUnsignedInteger:response]}];

}

@end
