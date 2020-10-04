//
//  project: Shock Vx
//     file: AssetRecord.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AssetRecord.h"

//
// Asset record implementation
//

@implementation AssetRecord

//
// Instantiate a new sensor record for the asset with the given identifier and label
+ (instancetype) context:(NSManagedObjectContext *)context assetWithIdentifier:(NSData *)identifier label:(NSString *)label {

    AssetRecord *       record  = [NSEntityDescription insertNewObjectForEntityForName:kAssetEntity inManagedObjectContext:context];
    NSError *           error   = nil;

    if ( record ) {
    
        record.identifier       = [identifier copy];
        record.label            = [label copy];
        
        [context save:&(error)];

    } else return nil;
    
    return ( error ? nil : record );
    
}

//
// Check if the sensor matches the given identifier code
- (bool) matchesIdentifier:(NSData *)identifier { return [self.identifier isEqual:identifier]; }

//
// Record elements
//

@dynamic identifier;
@dynamic location;
@dynamic label;

@dynamic altitude;
@dynamic latitude;
@dynamic longitude;

@dynamic opened;
@dynamic closed;

@end
