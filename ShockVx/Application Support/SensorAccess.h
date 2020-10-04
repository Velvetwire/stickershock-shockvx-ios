//
//  project: Shock Vx
//     file: SensorAccess.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define kSensorAccessServiceUUID        @"00004143-5657-5353-2020-56454C564554"

#define kSensorAccessTimeUUID           @"00005554-5657-5353-2020-56454C564554"
#define kSensorAccessControlUUID        @"00004357-5657-5353-2020-56454C564554"
#define kSensorAccessPasskeyUUID        @"0000504B-5657-5353-2020-56454C564554"

#define kAccessRequestShutdown          (unsigned) 0x504F5453                     // Request shutdown notice ('STOP')
#define kAccessRequestFactory           (unsigned) 0x4F52455A                     // Request factory erase ('ZERO')
#define kAccessRequestReboot            (unsigned) 0x544F4F42                     // Request reboot ('BOOT')
#define kAccessRequestLoader            (unsigned) 0x4D414F4C                     // Request boot loader ('LOAD')
#define kAccessRequestErase             (unsigned) 0x45504957                     // Request storage erase ('WIPE')

#define kAccessResponseAccepted         (unsigned) 0x454E4F44                     // Respond accepted ('DONE')
#define kAccessResponseRejected         (unsigned) 0x4C494146                     // Respond rejected ('FAIL')
#define kAccessResponseLocked           (unsigned) 0x4B434F4C                     // Respond access locked ('LOCK')
#define kAccessResponseOpened           (unsigned) 0x4E45504F                     // Respond access open ('OPEN')

@protocol SensorAccessDelegate;

@interface SensorAccess : NSObject

+ (CBUUID *) serviceIdentifier;
+ (instancetype) serviceForPeripheral:(CBPeripheral *)peripheral delegate:(id)delegate;

- (void) discoveredCharacteristic:(CBCharacteristic *)characteristic;
- (void) retrievedCharacteristic:(CBCharacteristic *)characteristic;
- (void) confirmedCharacteristic:(CBCharacteristic *)characteristic;

- (void) useAccessKey:(NSData *)key;

- (void) requestLoader;
- (void) requestReboot;
- (void) requestErase;

@end

typedef NS_ENUM( NSUInteger, AccessResponse ) {

    kAccessResponseSuccess,
    kAccessResponseFailure,
    
};

typedef NS_ENUM( NSUInteger, AccessStatus ) {

    kAccessStatusOpened,
    kAccessStatusLocked,
    
};

@protocol SensorAccessDelegate <NSObject>

- (void) accessReponse:(AccessResponse)response;
- (void) accessStatus:(AccessStatus)status;

@end

