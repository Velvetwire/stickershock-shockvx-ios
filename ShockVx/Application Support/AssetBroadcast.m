//
//  project: Shock Vx
//     file: AssetBroadcast.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AssetBroadcast.h"

@interface AssetBroadcast ( )

@property (nonatomic, strong)   NSData *    packet;

@end

@implementation AssetBroadcast

#pragma mark - Instantiation

+ (instancetype) broadcastFromData:(NSData *)data { return [[AssetBroadcast alloc] initWithData:data]; }

- (instancetype) initWithData:(NSData *)data {

    if ( (self = [super init]) ) { _packet = [self packetData:data]; }
    
    return ( self );
    
}

- (NSData *) packetData:(NSData *)data {

    broadcast_record_t *    record  = (broadcast_record_t *) [data bytes];

    if ( record ) for ( NSUInteger offset = 0; offset < data.length; offset += record->size + 1 ) {
    
        record                      = (broadcast_record_t *)(data.bytes + offset);
        void *              packet  = (record + 1);
        
        switch ( record->type ) {
                
            case BROADCAST_TYPE_NORMAL(BROADCAST_TYPE_IDENTITY):
            case BROADCAST_TYPE_SECURE(BROADCAST_TYPE_IDENTITY):
                [self decodeIdentity:(broadcast_identity_t *)packet length:record->size - 1];
                break;

            case BROADCAST_TYPE_NORMAL(BROADCAST_TYPE_TEMPERATURE):
            case BROADCAST_TYPE_SECURE(BROADCAST_TYPE_TEMPERATURE):
                [self decodeTemperature:(broadcast_temperature_t *)packet length:record->size - 1];
                break;

            case BROADCAST_TYPE_NORMAL(BROADCAST_TYPE_ATMOSPHERE):
            case BROADCAST_TYPE_SECURE(BROADCAST_TYPE_ATMOSPHERE):
                [self decodeAtmosphere:(broadcast_atmosphere_t *)packet length:record->size - 1];
                break;

            case BROADCAST_TYPE_NORMAL(BROADCAST_TYPE_HANDLING):
            case BROADCAST_TYPE_SECURE(BROADCAST_TYPE_HANDLING):
                [self decodeHandling:(broadcast_handling_t *)packet length:record->size - 1];
                break;

            case BROADCAST_TYPE_NORMAL(BROADCAST_TYPE_VARIANT):
            case BROADCAST_TYPE_SECURE(BROADCAST_TYPE_VARIANT):
                [self decodeVariant:(broadcast_variant_t *)packet length:record->size - 1];
                break;

        }
        
    }

    return [data copy];
    
}

- (void) decodeIdentity:(broadcast_identity_t *)packet length:(int)length {

    _identifier     = [AssetIdentifier identifierWithData:[NSData dataWithBytes:&(packet->identity) length:sizeof(hash_t)]];
    _battery        = [NSNumber numberWithChar:packet->battery];
    _horizon        = [NSNumber numberWithChar:packet->horizon];
    
}

- (void) decodeTemperature:(broadcast_temperature_t *)packet length:(int)length {
    
    _temperature    = [NSNumber numberWithFloat:((float)packet->measurement / (float)1e2)];
    
}

- (void) decodeAtmosphere:(broadcast_atmosphere_t *)packet length:(int)length {

    _airTemperature = [NSNumber numberWithFloat:((float)packet->temperature.measurement / (float)1e2)];
    _airHumidity    = [NSNumber numberWithFloat:((float)packet->humidity.measurement / (float)1e2)];
    _airPressure    = [NSNumber numberWithFloat:((float)packet->pressure.measurement / (float)1e3)];

}

- (void) decodeHandling:(broadcast_handling_t *)packet length:(int)length {
    
    _orientationFace    = [NSNumber numberWithChar:BROADCAST_HANLDING_FACE(packet->orientation)];
    _orientationAlarm   = (packet->orientation & BROADCAST_ORIENTATION_FACE) ? true : false;
    
    if ( packet->orientation & BROADCAST_ORIENTATION_ANGLE ) {

        _tiltAngle      = [NSNumber numberWithChar:packet->angle];
        _tiltAlarm      = (packet->orientation & BROADCAST_ORIENTATION_TILT) ? true : false;

    }
    
    _bumpAlarm          = (packet->orientation & BROADCAST_ORIENTATION_BUMP) ? true : false;
    _dropAlarm          = (packet->orientation & BROADCAST_ORIENTATION_DROP) ? true : false;
        
}

- (void) decodeVariant:(broadcast_variant_t *)packet length:(int)length {

    _variant            = packet->type;
    
}

@end
