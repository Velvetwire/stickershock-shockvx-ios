//
//  project: Shock Vx
//     file: AssetRegistry.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AssetRegistry.h"
#import "AssetRecord.h"

//
// Asset registry instance
//

@interface AssetRegistry ( )

@property (nonatomic, weak)     NSManagedObjectContext *    context;
@property (atomic, strong)      NSMutableArray *            records;

@end

//
// Asset registry implementation
//

@implementation AssetRegistry

#pragma mark - Instantiation

//
// Instantiate the registry with the core data context
+ (instancetype) registryForContext:(NSManagedObjectContext *)context { return [[AssetRegistry alloc] initWithContext:context]; }

//
// Initialize the registry with the core data context
- (id) initWithContext:(NSManagedObjectContext *)context {
    
    if ( (self = [super init]) ) {
        
        _context                            = context;

        NSFetchRequest *    fetchRequest    = [[NSFetchRequest alloc] initWithEntityName:kAssetEntity];
        _records                            = [[self.context executeFetchRequest:fetchRequest error:nil] mutableCopy];
        
    }
    
    return ( self );
    
}

//
// Return the count of records in the asset registry.
- (NSUInteger) assetCount { return ( self.records.count ); }

- (NSArray *) assetList {

    NSMutableArray *    assets = [[NSMutableArray alloc] init];
    
    for ( AssetRecord * record in self.records ) {
        [assets addObject:record.identifier];
    }
    
    return ( assets );
}

- (NSDictionary *) assetAtIndex:(NSUInteger)index {

    AssetRecord *           record  = (index < self.records.count) ? [self.records objectAtIndex:index] : nil;
    NSMutableDictionary *   asset   = [[NSMutableDictionary alloc] init];

    if ( record ) {
        
        if ( record.identifier) [asset setObject:record.identifier forKey:kAssetRecordIdentifier];
        if ( record.location ) [asset setObject:record.location forKey:kAssetRecordLocation];
        if ( record.label ) [asset setObject:record.label forKey:kAssetRecordLabel];

        if ( record.opened ) [asset setObject:record.opened forKey:kAssetRecordOpened];
        if ( record.closed ) [asset setObject:record.closed forKey:kAssetRecordClosed];

    } else return nil;

    return ( asset );

}

- (NSDictionary *) assetForIdentifier:(NSData *)identifier {

    AssetRecord *           record  = [self recordForIdentifier:identifier];
    NSMutableDictionary *   asset   = [[NSMutableDictionary alloc] init];
    
    if ( record ) {
        
        if ( record.identifier) [asset setObject:record.identifier forKey:kAssetRecordIdentifier];
        if ( record.location ) [asset setObject:record.location forKey:kAssetRecordLocation];
        if ( record.label ) [asset setObject:record.label forKey:kAssetRecordLabel];

        if ( record.opened ) [asset setObject:record.opened forKey:kAssetRecordOpened];
        if ( record.closed ) [asset setObject:record.closed forKey:kAssetRecordClosed];

    } else return nil;

    return ( asset );
    
}

- (NSUInteger) indexOfAssetWithIdentifier:(NSData *)identifier {

    return [self indexOfIdentifier:identifier];
    
}

- (bool) assetWithIdentifier:(NSData *)identifier label:(NSString *)label {

    AssetRecord *           record  = [self recordForIdentifier:identifier];
    NSError *               error   = nil;

    if ( record ) { [record setLabel:label]; }
    else if ( (record = [AssetRecord context:self.context assetWithIdentifier:identifier label:label]) ) { [self.records insertObject:record atIndex:0]; }
    else return ( false );

    [self.context save:&(error)];

    return ( error ? false : true );

}

- (bool) removeAssetWithIdentifier:(NSData *)identifier {

    AssetRecord *           record  = [self recordForIdentifier:identifier];
    NSError *               error   = nil;

    if ( record ) {
    
        [self.records removeObject:record];
        [self.context deleteObject:record];
    
    } else return ( false );

    [self.context save:&(error)];
    
    return ( error ? false : true );

}

#pragma mark - Record modification

- (bool) setLabel:(NSString *)label andLocation:(NSString *)location forAssetWithIdentifier:(NSData *)identifier {

    AssetRecord *           record  = [self recordForIdentifier:identifier];
    NSError *               error   = nil;

    if ( record ) {
    
        [record setLabel:[label copy]];
        [record setLocation:[location copy]];
        
        [self.context save:&(error)];
        
    } else return ( false );
    
    return ( error ? false : true );

}

- (bool) setOpened:(NSDate *)opened andClosed:(NSDate *)closed forAssetWithIdentifier:(NSData *)identifier {

    AssetRecord *           record  = [self recordForIdentifier:identifier];
    NSError *               error   = nil;

    if ( record ) {
    
        [record setOpened:[opened copy]];
        [record setClosed:[closed copy]];
        
        [self.context save:&(error)];
        
    } else return ( false );
    
    return ( error ? false : true );
    
}

#pragma mark - Record lookup

- (AssetRecord *) recordForIdentifier:(NSData *)identifier {

    for ( AssetRecord * record in self.records )
        if ( [record matchesIdentifier:identifier] )
            return ( record );
    
    return nil;
    
}

- (NSUInteger) indexOfIdentifier:(NSData *)identifier {

    for ( NSUInteger index = 0; index < self.records.count; ++ index )
        if ( [(AssetRecord *)[self.records objectAtIndex:index] matchesIdentifier:identifier] )
            return ( index );

    return ( NSNotFound );
    
}

@end
