//
//  project: Shock Vx
//     file: DeviceAccess.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

// Service UTC time code characteristic

#define kDeviceAccessTimePrefix         @"00005554"

// Service control request and response characteristic

#define kDeviceAccessControlPrefix      @"00004357"

#define kAccessRequestShutdown          (unsigned) 0x504F5453   // Request shutdown notice ('STOP')
#define kAccessRequestFactory           (unsigned) 0x4F52455A   // Request factory erase ('ZERO')
#define kAccessRequestReboot            (unsigned) 0x544F4F42   // Request reboot ('BOOT')
#define kAccessRequestLoader            (unsigned) 0x4D414F4C   // Request boot loader ('LOAD')
#define kAccessRequestErase             (unsigned) 0x45504957   // Request storage erase ('WIPE')

#define kAccessResponseAccepted         (unsigned) 0x454E4F44   // Respond accepted ('DONE')
#define kAccessResponseRejected         (unsigned) 0x4C494146   // Respond rejected ('FAIL')
#define kAccessResponseLocked           (unsigned) 0x4B434F4C   // Respond access locked ('LOCK')
#define kAccessResponseOpened           (unsigned) 0x4E45504F   // Respond access open ('OPEN')

// Service access key characteristic

#define kDeviceAccessPasskeyPrefix      @"0000504B"

//
// Device access control service
@interface DeviceAccess : NSObject

+ (instancetype) accessService:(NSUUID *)service forPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate;

// Service characteristics

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic;
- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic;
- (void) confirmedCharacteristic:(CBCharacteristic *)characteristic;

// Access security

- (void) useAccessKey:(NSData *)key;

// Access requests

- (void) requestLoader;
- (void) requestReboot;
- (void) requestErase;

@end

// Access response from the device
typedef NS_ENUM( NSUInteger, AccessResponse ) {
    kAccessResponseSuccess,
    kAccessResponseFailure,
};

// Status response from the device
typedef NS_ENUM( NSUInteger, AccessStatus ) {
    kAccessStatusOpened,
    kAccessStatusLocked,
};

//
// Device access control delegate
@protocol DeviceAccessDelegate <NSObject>

- (void) accessReponse:(AccessResponse)response;
- (void) accessStatus:(AccessStatus)status;

@end

