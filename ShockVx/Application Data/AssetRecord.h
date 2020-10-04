//
//  project: Shock Vx
//     file: AssetRecord.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

// The core data entity for assets

#define kAssetEntity                        @"Asset"

// Each asset is identified by its unique 64-bit identifier

#define kAssetRecordIdentifier              @"identifier"
#define kAssetRecordLocation                @"location"
#define kAssetRecordLabel                   @"label"

#define kAssetRecordAltitude                @"altitude"
#define kAssetRecordLatitude                @"latitude"
#define kAssetRecordLongitude               @"longitude"

#define kAssetRecordOpened                  @"opened"
#define kAssetRecordClosed                  @"closed"

@interface AssetRecord : NSManagedObject

+ (instancetype) context:(NSManagedObjectContext *)context assetWithIdentifier:(NSData *)identifier label:(NSString *)label;

@property (nonatomic, retain) NSData *      identifier;
@property (nonatomic, retain) NSString *    location;
@property (nonatomic, retain) NSString *    label;

@property (nonatomic, retain) NSNumber *    altitude;
@property (nonatomic, retain) NSNumber *    latitude;
@property (nonatomic, retain) NSNumber *    longitude;

@property (nonatomic, retain) NSDate *      opened;
@property (nonatomic, retain) NSDate *      closed;

- (bool) matchesIdentifier:(NSData *)identifier;

@end

