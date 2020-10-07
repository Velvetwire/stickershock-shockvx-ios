//
//  project: Shock Vx
//     file: SensorSurface.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "SensorSurface.h"

@interface SensorSurface ( )

@property (nonatomic, weak)     CBPeripheral *                  peripheral;
@property (nonatomic, weak)     id <SensorSurfaceDelegate>      delegate;

@property (nonatomic, strong)   CBCharacteristic *              valueCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              lowerCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              upperCharacteristic;

@end

@implementation SensorSurface

+ (CBUUID *) serviceIdentifier { return [CBUUID UUIDWithString:kSensorSurfaceServiceUUID]; }

+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate { return [[SensorSurface alloc] initWithPeripheral:peripheral delegate:delegate]; }

- (instancetype) initWithPeripheral:(CBPeripheral *)peripheral  delegate:(id)delegate {

    if ( (self = [super init]) ) { _peripheral = peripheral; _delegate = delegate; }

    return ( self );

}

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorSurfaceValueUUID]] ) { [self setValueCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorSurfaceLowerUUID]] ) { [self setLowerCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorSurfaceUpperUUID]] ) { [self setUpperCharacteristic:characteristic]; }

}

- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorSurfaceValueUUID]] ) {
        
        float *                 value   = (float *) [characteristic.value bytes];
        
        if ( value ) { _temperature = [NSNumber numberWithFloat:*(value)]; }

        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorSurface:self]; });

    }

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorSurfaceLowerUUID]] ) {

        float *                 value   = (float *) [characteristic.value bytes];
        
        if ( value ) { _temperatureMinimum = [NSNumber numberWithFloat:*(value)]; }

        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorMinimumSurface:self]; });

    }

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorSurfaceUpperUUID]] ) {

        float *                 value   = (float *) [characteristic.value bytes];
        
        if ( value ) { _temperatureMaximum = [NSNumber numberWithFloat:*(value)]; }

        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorMaximumSurface:self]; });

    }

}

#pragma mark - Temperature Limits

- (void) setTemperatureMinimum:(NSNumber *)minimum {

    if ( (_temperatureMinimum = minimum) ) {

        float       value       = [minimum floatValue];
        NSData *    data        = [NSData dataWithBytes:&(value) length:sizeof(float)];
        
        [self.peripheral writeValue:data forCharacteristic:self.lowerCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        float       value       = 0.0;
        NSData *    data        = [NSData dataWithBytes:&(value) length:sizeof(float)];
        
        [self.peripheral writeValue:data forCharacteristic:self.lowerCharacteristic type:CBCharacteristicWriteWithResponse];

    }

}

- (void) setTemperatureMaximum:(NSNumber *)maximum {

    if ( (_temperatureMaximum = maximum) ) {

        float       value       = [maximum floatValue];
        NSData *    data        = [NSData dataWithBytes:&(value) length:sizeof(float)];
        
        [self.peripheral writeValue:data forCharacteristic:self.upperCharacteristic type:CBCharacteristicWriteWithResponse];
        
    } else {

        float       value       = 0.0;
        NSData *    data        = [NSData dataWithBytes:&(value) length:sizeof(float)];
        
        [self.peripheral writeValue:data forCharacteristic:self.upperCharacteristic type:CBCharacteristicWriteWithResponse];

    }

}

@end
