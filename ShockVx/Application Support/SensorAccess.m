//
//  project: Shock Vx
//     file: SensorAccess.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "SensorAccess.h"

@interface SensorAccess ( )

@property (nonatomic, weak)     CBPeripheral *                  peripheral;
@property (nonatomic, weak)     id <SensorAccessDelegate>       delegate;

@property (nonatomic, strong)   CBCharacteristic *              timeCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              controlCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              passkeyCharacteristic;

@end

@implementation SensorAccess

+ (CBUUID *) serviceIdentifier { return [CBUUID UUIDWithString:kSensorAccessServiceUUID]; }

+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate { return [[SensorAccess alloc] initWithPeripheral:peripheral delegate:delegate]; }

- (instancetype) initWithPeripheral:(CBPeripheral *)peripheral  delegate:(id)delegate {

    if ( (self = [super init]) ) { _peripheral = peripheral; _delegate = delegate; }

    return ( self );

}

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorAccessTimeUUID]] ) {
        
        [self setTimeCharacteristic:characteristic];
        [self setTime:[NSDate date]];
        
    }
    
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorAccessControlUUID]] ) { [self setControlCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorAccessPasskeyUUID]] ) { [self setPasskeyCharacteristic:characteristic]; }

}

- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorAccessControlUUID]] ) {
        
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

- (void) useAccessKey:(NSData *)key {

    [self.peripheral writeValue:[NSData dataWithData:key]
              forCharacteristic:self.passkeyCharacteristic
                           type:CBCharacteristicWriteWithResponse];

}

- (void) setTime:(NSDate *)time {
    
    unsigned    seconds     = (unsigned) floor ( [time timeIntervalSince1970] );
    
    [self.peripheral writeValue:[NSData dataWithBytes:&(seconds) length:sizeof(unsigned)]
              forCharacteristic:self.timeCharacteristic
                           type:CBCharacteristicWriteWithResponse];

}

- (void) accessRequest:(unsigned)request {

    [self.peripheral writeValue:[NSData dataWithBytes:&(request) length:sizeof(unsigned)]
              forCharacteristic:self.controlCharacteristic
                           type:CBCharacteristicWriteWithResponse];

}

- (void) requestLoader { [self accessRequest:kAccessRequestLoader]; }
- (void) requestReboot { [self accessRequest:kAccessRequestReboot]; }
- (void) requestErase { [self accessRequest:kAccessRequestErase]; }

@end
