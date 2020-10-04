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

@property (nonatomic, strong)   CBCharacteristic *              valueCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              upperCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              lowerCharacteristic;

@property (nonatomic)           telemetry_values_t              lowerLimits;
@property (nonatomic)           telemetry_values_t              upperLimits;

@end

@implementation SensorTelemetry

@synthesize lowerLimits = _lowerLimits;
@synthesize upperLimits = _upperLimits;

+ (CBUUID *) serviceIdentifier { return [CBUUID UUIDWithString:kSensorTelemetryServiceUUID]; }

+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate { return [[SensorTelemetry alloc] initWithPeripheral:peripheral delegate:delegate]; }

- (instancetype) initWithPeripheral:(CBPeripheral *)peripheral  delegate:(id)delegate {

    if ( (self = [super init]) ) { _peripheral = peripheral; _delegate = delegate; }

    return ( self );

}

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorTelemetryIntervalUUID]] ) { [self setIntervalCharacteristic:characteristic]; }

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorTelemetryValueUUID]] ) { [self setValueCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorTelemetryUpperUUID]] ) { [self setUpperCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorTelemetryLowerUUID]] ) { [self setLowerCharacteristic:characteristic]; }

}

- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorTelemetryIntervalUUID]] ) {
        
        float *         interval    = (float *) [characteristic.value bytes];
        _interval                   = interval ? [NSNumber numberWithFloat:(*interval)] : nil;
        
        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorTelemetry:self interval:self.interval]; });
        
    }

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorTelemetryValueUUID]] ) {
        
        telemetry_values_t *  value = (telemetry_values_t *) [characteristic.value bytes];
        
        if ( value ) {
            
            _pressure   = [NSNumber numberWithFloat:value->pressure];
            _humidity   = [NSNumber numberWithFloat:value->humidity];
            _ambient    = [NSNumber numberWithFloat:value->ambient];
            _surface    = [NSNumber numberWithFloat:value->surface];
            
        }

        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorTelemetry:self]; });

    }

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorTelemetryUpperUUID]] ) {

        telemetry_values_t *  value = memcpy ( &(_upperLimits), [characteristic.value bytes], sizeof(telemetry_values_t) );
        
        if ( value ) {
        
            _pressureMaximum    = [NSNumber numberWithFloat:value->pressure];
            _humidityMaximum    = [NSNumber numberWithFloat:value->humidity];
            _ambientMaximum     = [NSNumber numberWithFloat:value->ambient];
            _surfaceMaximum     = [NSNumber numberWithFloat:value->surface];
            
        }
        
        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorMaximumTelemetry:self]; });

    }

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorTelemetryLowerUUID]] ) {
        
        telemetry_values_t *  value = memcpy ( &(_lowerLimits), [characteristic.value bytes], sizeof(telemetry_values_t) );

        if ( value ) {
            
            _pressureMinimum    = [NSNumber numberWithFloat:value->pressure];
            _humidityMinimum    = [NSNumber numberWithFloat:value->humidity];
            _ambientMinimum     = [NSNumber numberWithFloat:value->ambient];
            _surfaceMinimum     = [NSNumber numberWithFloat:value->surface];
            
        }

        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorMinimumTelemetry:self]; });

    }

}

#pragma mark - Telemetry Interval

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

#pragma mark - Pressure Limits

- (void) setPressureMaximum:(NSNumber *)maximum {

    if ( (_pressureMaximum = maximum) ) {

        _upperLimits.pressure   = [maximum floatValue];
        NSData *    data        = [NSData dataWithBytes:&(_upperLimits) length:sizeof(telemetry_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.upperCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        _upperLimits.pressure   = 0.0;
        NSData *    data        = [NSData dataWithBytes:&(_upperLimits) length:sizeof(telemetry_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.upperCharacteristic type:CBCharacteristicWriteWithResponse];

    }

}

- (void) setPressureMinimum:(NSNumber *)minimum {

    if ( (_pressureMinimum = minimum) ) {

        _lowerLimits.pressure   = [minimum floatValue];
        NSData *    data        = [NSData dataWithBytes:&(_lowerLimits) length:sizeof(telemetry_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.lowerCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        _lowerLimits.pressure   = 0.0;
        NSData *    data        = [NSData dataWithBytes:&(_lowerLimits) length:sizeof(telemetry_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.lowerCharacteristic type:CBCharacteristicWriteWithResponse];

    }

}

#pragma mark - Humidity Limits

- (void) setHumidityMaximum:(NSNumber *)maximum {

    if ( (_humidityMaximum = maximum) ) {

        _upperLimits.humidity   = [maximum floatValue];
        NSData *    data        = [NSData dataWithBytes:&(_upperLimits) length:sizeof(telemetry_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.upperCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        _upperLimits.humidity   = 0.0;
        NSData *    data        = [NSData dataWithBytes:&(_upperLimits) length:sizeof(telemetry_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.upperCharacteristic type:CBCharacteristicWriteWithResponse];

    }
    
}

- (void) setHumidityMinimum:(NSNumber *)minimum {

    if ( (_humidityMinimum = minimum) ) {

        _lowerLimits.humidity   = [minimum floatValue];
        NSData *    data        = [NSData dataWithBytes:&(_lowerLimits) length:sizeof(telemetry_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.lowerCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        _lowerLimits.humidity   = 0.0;
        NSData *    data        = [NSData dataWithBytes:&(_lowerLimits) length:sizeof(telemetry_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.lowerCharacteristic type:CBCharacteristicWriteWithResponse];

    }

}

#pragma mark - Ambient Temperature Limits

- (void) setAmbientMaximum:(NSNumber *)maximum {

    if ( (_ambientMaximum = maximum) ) {

        _upperLimits.ambient    = [maximum floatValue];
        NSData *    data        = [NSData dataWithBytes:&(_upperLimits) length:sizeof(telemetry_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.upperCharacteristic type:CBCharacteristicWriteWithResponse];
        
    } else {

        _upperLimits.ambient    = 0.0;
        NSData *    data        = [NSData dataWithBytes:&(_upperLimits) length:sizeof(telemetry_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.upperCharacteristic type:CBCharacteristicWriteWithResponse];

    }

}

- (void) setAmbientMinimum:(NSNumber *)minimum {

    if ( (_ambientMinimum = minimum) ) {

        _lowerLimits.ambient    = [minimum floatValue];
        NSData *    data        = [NSData dataWithBytes:&(_lowerLimits) length:sizeof(telemetry_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.lowerCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        _lowerLimits.ambient    = 0.0;
        NSData *    data        = [NSData dataWithBytes:&(_lowerLimits) length:sizeof(telemetry_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.lowerCharacteristic type:CBCharacteristicWriteWithResponse];

    }

}

#pragma mark - Surface Temperature Limits

- (void) setSurfaceMaximum:(NSNumber *)maximum {

    if ( (_surfaceMaximum = maximum) ) {

        _upperLimits.surface    = [maximum floatValue];
        NSData *    data        = [NSData dataWithBytes:&(_upperLimits) length:sizeof(telemetry_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.upperCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        _upperLimits.surface    = 0.0;
        NSData *    data        = [NSData dataWithBytes:&(_upperLimits) length:sizeof(telemetry_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.upperCharacteristic type:CBCharacteristicWriteWithResponse];

    }

}

- (void) setSurfaceMinimum:(NSNumber *)minimum {

    if ( (_surfaceMinimum = minimum) ) {

        _lowerLimits.surface    = [minimum floatValue];
        NSData *    data        = [NSData dataWithBytes:&(_lowerLimits) length:sizeof(telemetry_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.lowerCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        _lowerLimits.surface    = 0.0;
        NSData *    data        = [NSData dataWithBytes:&(_lowerLimits) length:sizeof(telemetry_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.lowerCharacteristic type:CBCharacteristicWriteWithResponse];

    }

}

@end
