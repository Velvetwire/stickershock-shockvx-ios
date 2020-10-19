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
@property (nonatomic, strong)   CBCharacteristic *              countCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              eventCharacteristic;

@property (nonatomic, strong)   NSMutableArray *                eventRecords;
@property (nonatomic, strong)   NSNumber *                      eventCount;

@end

@implementation SensorSurface

+ (CBUUID *) serviceIdentifier { return [CBUUID UUIDWithString:kSensorSurfaceServiceUUID]; }

+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate { return [[SensorSurface alloc] initWithPeripheral:peripheral delegate:delegate]; }

- (instancetype) initWithPeripheral:(CBPeripheral *)peripheral  delegate:(id)delegate {

    if ( (self = [super init]) ) {
        
        _eventRecords   = [[NSMutableArray alloc] init];

        _peripheral     = peripheral;
        _delegate       = delegate;

    }
    
    return ( self );

}

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorSurfaceValueUUID]] ) { [self setValueCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorSurfaceLowerUUID]] ) { [self setLowerCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorSurfaceUpperUUID]] ) { [self setUpperCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorSurfaceCountUUID]] ) { [self setCountCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorSurfaceEventUUID]] ) { [self setEventCharacteristic:characteristic]; }

}

- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:self.valueCharacteristic.UUID] ) {
        
        float *                 value   = (float *) [characteristic.value bytes];
        
        if ( value ) { _temperature = [NSNumber numberWithFloat:*(value)]; }

        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorSurface:self]; });

    }

    if ( [characteristic.UUID isEqual:self.lowerCharacteristic.UUID] ) {

        float *                 value   = (float *) [characteristic.value bytes];
        
        if ( value ) { _temperatureMinimum = [NSNumber numberWithFloat:*(value)]; }

        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorMinimumSurface:self]; });

    }

    if ( [characteristic.UUID isEqual:self.upperCharacteristic.UUID] ) {

        float *                 value   = (float *) [characteristic.value bytes];
        
        if ( value ) { _temperatureMaximum = [NSNumber numberWithFloat:*(value)]; }

        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorMaximumSurface:self]; });

    }

    if ( [characteristic.UUID isEqual:self.countCharacteristic.UUID] ) {

        unsigned short          count   = *(unsigned short *) [characteristic.value bytes];
        
        [self setEventCount:[NSNumber numberWithUnsignedShort:count]];
        
        if ( [self.eventCount unsignedIntegerValue] > self.eventRecords.count ) [self requestNextEvent];
        
    }

    if ( [characteristic.UUID isEqual:self.eventCharacteristic.UUID] ) {

        surface_event_t *       event   = (surface_event_t *) [characteristic.value bytes];
        
        if ( event ) {
            
            NSNumber *           index  = [NSNumber numberWithUnsignedInteger: self.eventRecords.count];
            NSDictionary *      record  = @{ @"date":[NSDate dateWithTimeIntervalSince1970:event->time],
                                             @"temperature":[NSNumber numberWithFloat:((float) event->temperature / 1e2)] };

            [self.eventRecords addObject:record];

            if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorSurface:self eventIndex:index]; });

        } else [self.eventRecords removeAllObjects];
        
        if ( [self.eventCount unsignedIntegerValue] > self.eventRecords.count ) [self requestNextEvent];

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

#pragma mark - Archived events

- (void) requestNextEvent {

    unsigned short      index   = (unsigned short) self.eventRecords.count;
    NSData *            data    = [NSData dataWithBytes:&(index) length:sizeof(short)];

    [self.peripheral writeValue:data forCharacteristic:self.eventCharacteristic type:CBCharacteristicWriteWithResponse];

}

- (NSUInteger) number { return [self.eventCount unsignedIntegerValue]; }

- (NSArray *) events { return [self eventRecords]; }

@end
