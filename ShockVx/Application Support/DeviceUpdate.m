//
//  project: Shock Vx
//     file: DeviceUpdate.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "DeviceUpdate.h"

@interface DeviceUpdate ( )

@property (nonatomic, weak)     CBPeripheral *                  peripheral;
@property (nonatomic, weak)     id <DeviceUpdateDelegate>       delegate;
@property (nonatomic, strong)   NSUUID *                        service;

@property (nonatomic, strong)   CBCharacteristic *              statusCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              regionCharacteristic;
@property (nonatomic, strong)   CBCharacteristic *              recordCharacteristic;

@property (nonatomic)           unsigned                        regionStart;
@property (nonatomic)           unsigned                        regionLimit;

@end

@implementation DeviceUpdate

#pragma mark - Service instantiation

+ (instancetype) updateService:(NSUUID *)service forPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate { return [[DeviceUpdate alloc] initService:service forPeripheral:peripheral delegate:delegate]; }

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

    if ( [characteristic.UUID isEqual:[self identifierWithPrefix:kDeviceUpdateStatusPrefix]] ) { [self setStatusCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[self identifierWithPrefix:kDeviceUpdateRegionPrefix]] ) { [self setRegionCharacteristic:characteristic]; }
    if ( [characteristic.UUID isEqual:[self identifierWithPrefix:kDeviceUpdateRecordPrefix]] ) { [self setRecordCharacteristic:characteristic]; }
    
}

- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic {

    if ( [characteristic.UUID isEqual:self.statusCharacteristic.UUID] ) {
        
        const update_status_t * status  = [characteristic.value bytes];
        
        if ( status->package != ((unsigned)-1) ) { _packageCode = [NSNumber numberWithUnsignedInt:status->package]; }
        if ( status->version.encoding != ((unsigned short)-1) ) {
            
            _versionMajor   = [NSNumber numberWithUnsignedInt:status->version.revision.major];
            _versionMinor   = [NSNumber numberWithUnsignedInt:status->version.revision.minor];
            _versionBuild   = [NSNumber numberWithUnsignedInt:status->version.revision.build];

        }
        
        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{
            [self.delegate deviceUpdate:self packageCode:self.packageCode];
        });
        
    }
    
    if ( [characteristic.UUID isEqual:self.regionCharacteristic.UUID] ) {

        const update_region_t * region  = [characteristic.value bytes];
        unsigned                offset  = region->code.page * region->area.unit;
        unsigned                length  = region->code.size * region->area.unit;

        [self setRegionStart:offset];
        [self setRegionStart:offset + length];

        if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{
            [self.delegate deviceUpdate:self packageSize:[NSNumber numberWithUnsignedInt:length]];
        });
        
    }

    if ( [characteristic.UUID isEqual:self.recordCharacteristic.UUID] ) {
        
        const unsigned      response    = *(unsigned *) [characteristic.value bytes];

        if ( response < 0x10000 ) {
        
            if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate deviceUpdate:self writtenChecksum:[NSNumber numberWithUnsignedInt:response]]; });
            
        } else switch ( response ) {
        
            case kUpdateResponseEmpty:
                if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate deviceUpdate:self packageInstalled:NO]; });
                break;
            
            case kUpdateResponsePackage:
                if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate deviceUpdate:self packageInstalled:YES]; });
                break;
            
            case kUpdateResponseAccepted:
                if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate deviceUpdate:self requestCompleted:YES]; });
                break;
            
            case kUpdateResponseRejected:
                if ( self.delegate ) dispatch_async( dispatch_get_main_queue(), ^{ [self.delegate deviceUpdate:self requestCompleted:NO]; });
                break;
                
            default: NSLog ( @"Unhandled response %08x", response ); break;
        
        }
        
    }

}

- (void) confirmedCharacteristic:(CBCharacteristic *)characteristic {

}

#pragma mark - Update requests

- (void) writeData:(NSData *)data toAddress:(unsigned)address {

    NSMutableData *     record  = [NSMutableData dataWithBytes:&(address) length:sizeof(unsigned)];

    if ( data ) [record appendData:data];
    
    [self.peripheral writeValue:record
              forCharacteristic:self.recordCharacteristic
                           type:CBCharacteristicWriteWithResponse];

}

- (void) requestReset { [self updateRequest:kUpdateRequestReset]; }
- (void) requestErase { [self updateRequest:kUpdateRequestErase]; }
- (void) requestClear { [self updateRequest:kUpdateRequestClear]; }
- (void) requestBlank { [self updateRequest:kUpdateRequestBlank]; }

- (void) updateRequest:(unsigned)request {

    [self.peripheral writeValue:[NSData dataWithBytes:&(request) length:sizeof(unsigned)]
              forCharacteristic:self.recordCharacteristic
                           type:CBCharacteristicWriteWithResponse];

}

@end
