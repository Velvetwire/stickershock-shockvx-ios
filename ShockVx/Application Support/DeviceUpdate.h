//
//  project: Shock Vx
//     file: DeviceUpdate.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@protocol DeviceUpdateDelegate;

// Installed package status characteristic

#define kDeviceUpdateStatusPrefix       @"00005056"

typedef struct __attribute__ (( packed )) {

    unsigned char       major;          // Major revision index
    unsigned char       minor;          // Minor revision index
    unsigned short      build;          // Build number

} package_revision_t;

typedef union {
    
    unsigned            encoding;
    package_revision_t  revision;
    
} package_version_t;

typedef struct __attribute__ (( packed )) {
    
    unsigned            package;        // Package code
    package_version_t   version;        // Package version information

} update_status_t;

// Flash memory region map characteristic

#define kDeviceUpdateRegionPrefix       @"0000524D"

typedef struct __attribute__ (( packed )) {
    
    struct __attribute__ (( packed )) { // Flash memory area
        unsigned short  unit;           //  Page unit size in bytes
        unsigned short  size;           //  Total page count
    } area;

    struct __attribute__ (( packed )) { // Firmware code area
        unsigned short  page;           //  Starting page index
        unsigned short  size;           //  Page count
    } code;

    struct __attribute__ (( packed )) { // Storage data area
        unsigned short  page;           //  Starting page index
        unsigned short  size;           //  Page count
    } data;

    struct __attribute__ (( packed )) { // Reserve data area
        unsigned short  page;           //  Starting page index
        unsigned short  size;           //  Page count
    } user;

} update_region_t;

// Update record characteristic

#define kDeviceUpdateRecordPrefix       @"00005552"

#define kUpdateRequestReset             (unsigned) 0x504F5453   // Request shutdown notice ('STOP')
#define kUpdateRequestErase             (unsigned) 0x4F52455A   // Request setttings erase ('ZERO')
#define kUpdateRequestClear             (unsigned) 0x45504957   // Request storage erase ('WIPE')
#define kUpdateRequestBlank             (unsigned) 0x45455246   // Request firmware erase ('FREE')

#define kUpdateResponseEmpty            (unsigned) 0x454E4F4E   // Respond empty package ('NONE')
#define kUpdateResponsePackage          (unsigned) 0x45444F43   // Respond with package ('CODE')
#define kUpdateResponseAccepted         (unsigned) 0x454E4F44   // Respond accepted ('DONE')
#define kUpdateResponseRejected         (unsigned) 0x4C494146   // Respond rejected ('FAIL')

#define UPDATE_PACKET_SIZE              128

//
// Device update service
@interface DeviceUpdate : NSObject

+ (instancetype) updateService:(NSUUID *)service forPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate;

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic;
- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic;
- (void) confirmedCharacteristic:(CBCharacteristic *)characteristic;

// Package version information

@property (nonatomic, readonly) NSNumber *      packageCode;
@property (nonatomic, readonly) NSNumber *      versionMajor;
@property (nonatomic, readonly) NSNumber *      versionMinor;
@property (nonatomic, readonly) NSNumber *      versionBuild;

- (void) writeData:(NSData *)data toAddress:(unsigned)address;

- (void) requestReset;
- (void) requestErase;
- (void) requestClear;
- (void) requestBlank;

@end

//
// Device update delegate
@protocol DeviceUpdateDelegate <NSObject>

- (void) deviceUpdate:(DeviceUpdate *)update packageInstalled:(bool)installed;
- (void) deviceUpdate:(DeviceUpdate *)update requestCompleted:(bool)completed;

- (void) deviceUpdate:(DeviceUpdate *)update writtenChecksum:(NSNumber *)checksum;

- (void) deviceUpdate:(DeviceUpdate *)update packageCode:(NSNumber *)code;
- (void) deviceUpdate:(DeviceUpdate *)update packageSize:(NSNumber *)size;

@end
