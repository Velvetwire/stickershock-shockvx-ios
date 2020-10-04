//
//  project: Shock Vx
//     file: SensorRecords.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "SensorRecords.h"

@interface SensorRecords ( )

@property (nonatomic, weak)     CBPeripheral *                  peripheral;
@property (nonatomic, weak)     id <SensorRecordsDelegate>      delegate;

@property (nonatomic, strong)   CBCharacteristic *              intervalCharacteristic;

@property (nonatomic, strong)   CBCharacteristic *              cursorCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              dataCharacteristic;

@end

@implementation SensorRecords

+ (CBUUID *) serviceIdentifier { return [CBUUID UUIDWithString:kSensorRecordsServiceUUID]; }

+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate { return [[SensorRecords alloc] initWithPeripheral:peripheral delegate:delegate]; }

- (instancetype) initWithPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate {

    if ( (self = [super init]) ) { _peripheral = peripheral; _delegate = delegate; }

    return ( self );

}

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorRecordsIntervalUUID]] ) { [self setIntervalCharacteristic:characteristic]; }

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorRecordsCursorUUID]] ) { [self setCursorCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorRecordsDataUUID]] ) { [self setDataCharacteristic:characteristic]; }

}

- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorRecordsIntervalUUID]] ) {
        
        float *         interval    = (float *) [characteristic.value bytes];
        _interval                   = interval ? [NSNumber numberWithFloat:(*interval)] : nil;
        
        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate sensorRecords:self interval:self.interval]; });
        
    }

}

#pragma mark - Recording Interval

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

@end
