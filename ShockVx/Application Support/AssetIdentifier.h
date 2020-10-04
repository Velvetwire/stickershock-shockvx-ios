//
//  project: Shock Vx
//     file: AssetIdentifier.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// The asset identifier is associated with the Bluetooth SiG information UUID
#define kAssetIdentifierUUID        @"180A"

//
// The asset ID consists of four parts across 8 bytes.
#define kAssetIdentifierParts       4
#define kAssetIdentifierSize        8

//
// Define the identifier interface
@interface AssetIdentifier : NSObject

+ (instancetype) identifierWithData:(NSData *)data;
+ (instancetype) identifierWithString:(NSString *)string;

- (bool) matchesIdentifier:(AssetIdentifier *)identifier;

- (NSString *) identifierString;
- (NSData *) identifierData;

@end
