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
@property (nonatomic)           bool                            updates;

@property (nonatomic, strong)   CBCharacteristic *              nodeCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              lockCharacteristic;

@property (nonatomic, strong)   CBCharacteristic *              openedCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              closedCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              windowCharacteristic;

@property (nonatomic, strong)   CBCharacteristic *              identifyCharacteristic;

@end

@implementation SensorControl

+ (CBUUID *) serviceIdentifier { return [CBUUID UUIDWithString:kSensorControlServiceUUID]; }

+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate { return [[SensorControl alloc] initWithPeripheral:peripheral delegate:delegate]; }

- (instancetype) initWithPeripheral:(CBPeripheral *)peripheral  delegate:(id)delegate {

    if ( (self = [super init]) ) { _peripheral = peripheral; _delegate = delegate; }
    
    return ( self );

}

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorControlNodeUUID]] ) { [self setNodeCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorControlLockUUID]] ) { [self setLockCharacteristic:characteristic]; }

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorControlOpenedUUID]] ) { [self setOpenedCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorControlClosedUUID]] ) { [self setClosedCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorControlWindowUUID]] ) { [self setWindowCharacteristic:characteristic]; }

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorControlIdentifyUUID]] ) { [self setIdentifyCharacteristic:characteristic]; }

}

- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorControlNodeUUID]] ) {
        
        unsigned char *     bytes   = (unsigned char *) [characteristic.value bytes];
        _trackingNode               = nil;
        
        for ( int n = 0; n < characteristic.value.length; ++n ) if ( bytes[ n ] ) { _trackingNode = [AssetIdentifier identifierWithData:characteristic.value]; break; }
        
        [self updatedCharacteristic:characteristic];
        
    }

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorControlLockUUID]] ) {
        
        unsigned char *     bytes   = (unsigned char *) [characteristic.value bytes];
        _trackingLock               = nil;
        
        for ( int n = 0; n < characteristic.value.length; ++n ) if ( bytes[ n ] ) { _trackingLock = [[NSUUID alloc] initWithUUIDBytes:bytes]; break; }
        
        [self updatedCharacteristic:characteristic];
        
    }

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorControlOpenedUUID]] ) {
        
        unsigned char *     bytes   = (unsigned char *) [characteristic.value bytes];
        _uuidOpened                 = nil;
        
        for ( int n = 0; n < characteristic.value.length; ++n ) if ( bytes[ n ] ) { _uuidOpened = [[NSUUID alloc] initWithUUIDBytes:bytes]; break; }
        
        [self updatedCharacteristic:characteristic];
        
    }
    
    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorControlClosedUUID]] ) {
        
        unsigned char *     bytes   = (unsigned char *) [characteristic.value bytes];
        _uuidClosed                 = nil;
        
        for ( int n = 0; n < characteristic.value.length; ++n ) if ( bytes[ n ] ) { _uuidClosed = [[NSUUID alloc] initWithUUIDBytes:bytes]; break; }
        
        [self updatedCharacteristic:characteristic];
        
    }

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorControlWindowUUID]] ) {
        
        control_window_t *  window  = (control_window_t *) [characteristic.value bytes];
        
        if ( window->opened ) { _timeOpened = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) window->opened]; }
        else { _timeOpened = nil; }

        if ( window->closed ) { _timeClosed = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval) window->closed]; }
        else { _timeClosed = nil; }

        [self updatedCharacteristic:characteristic];
        
    }

}

//
// A write to a characteristic has been confirmed.
- (void) confirmedCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorControlOpenedUUID]] ) {
        [self.delegate sensorControl:self trackingWindow:kTrackingWindowOpened];
    }

    if ( [characteristic.UUID isEqual:[CBUUID UUIDWithString:kSensorControlClosedUUID]] ) {
        [self.delegate sensorControl:self trackingWindow:kTrackingWindowClosed];
    }

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
