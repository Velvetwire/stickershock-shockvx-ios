//
//  project: Shock Vx
//     file: SensorTelemetry.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "SensorTelemetry.h"

@interface SensorTelemetry ( )

@property (nonatomic, weak)     CBPeripheral *                  peripheral;
@property (nonatomic, weak)     id <SensorTelemetryDelegate>    delegate;

@property (nonatomic, strong)   CBCharacteristic *              intervalCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              archivalCharacteristic;

@end

@implementation SensorTelemetry

+ (CBUUID *) serviceIdentifier { return [CBUUID UUIDWithString:kSensorTelemetryServiceUUID]; }

+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate { return [[SensorTelemetry alloc] initWithPeripheral:peripheral delegate:delegate]; }

- (instancetype) initWithPeripheral:(CBPeripheral *)peripheral  delegate:(id)delegate {

    if ( (self = [super init]) ) { _peripheral = peripheral; _delegate = delegate; }

    return ( self );

}

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorTelemetryIntervalUUID]] ) { [self setIntervalCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorTelemetryArchivalUUID]] ) { [self setArchivalCharacteristic:characteristic]; }

}

- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:self.intervalCharacteristic.UUID] ) {
        
        float *         interval    = (float *) [characteristic.value bytes];
        _interval                   = interval ? [NSNumber numberWithFloat:(*interval)] : nil;
        
        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorTelemetry:self interval:self.interval]; });
        
    }

    if ( [characteristic.UUID isEqual:self.archivalCharacteristic.UUID] ) {
        
        float *         archival    = (float *) [characteristic.value bytes];
        _archival                   = archival ? [NSNumber numberWithFloat:(*archival)] : nil;
        
        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorTelemetry:self archival:self.archival]; });
        
    }


}

#pragma mark - Telemetry Intervals

- (void) setInterval:(NSNumber *)interval {

    if ( (_interval = interval) ) {
        
        float       value   = [interval floatValue];
        NSData *    data    = [NSData dataWithBytes:&(value) length:sizeof(float)];
        
        [self.peripheral writeValue:data forCharacteristic:self.intervalCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        float       value   = 0.0;
        NSData *    data    = [NSData dataWithBytes:&(value) length:sizeof(float)];

        [self.peripheral writeValue:data forCharacteristic:self.intervalCharacteristic type:CBCharacteristicWriteWithResponse];
        
    }
    
}

- (void) setArchival:(NSNumber *)archival {

    if ( (_archival = archival) ) {
        
        float       value   = [archival floatValue];
        NSData *    data    = [NSData dataWithBytes:&(value) length:sizeof(float)];
        
        [self.peripheral writeValue:data forCharacteristic:self.archivalCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        float       value   = 0.0;
        NSData *    data    = [NSData dataWithBytes:&(value) length:sizeof(float)];

        [self.peripheral writeValue:data forCharacteristic:self.archivalCharacteristic type:CBCharacteristicWriteWithResponse];
        
    }
    
}

@end
