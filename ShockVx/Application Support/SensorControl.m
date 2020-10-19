//
//  project: Shock Vx
//     file: SensorControl.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "SensorControl.h"

@interface SensorControl ( )

@property (nonatomic, weak)     CBPeripheral *                  peripheral;
@property (nonatomic, weak)     id <SensorControlDelegate>      delegate;
@property (nonatomic, strong)   NSUUID *                        service;

@property (nonatomic, strong)   CBCharacteristic *              nodeCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              lockCharacteristic;

@property (nonatomic, strong)   CBCharacteristic *              openedCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              closedCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              windowCharacteristic;

@property (nonatomic, strong)   CBCharacteristic *              identifyCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              summaryCharacteristic;

@property (nonatomic)           bool                            updates;

@end

@implementation SensorControl

#pragma mark - Service instantiation

+ (instancetype) controlService:(NSUUID *)service forPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate { return [[SensorControl alloc] initService:service forPeripheral:peripheral delegate:delegate]; }

- (instancetype) initService:(NSUUID *)service forPeripheral:(CBPeripheral *)peripheral  delegate:(id)delegate {

    if ( (self = [super init]) ) { _service = service; _peripheral = peripheral; _delegate = delegate; }

    return ( self );

}

#pragma mark - Service identifier

//
// Construct a 128-bit Bluetooth UUID from the prefix and the service UUID suffix
- (CBUUID *) identifierWithPrefix:(NSString *)prefix {

    NSString *  suffix      = [[self.service UUIDString] substringFromIndex:8];
    
    return [CBUUID UUIDWithString:[prefix stringByAppendingString:suffix]];
    
}

#pragma mark - Service characteristics

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[self identifierWithPrefix:kSensorControlNodePrefix]] ) { [self setNodeCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[self identifierWithPrefix:kSensorControlLockPrefix]] ) { [self setLockCharacteristic:characteristic]; }

    if ( [characteristic.UUID isEqual:[self identifierWithPrefix:kSensorControlOpenedPrefix]] ) { [self setOpenedCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[self identifierWithPrefix:kSensorControlClosedPrefix]] ) { [self setClosedCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[self identifierWithPrefix:kSensorControlWindowPrefix]] ) { [self setWindowCharacteristic:characteristic]; }

    if ( [characteristic.UUID isEqual:[self identifierWithPrefix:kSensorControlIdentifyPrefix]] ) { [self setIdentifyCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[self identifierWithPrefix:kSensorControlSummaryPrefix]] ) { [self setSummaryCharacteristic:characteristic]; }

}

- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:self.nodeCharacteristic.UUID] ) {
        
        unsigned char *     bytes   = (unsigned char *) [characteristic.value bytes];
        _trackingNode               = nil;
        
        for ( int n = 0; n < characteristic.value.length; ++n ) if ( bytes[ n ] ) { _trackingNode = [AssetIdentifier identifierWithData:characteristic.value]; break; }
        
        [self updatedCharacteristic:characteristic];
        
    }

    if ( [characteristic.UUID isEqual:self.lockCharacteristic.UUID] ) {
        
        unsigned char *     bytes   = (unsigned char *) [characteristic.value bytes];
        _trackingLock               = nil;
        
        for ( int n = 0; n < characteristic.value.length; ++n ) if ( bytes[ n ] ) { _trackingLock = [[NSUUID alloc] initWithUUIDBytes:bytes]; break; }
        
        [self updatedCharacteristic:characteristic];
        
    }

    if ( [characteristic.UUID isEqual:self.openedCharacteristic.UUID] ) {
        
        unsigned char *     bytes   = (unsigned char *) [characteristic.value bytes];
        _uuidOpened                 = nil;
        
        for ( int n = 0; n < characteristic.value.length; ++n ) if ( bytes[ n ] ) { _uuidOpened = [[NSUUID alloc] initWithUUIDBytes:bytes]; break; }
        
        [self updatedCharacteristic:characteristic];
        
    }
    
    if ( [characteristic.UUID isEqual:self.closedCharacteristic.UUID] ) {
        
        unsigned char *     bytes   = (unsigned char *) [characteristic.value bytes];
        _uuidClosed                 = nil;
        
        for ( int n = 0; n < characteristic.value.length; ++n ) if ( bytes[ n ] ) { _uuidClosed = [[NSUUID alloc] initWithUUIDBytes:bytes]; break; }
        
        [self updatedCharacteristic:characteristic];
        
    }

    if ( [characteristic.UUID isEqual:self.windowCharacteristic.UUID] ) {
        
        control_window_t *  window  = (control_window_t *) [characteristic.value bytes];
        
        if ( window->opened ) { _timeOpened = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) window->opened]; }
        else { _timeOpened = nil; }

        if ( window->closed ) { _timeClosed = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) window->closed]; }
        else { _timeClosed = nil; }

        [self updatedCharacteristic:characteristic];
        
    }

    if ( [characteristic.UUID isEqual:self.summaryCharacteristic.UUID] ) {
        
        control_summary_t * summary = (control_summary_t *) [characteristic.value bytes];
        _storageUsed                = [NSNumber numberWithFloat:(float)(100.0 - summary->storage) / 100.0];
        _memoryUsed                 = [NSNumber numberWithFloat:(float)(100 - summary->memory) / 100.0];

        _surfaceSensor              = (summary->status & kControlSurfaceSensorOK) ? true : false;
        _ambientSensor              = (summary->status & kControlAmbientSensorOK) ? true : false;
        _humiditySensor             = (summary->status & kControlHumiditySensorOK) ? true : false;
        _pressureSensor             = (summary->status & kControlPressureSensorOK) ? true : false;
        _movementSensor             = (summary->status & kControlMovementSensorOK) ? true : false;

        [self updatedCharacteristic:characteristic];

    }
    
}

//
// A write to a characteristic has been confirmed.
- (void) confirmedCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:self.openedCharacteristic.UUID] ) { [self.delegate sensorControl:self trackingWindow:kTrackingWindowOpened]; }
    if ( [characteristic.UUID isEqual:self.closedCharacteristic.UUID] ) { [self.delegate sensorControl:self trackingWindow:kTrackingWindowClosed]; }

}

//
// An characteristic has been updated.
- (void) updatedCharacteristic:(CBCharacteristic *)characteristic {

    // If the information has changed, trigger a delayed dispatch to the
    // delegate, informing it of the changes.
    
    if ( ! self.updates ) dispatch_after( dispatch_time( DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC ), dispatch_get_main_queue( ), ^{ [self setUpdates:false]; [self.delegate sensorControl:self]; });
    if ( ! self.updates ) [self setUpdates:true];

}

- (void) setTrackingNode:(AssetIdentifier *)node {
    
    if ( (_trackingNode = node) ) {
    
        [self.peripheral writeValue:[node identifierData]
                  forCharacteristic:self.nodeCharacteristic
                               type:CBCharacteristicWriteWithResponse];
        
    }
    
}

- (void) setTrackingLock:(NSUUID *)lock {
    
    if ( (_trackingLock = lock) ) {
    
        unsigned char   bytes [ 16 ];
        
        [lock getUUIDBytes:bytes];
        [self.peripheral writeValue:[NSData dataWithBytes:bytes length:sizeof(bytes)]
                  forCharacteristic:self.lockCharacteristic
                               type:CBCharacteristicWriteWithResponse];
        
    }
    
}

- (void) openUsingIdentifier:(NSUUID *)identifier {
    
    if ( (_uuidOpened = identifier) && (_timeOpened = [NSDate date]) ) {
    
        unsigned char   bytes [ 16 ];
        
        [identifier getUUIDBytes:bytes];
        
        [self.peripheral writeValue:[NSData dataWithBytes:bytes length:sizeof(bytes)]
                  forCharacteristic:self.openedCharacteristic
                               type:CBCharacteristicWriteWithResponse];

    }
    
}

- (void) closeUsingIdentifier:(NSUUID *)identifier {
    
    if ( (_uuidClosed = identifier) && (_timeClosed = [NSDate date]) ) {
    
        unsigned char   bytes [ 16 ];
        
        [identifier getUUIDBytes:bytes];
        [self.peripheral writeValue:[NSData dataWithBytes:bytes length:sizeof(bytes)]
                  forCharacteristic:self.closedCharacteristic
                               type:CBCharacteristicWriteWithResponse];
        
    }
    
}

- (void) identifySensor:(unsigned char)seconds {

    NSData *    value   = [NSData dataWithBytes:&(seconds) length:sizeof(char)];
    
    [self.peripheral writeValue:value forCharacteristic:self.identifyCharacteristic type:CBCharacteristicWriteWithResponse];

}

@end
