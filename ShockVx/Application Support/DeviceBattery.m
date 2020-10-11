//
//  project: Shock Vx
//     file: DeviceBattery.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "DeviceBattery.h"

//
// Service interface
@interface DeviceBattery ( )

@property (nonatomic, weak)     CBPeripheral *              peripheral;
@property (nonatomic, weak)     id <DeviceBatteryDelegate>  delegate;

@property (nonatomic, strong)   CBCharacteristic *          stateCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *          levelCharacteristic;

@end

//
// Service implementation
@implementation DeviceBattery

#pragma mark - Service instantiation

+ (CBUUID *) serviceIdentifier { return [CBUUID UUIDWithString:kDeviceBatteryServiceUUID]; }

+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate { return [[DeviceBattery alloc] initWithPeripheral:peripheral delegate:delegate]; }

- (instancetype) initWithPeripheral:(CBPeripheral *)peripheral  delegate:(id)delegate {

    if ( (self = [super init]) ) { _peripheral = peripheral; _delegate = delegate; }

    return ( self );

}

#pragma mark - Service characteristics

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kDeviceBatteryStateUUID]] ) { [self setStateCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kDeviceBatteryLevelUUID]] ) { [self setLevelCharacteristic:characteristic]; }

}

- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic {

    // Update the battery charging state from the status characteristic.
    
    if ( [characteristic.UUID isEqual:self.stateCharacteristic.UUID] ) {
        
        const unsigned char *   value   = (const unsigned char *) [characteristic value].bytes;
        bool                    state   = ((*(value) & (3 << 4)) == 3) ? true : false;
        
        if ( _batteryCharging != state ) { _batteryCharging = state; }
        else return;
        
        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate deviceBattery:self charging:self.batteryCharging]; });
        
    }

    // Update the battery charge from the level characteristic.
    
    if ( [characteristic.UUID isEqual:self.levelCharacteristic.UUID] ) {
        
        const signed char *     value   = (const signed char *) [characteristic value].bytes;
        _batteryLevel                   = [NSNumber numberWithChar:*(value)];
        
        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate deviceBattery:self level:self.batteryLevel]; });
        
    }

}

@end
