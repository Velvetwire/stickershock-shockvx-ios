//
//  project: Shock Vx
//     file: AssetPackage.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPackageMagic       0x50465353          // Magic signature code for package

typedef struct __attribute__ (( packed )) {

    unsigned                magic;              // Magic code for package
    unsigned                width;              // Width of header (in bytes)

    unsigned                address;            // Target address of package image
    unsigned short          pages;              // Number of pages in package
    unsigned short          bytes;              // Number of bytes per page
    
} package_header_t;

typedef struct __attribute__ (( packed )) {
    
    unsigned                stack;
    unsigned                reset;
    
} package_vectors_t;

typedef struct __attribute__ (( packed )) {
    
    unsigned                code;               // 32-bit package code

    union {
        
        unsigned            code;               // Revision code
        
        struct __attribute__ (( packed )) {
            unsigned char   major;              // Major revision index
            unsigned char   minor;              // Minor revision index
            unsigned short  build;              // Build number index
        } version;
        
    } revision;
    
    unsigned short          check;              // Image checksum
    unsigned short          pages;              // Image pages

} package_signature_t;

@interface AssetPackage : NSObject

+ (instancetype) packageWithData:(NSData *)data;

@property (nonatomic, readonly) NSData *        data;
@property (nonatomic, readonly) unsigned        address;
@property (nonatomic, readonly) unsigned short  checksum;

@property (nonatomic, readonly) NSNumber *      majorVersion;
@property (nonatomic, readonly) NSNumber *      minorVersion;
@property (nonatomic, readonly) NSNumber *      buildNumber;

@end
