//
//  project: Shock Vx
//     file: AssetPackage.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AssetPackage.h"

//
// Asset package instance
//

@interface AssetPackage( )

@property (nonatomic, strong)   NSData *  payload;

@end

//
// Asset package interface
//

@implementation AssetPackage

//
// Construct a package from a given data payload.
+ (instancetype) packageWithData:(NSData *)data { return [[AssetPackage alloc] initWithData:data]; }

//
// Initalize the package payload with data.
- (instancetype) initWithData:(NSData *)data {

    if ( (self = [super init]) ) { [self initPayload:(_payload = data)]; }
    
    return ( self );
    
}

- (void) initPayload:(NSData *)data {

    package_header_t *          package     = (package_header_t *) [data bytes];

    if ( package->magic == kPackageMagic ) {

        package_vectors_t *     vectors     = (void *) [data bytes] + package->width;
        unsigned                length      = (unsigned) data.length  - package->width;
        unsigned                offset      = (vectors->reset & ~(1)) - package->address - sizeof(package_signature_t);
        package_signature_t *   signature   = (void *) [data bytes] + package->width + offset;

        if ( signature->revision.code != ((unsigned)-1) ) {
        
            _majorVersion                   = [NSNumber numberWithUnsignedChar:signature->revision.version.major];
            _minorVersion                   = [NSNumber numberWithUnsignedChar:signature->revision.version.minor];
            _buildNumber                    = [NSNumber numberWithUnsignedShort:signature->revision.version.build];

        }

        _data                               = [NSData dataWithBytes:vectors length:length];
        _address                            = package->address;
        _checksum                           = signature->check;
        
        NSLog ( @"Package checksum %04x", self.checksum );
        
    }
    
}

@end
