//
//  project: Shock Vx
//     file: SensorAtmosphere.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "SensorAtmosphere.h"

@interface SensorAtmosphere ( )

@property (nonatomic, weak)     CBPeripheral *                  peripheral;
@property (nonatomic, weak)     id <SensorAtmosphereDelegate>   delegate;

@property (nonatomic, strong)   CBCharacteristic *              valueCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              lowerCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              upperCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              countCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              eventCharacteristic;

@property (nonatomic, strong)   NSMutableArray *                eventRecords;
@property (nonatomic, strong)   NSNumber *                      eventCount;

@property (nonatomic)           atmosphere_values_t             lowerLimits;
@property (nonatomic)           atmosphere_values_t             upperLimits;

@end

@implementation SensorAtmosphere

@synthesize lowerLimits = _lowerLimits;
@synthesize upperLimits = _upperLimits;

+ (CBUUID *) serviceIdentifier { return [CBUUID UUIDWithString:kSensorAtmosphereServiceUUID]; }

+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate { return [[SensorAtmosphere alloc] initWithPeripheral:peripheral delegate:delegate]; }

- (instancetype) initWithPeripheral:(CBPeripheral *)peripheral  delegate:(id)delegate {

    if ( (self = [super init]) ) {
        
        _eventRecords   = [[NSMutableArray alloc] init];

        _peripheral     = peripheral;
        _delegate       = delegate;

    }

    return ( self );

}

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorAtmosphereValueUUID]] ) { [self setValueCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorAtmosphereLowerUUID]] ) { [self setLowerCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorAtmosphereUpperUUID]] ) { [self setUpperCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorAtmosphereCountUUID]] ) { [self setCountCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorAtmosphereEventUUID]] ) { [self setEventCharacteristic:characteristic]; }

}

- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:self.valueCharacteristic.UUID] ) {
        
        atmosphere_values_t *   value   = (atmosphere_values_t *) [characteristic.value bytes];
        
        if ( value ) {
            
            _ambient    = [NSNumber numberWithFloat:value->ambient];
            _humidity   = [NSNumber numberWithFloat:value->humidity];
            _pressure   = [NSNumber numberWithFloat:value->pressure];

        }

        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorAtmosphere:self]; });

    }

    if ( [characteristic.UUID isEqual:self.lowerCharacteristic.UUID] ) {
        
        atmosphere_values_t *   value   = memcpy ( &(_lowerLimits), [characteristic.value bytes], sizeof(atmosphere_values_t) );

        if ( value ) {
            
            _ambientMinimum     = [NSNumber numberWithFloat:value->ambient];
            _humidityMinimum    = [NSNumber numberWithFloat:value->humidity];
            _pressureMinimum    = [NSNumber numberWithFloat:value->pressure];

        }

        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorMinimumAtmosphere:self]; });

    }

    if ( [characteristic.UUID isEqual:self.upperCharacteristic.UUID] ) {

        atmosphere_values_t *   value   = memcpy ( &(_upperLimits), [characteristic.value bytes], sizeof(atmosphere_values_t) );
        
        if ( value ) {
        
            _ambientMaximum     = [NSNumber numberWithFloat:value->ambient];
            _humidityMaximum    = [NSNumber numberWithFloat:value->humidity];
            _pressureMaximum    = [NSNumber numberWithFloat:value->pressure];
            
        }
        
        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorMaximumAtmosphere:self]; });

    }

    if ( [characteristic.UUID isEqual:self.countCharacteristic.UUID] ) {

        unsigned short          count   = *(unsigned short *) [characteristic.value bytes];
        
        [self setEventCount:[NSNumber numberWithUnsignedShort:count]];
        
        if ( [self.eventCount unsignedIntegerValue] > self.eventRecords.count ) [self requestNextEvent];
        
    }

    if ( [characteristic.UUID isEqual:self.eventCharacteristic.UUID] ) {

        atmosphere_event_t *    event   = (atmosphere_event_t *) [characteristic.value bytes];
        
        if ( event ) {
            
            NSNumber *           index  = [NSNumber numberWithUnsignedInteger: self.eventRecords.count];
            NSDictionary *      record  = @{ @"date":[NSDate dateWithTimeIntervalSince1970:event->time],
                                             @"temperature":[NSNumber numberWithFloat:((float) event->temperature / 1e2)],
                                             @"humidity":[NSNumber numberWithFloat:((float) event->humidity / 1e3)],
                                             @"pressure":[NSNumber numberWithFloat:((float) event->humidity / 1e4)] };

            [self.eventRecords addObject:record];

            if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorAtmosphere:self eventIndex:index]; });
            
        } else [self.eventRecords removeAllObjects];
        
        if ( [self.eventCount unsignedIntegerValue] > self.eventRecords.count ) [self requestNextEvent];

    }

}

#pragma mark - Ambient Temperature Limits

- (void) setAmbientMinimum:(NSNumber *)minimum {

    if ( (_ambientMinimum = minimum) ) {

        _lowerLimits.ambient    = [minimum floatValue];
        NSData *    data        = [NSData dataWithBytes:&(_lowerLimits) length:sizeof(atmosphere_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.lowerCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        _lowerLimits.ambient    = 0.0;
        NSData *    data        = [NSData dataWithBytes:&(_lowerLimits) length:sizeof(atmosphere_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.lowerCharacteristic type:CBCharacteristicWriteWithResponse];

    }

}

- (void) setAmbientMaximum:(NSNumber *)maximum {

    if ( (_ambientMaximum = maximum) ) {

        _upperLimits.ambient    = [maximum floatValue];
        NSData *    data        = [NSData dataWithBytes:&(_upperLimits) length:sizeof(atmosphere_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.upperCharacteristic type:CBCharacteristicWriteWithResponse];
        
    } else {

        _upperLimits.ambient    = 0.0;
        NSData *    data        = [NSData dataWithBytes:&(_upperLimits) length:sizeof(atmosphere_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.upperCharacteristic type:CBCharacteristicWriteWithResponse];

    }

}

#pragma mark - Humidity Limits

- (void) setHumidityMinimum:(NSNumber *)minimum {

    if ( (_humidityMinimum = minimum) ) {

        _lowerLimits.humidity   = [minimum floatValue];
        NSData *    data        = [NSData dataWithBytes:&(_lowerLimits) length:sizeof(atmosphere_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.lowerCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        _lowerLimits.humidity   = 0.0;
        NSData *    data        = [NSData dataWithBytes:&(_lowerLimits) length:sizeof(atmosphere_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.lowerCharacteristic type:CBCharacteristicWriteWithResponse];

    }

}

- (void) setHumidityMaximum:(NSNumber *)maximum {

    if ( (_humidityMaximum = maximum) ) {

        _upperLimits.humidity   = [maximum floatValue];
        NSData *    data        = [NSData dataWithBytes:&(_upperLimits) length:sizeof(atmosphere_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.upperCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        _upperLimits.humidity   = 0.0;
        NSData *    data        = [NSData dataWithBytes:&(_upperLimits) length:sizeof(atmosphere_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.upperCharacteristic type:CBCharacteristicWriteWithResponse];

    }
    
}

#pragma mark - Pressure Limits

- (void) setPressureMinimum:(NSNumber *)minimum {

    if ( (_pressureMinimum = minimum) ) {

        _lowerLimits.pressure   = [minimum floatValue];
        NSData *    data        = [NSData dataWithBytes:&(_lowerLimits) length:sizeof(atmosphere_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.lowerCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        _lowerLimits.pressure   = 0.0;
        NSData *    data        = [NSData dataWithBytes:&(_lowerLimits) length:sizeof(atmosphere_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.lowerCharacteristic type:CBCharacteristicWriteWithResponse];

    }

}

- (void) setPressureMaximum:(NSNumber *)maximum {

    if ( (_pressureMaximum = maximum) ) {

        _upperLimits.pressure   = [maximum floatValue];
        NSData *    data        = [NSData dataWithBytes:&(_upperLimits) length:sizeof(atmosphere_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.upperCharacteristic type:CBCharacteristicWriteWithResponse];

    } else {

        _upperLimits.pressure   = 0.0;
        NSData *    data        = [NSData dataWithBytes:&(_upperLimits) length:sizeof(atmosphere_values_t)];
        
        [self.peripheral writeValue:data forCharacteristic:self.upperCharacteristic type:CBCharacteristicWriteWithResponse];

    }

}

#pragma mark - Archived events

- (void) requestNextEvent {

    unsigned short      index   = (unsigned short) self.eventRecords.count;
    NSData *            data    = [NSData dataWithBytes:&(index) length:sizeof(short)];

    [self.peripheral writeValue:data forCharacteristic:self.eventCharacteristic type:CBCharacteristicWriteWithResponse];

}

- (NSUInteger) number { return [self.eventCount unsignedIntegerValue]; }

- (NSArray *) events { return [self.eventRecords copy]; }

@end
