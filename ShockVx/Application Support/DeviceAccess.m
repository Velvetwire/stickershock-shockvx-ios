//
//  project: Shock Vx
//     file: DeviceAccess.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "DeviceAccess.h"

//
// Service interface
@interface DeviceAccess ( )

@property (nonatomic, weak)     CBPeripheral *                  peripheral;
@property (nonatomic, weak)     id <DeviceAccessDelegate>       delegate;
@property (nonatomic, strong)   NSUUID *                        service;

@property (nonatomic, strong)   CBCharacteristic *              timeCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              controlCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              passkeyCharacteristic;

@end

//
// Service implementation
@implementation DeviceAccess

#pragma mark - Service instantiation

+ (instancetype) accessService:(NSUUID *)service forPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate { return [[DeviceAccess alloc] initService:service forPeripheral:peripheral delegate:delegate]; }

- (instancetype) initService:(NSUUID *)service forPeripheral:(CBPeripheral *)peripheral  delegate:(id)delegate {

    if ( (self = [super init]) ) { _service = service; _peripheral = peripheral; _delegate = delegate; }
    
    return ( self );

}

#pragma mark - Service identifier

//
// Construct a 128-bit Bluetooth UUID from the prefix and the service UUID suffix
- (CBUUID *) identifierWithPrefix:(NSString *)prefix {

    NSString *  suffix      = [[self.service UUIDString] substringFromIndex:8];
    
    return [CBUUID UUIDWithString:[prefix stringByAppendingString:suffix]];
    
}

#pragma mark - Service characteristics

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic {

    // If the UTC time characteristic has been discovered, write the current UTC
    // time to the value in order to synchronize the device with the mobile.
    
    if ( [characteristic.UUID isEqual:[self identifierWithPrefix:kDeviceAccessTimePrefix]] ) {
        
        [self setTimeCharacteristic:characteristic];
        [self setTime:[NSDate date]];
        
    }
    
    // Discovered the access control and security key characteristics.
    
    if ( [characteristic.UUID isEqual:[self identifierWithPrefix:kDeviceAccessControlPrefix]] ) { [self setControlCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[self identifierWithPrefix:kDeviceAccessPasskeyPrefix]] ) { [self setPasskeyCharacteristic:characteristic]; }

}

- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:self.controlCharacteristic.UUID] ) {
        
        unsigned *      value   = (unsigned *)[characteristic.value bytes];

        if ( value ) switch ( *(value) ) {
        
            case kAccessResponseAccepted:   [self.delegate accessReponse:kAccessResponseSuccess]; break;
            case kAccessResponseRejected:   [self.delegate accessReponse:kAccessResponseFailure]; break;
                
            case kAccessResponseOpened:     [self.delegate accessStatus:kAccessStatusOpened]; break;
            case kAccessResponseLocked:     [self.delegate accessStatus:kAccessStatusLocked]; break;
        
        }
        
    }

}

- (void) confirmedCharacteristic:(CBCharacteristic *)characteristic {

}

#pragma mark - Time synchronization

- (void) setTime:(NSDate *)time {
    
    unsigned    seconds     = (unsigned) floor ( [time timeIntervalSince1970] );
    
    [self.peripheral writeValue:[NSData dataWithBytes:&(seconds) length:sizeof(unsigned)]
              forCharacteristic:self.timeCharacteristic
                           type:CBCharacteristicWriteWithResponse];

}

#pragma mark - Access security

- (void) useAccessKey:(NSData *)key {

    [self.peripheral writeValue:[NSData dataWithData:key]
              forCharacteristic:self.passkeyCharacteristic
                           type:CBCharacteristicWriteWithResponse];

}

#pragma mark - Access control requests

- (void) requestLoader { [self accessRequest:kAccessRequestLoader]; }
- (void) requestReboot { [self accessRequest:kAccessRequestReboot]; }
- (void) requestErase { [self accessRequest:kAccessRequestErase]; }

- (void) accessRequest:(unsigned)request {

    [self.peripheral writeValue:[NSData dataWithBytes:&(request) length:sizeof(unsigned)]
              forCharacteristic:self.controlCharacteristic
                           type:CBCharacteristicWriteWithResponse];

}

@end
