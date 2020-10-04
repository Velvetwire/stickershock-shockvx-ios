//
//  project: Shock Vx
//     file: AssetRegistry.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface AssetRegistry : NSObject

+ (instancetype) registryForContext:(NSManagedObjectContext *)context;

@property (nonatomic, readonly)     NSUInteger      assetCount;
@property (nonatomic, readonly)     NSArray *       assetList;

- (NSDictionary *) assetAtIndex:(NSUInteger)index;
- (NSDictionary *) assetForIdentifier:(NSData *)identifier;
- (NSUInteger) indexOfAssetWithIdentifier:(NSData *)identifier;

- (bool) assetWithIdentifier:(NSData *)identifier label:(NSString *)label;
- (bool) removeAssetWithIdentifier:(NSData *)identifier;

- (bool) setLabel:(NSString *)label andLocation:(NSString *)location forAssetWithIdentifier:(NSData *)identifier;
- (bool) setOpened:(NSDate *)opened andClosed:(NSDate *)closed forAssetWithIdentifier:(NSData *)identifier;

@end
