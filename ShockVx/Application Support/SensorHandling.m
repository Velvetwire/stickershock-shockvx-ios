//
//  project: Shock Vx
//     file: SensorHandling.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "SensorHandling.h"

@interface SensorHandling ( )

@property (nonatomic, weak)     CBPeripheral *                  peripheral;
@property (nonatomic, weak)     id <SensorHandlingDelegate>     delegate;

@property (nonatomic, strong)   CBCharacteristic *              valueCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              limitCharacteristic;

@property (nonatomic)           handling_values_t               limits;

@end

@implementation SensorHandling

@synthesize limits = _limits;

+ (CBUUID *) serviceIdentifier { return [CBUUID UUIDWithString:kSensorHandlingServiceUUID]; }

+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate { return [[SensorHandling alloc] initWithPeripheral:peripheral delegate:delegate]; }

- (instancetype) initWithPeripheral:(CBPeripheral *)peripheral  delegate:(id)delegate {

    if ( (self = [super init]) ) { _peripheral = peripheral; _delegate = delegate; }

    return ( self );

}

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorHandlingValueUUID]] ) { [self setValueCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorHandlingLimitUUID]] ) { [self setLimitCharacteristic:characteristic]; }

}

- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorHandlingValueUUID]] ) {
        
        handling_values_t * value = (handling_values_t *) [characteristic.value bytes];
        
        if ( value ) {
            
            _angle          = [NSNumber numberWithFloat:value->angle];
            _force          = [NSNumber numberWithFloat:value->force];
            
            _face           = (OrientationFace) value->orientation;
            
        }

        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorHandling:self]; });

    }

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorHandlingLimitUUID]] ) {
        
        handling_values_t * value = memcpy ( &(_limits), [characteristic.value bytes], sizeof(handling_values_t) );
        
        if ( value ) {
            
            _angleLimit     = [NSNumber numberWithFloat:value->angle];
            _forceLimit     = [NSNumber numberWithFloat:value->force];
            
            _preferredFace  = (OrientationFace) value->orientation;
            
        }

        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorLimitHandling:self]; });

    }

}

- (void) setAngleLimit:(NSNumber *)limit {
    
    if ( (_angleLimit = limit) ) {

        _limits.angle       = [limit floatValue];
        NSData *    data    = [NSData dataWithBytes:&(_limits) length:sizeof(handling_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.limitCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        _limits.angle       = 0.0;
        NSData *    data    = [NSData dataWithBytes:&(_limits) length:sizeof(handling_values_t)];

        [self.peripheral writeValue:data forCharacteristic:self.limitCharacteristic type:CBCharacteristicWriteWithResponse];

    }

}

- (void) setForceLimit:(NSNumber *)limit {
    
    if ( (_forceLimit = limit) ) {

        _limits.force       = [limit floatValue];
        NSData *    data    = [NSData dataWithBytes:&(_limits) length:sizeof(handling_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.limitCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        _limits.force       = 0.0;
        NSData *    data    = [NSData dataWithBytes:&(_limits) length:sizeof(handling_values_t)];

        [self.peripheral writeValue:data forCharacteristic:self.limitCharacteristic type:CBCharacteristicWriteWithResponse];

    }

}

- (void) setPreferredFace:(OrientationFace)face {

    if ( face < kOrientationFaces ) {
    
        _limits.orientation = (unsigned char) face;
        NSData *    data    = [NSData dataWithBytes:&(_limits) length:sizeof(handling_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.limitCharacteristic type:CBCharacteristicWriteWithResponse];

    }
    
}

@end
