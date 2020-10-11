//
//  project: Shock Vx
//     file: UpdateDevice.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "UpdateDevice.h"

//
// Update device interface
@interface UpdateDevice ( )

@property (nonatomic, strong)   NSData *        package;
@property (nonatomic)           UpdateStatus    packageStatus;
@property (nonatomic)           unsigned        packageTarget;
@property (nonatomic)           unsigned        packageOffset;
@property (nonatomic)           unsigned        packageLimit;

@property (nonatomic)           unsigned short  checksum;

@end

//
// Update device implementation
@implementation UpdateDevice

#pragma mark - Device instantiation

//
// Instantiate a new sensor asset.
+ (instancetype) updateWithUnit:(AssetIdentifier *)unit node:(AssetIdentifier *)node controlService:(NSUUID *)control primaryService:(NSUUID *)primary {
    
    return [[UpdateDevice alloc] initWithUnit:unit node:node controlService:control primaryService:primary];
    
}

//
// Initialize the instance.
- (instancetype) initWithUnit:(AssetIdentifier *)unit node:(AssetIdentifier *)node controlService:(NSUUID *)control primaryService:(NSUUID *)primary {
 
    // Instantiate the sensor.

    if ( (self = [super initWithUnit:unit node:node controlService:control primaryService:primary]) ) {
    
    }
    
    // Return with the instance.
    
    return ( self );
    
}

#pragma mark - Service characteristics

//
// Services have been discovered.
- (void) peripheral:(CBPeripheral *)peripheral service:(CBService *)service {

    [super peripheral:peripheral service:service];
    
    // If this is the primary service, construct the device update service as the primary.
    
    if ( [service.UUID isEqual:[CBUUID UUIDWithNSUUID:self.primaryService]] && self.update == nil ) [self setUpdate:[DeviceUpdate updateService:self.primaryService forPeripheral:peripheral delegate:self]];
        
}

//
// Service characteristics have been discovered.
- (void) peripheral:(CBPeripheral *)peripheral service:(CBService *)service characteristic:(CBCharacteristic *)characteristic {

    [super peripheral:peripheral service:service characteristic:characteristic];

    // If these belong to the primary service, forward to the device update service.
    
    if ( [service.UUID isEqual:[CBUUID UUIDWithNSUUID:self.primaryService]] ) [self.update discoveredCharacteristic:characteristic];

}

//
// Charactistic value retrieved.
- (void) peripheral:(CBPeripheral *)peripheral retrievedCharacteristic:(CBCharacteristic *)characteristic {

    [super peripheral:peripheral retrievedCharacteristic:characteristic];

    [self.update retrievedCharacteristic:characteristic];
    
}

//
// Characteristic write confirmed.
- (void) peripheral:(CBPeripheral *)peripheral confirmedCharacteristic:(CBCharacteristic *)characteristic {
    
    [super peripheral:peripheral confirmedCharacteristic:characteristic];
    
    [self.update confirmedCharacteristic:characteristic];
    
}

#pragma mark - Update service delegate

- (void) deviceUpdate:(DeviceUpdate *)update requestCompleted:(bool)completed {

    if ( completed ) {
    
        if ( self.packageStatus == kUpdateStatusErase ) [self setPackageStatus:kUpdateStatusWrite];
        
        if ( self.packageStatus == kUpdateStatusWrite ) {
        
            if ( self.packageOffset < self.package.length ) [self writeRecord];
            else [self setPackageStatus:kUpdateStatusSuccess];
            
        }
        
        if ( self.packageStatus == kUpdateStatusSuccess ) [self finishUpdate];
        
    } else [self failedUpdate];
    
}

- (void) deviceUpdate:(DeviceUpdate *)update writtenChecksum:(NSNumber *)checksum {

    _checksum += [checksum unsignedShortValue];
    
    [self setPackageOffset:self.packageOffset + UPDATE_PACKET_SIZE];
    [self deviceUpdate:update requestCompleted:YES];
    
}

- (void) deviceUpdate:(DeviceUpdate *)update packageInstalled:(bool)installed {

    [self setPackageStatus:kUpdateStatusReady];

}

- (void) deviceUpdate:(DeviceUpdate *)update packageCode:(NSNumber *)code {

    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateNotificationPackageData
                                                        object:self
                                                      userInfo:@{@"code":code}];

}

- (void) deviceUpdate:(DeviceUpdate *)update packageSize:(NSNumber *)size {

    [self setPackageLimit:(unsigned)[size unsignedIntValue]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateNotificationPackageArea
                                                        object:self
                                                      userInfo:@{@"size":size}];

}

#pragma mark - Update state machine

- (bool) updatePackage:(NSData *)package atAddress:(unsigned)address {

    if ( self.packageStatus == kUpdateStatusReady ) { _packageTarget = address; }
    else return ( false );
    
    if ( [package length] ) { if ( package.length > self.packageLimit ) return ( false ); }
    else return ( false );
    
    [self setPackageOffset:0];
    [self setPackage:package];

    [self eraseFirmware];
    
    return ( true );
    
}

- (void) eraseFirmware {

    [self.update requestBlank];
    [self setPackageStatus:kUpdateStatusErase];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateNotificationPackageStart
                                                        object:self
                                                      userInfo:nil];

}

- (void) writeRecord {

    unsigned    offset      = (unsigned) self.packageOffset;
    unsigned    length      = (unsigned) self.package.length - offset;
    
    if ( length > UPDATE_PACKET_SIZE ) { length = UPDATE_PACKET_SIZE; }

    NSData *    payload     = [NSData dataWithBytes:self.package.bytes + offset length:length];
    NSNumber *  progress    = [NSNumber numberWithFloat:((float)(offset + length) / (float)(self.package.length))];

    if ( payload ) [self.update writeData:payload toAddress:self.packageTarget + offset];

    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateNotificationPackageProgress
                                                        object:self
                                                      userInfo:@{@"progress":progress}];

}

- (void) finishUpdate {

    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateNotificationPackageComplete
                                                        object:self
                                                      userInfo:nil];

}

- (void) failedUpdate {

    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateNotificationPackageFailure
                                                        object:self
                                                      userInfo:nil];

}

@end
