//
//  project: Shock Vx
//     file: UpdateDevice.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AssetDevice.h"
#import "AssetBroadcast.h"

// Device update and settings service.

#import "DeviceUpdate.h"

#define kUpdateNotificationPackageArea              @"updatePackageArea"
#define kUpdateNotificationPackageData              @"updatePackageData"
#define kUpdateNotificationPackageStart             @"updatePackageStart"
#define kUpdateNotificationPackageProgress          @"updatePackageProgress"
#define kUpdateNotificationPackageComplete          @"updatePackageComplete"
#define kUpdateNotificationPackageFailure           @"updatePackageFailure"

typedef NS_ENUM( NSInteger, UpdateStatus ) {

    kUpdateStatusBegin,                             // Begin update process (not ready)
    kUpdateStatusReady,                             // Ready to start update
    kUpdateStatusErase,                             // Erasing the region
    kUpdateStatusWrite,                             // Writing the region
    kUpdateStatusFailure,                           // Failure received
    kUpdateStatusSuccess,                           // Update complete
    
};

//
// Update device reference object
@interface UpdateDevice : AssetDevice <DeviceUpdateDelegate>

+ (instancetype) updateWithUnit:(AssetIdentifier *)unit node:(AssetIdentifier *)node controlService:(NSUUID *)control primaryService:(NSUUID *)primary;

// Device update service

@property (nonatomic, strong)   DeviceUpdate *     update;

- (bool) updatePackage:(NSData *)package atAddress:(unsigned)address;

@end
