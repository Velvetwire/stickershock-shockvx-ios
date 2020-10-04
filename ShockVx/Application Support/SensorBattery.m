//
//  project: Shock Vx
//     file: SensorBattery.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "SensorBattery.h"

@interface SensorBattery ( )

@property (nonatomic, weak)     CBPeripheral *              peripheral;
@property (nonatomic, weak)     id <SensorBatteryDelegate>  delegate;

@property (nonatomic, strong)   CBCharacteristic *          stateCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *          levelCharacteristic;

@end

@implementation SensorBattery

+ (CBUUID *) serviceIdentifier { return [CBUUID UUIDWithString:kSensorBatteryServiceUUID]; }

+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate { return [[SensorBattery alloc] initWithPeripheral:peripheral delegate:delegate]; }

- (instancetype) initWithPeripheral:(CBPeripheral *)peripheral  delegate:(id)delegate {

    if ( (self = [super init]) ) { _peripheral = peripheral; _delegate = delegate; }

    return ( self );

}

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorBatteryStateUUID]] ) { [self setStateCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorBatteryLevelUUID]] ) { [self setLevelCharacteristic:characteristic]; }

}

- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorBatteryLevelUUID]] ) {
        
        const signed char *     value   = (const signed char *) [characteristic value].bytes;
        _batteryLevel                   = [NSNumber numberWithChar:*(value)];
        
        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorBattery:self level:self.batteryLevel]; });
        
    }

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorBatteryStateUUID]] ) {
        
        const unsigned char *   value   = (const unsigned char *) [characteristic value].bytes;
        bool                    state   = ((*(value) & (3 << 4)) == 3) ? true : false;
        
        if ( _batteryCharging != state ) { _batteryCharging = state; }
        else return;
        
        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorBattery:self charging:self.batteryCharging]; });
        
    }

}

@end
