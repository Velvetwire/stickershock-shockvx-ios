//
//  project: Shock Vx
//     file: AssetIdentifier.m
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AssetIdentifier.h"

//
// Asset identifier instance
//

@interface AssetIdentifier( )

@property (nonatomic, strong)   NSData *  identifier;

@end

//
// Asset identifier implementation
//

@implementation AssetIdentifier

//
// Construct an 64-bit identifier from data.
+ (instancetype) identifierWithData:(NSData *)data {

    AssetIdentifier *       identifier  = [[AssetIdentifier alloc] init];

    if ( data.length == kAssetIdentifierSize ) [identifier setIdentifier:[NSData dataWithData:data]];
    else return nil;
    
    return ( identifier );
    
}

//
// Construct an 64-bit identifier from a string.
+ (instancetype) identifierWithString:(NSString *)string {
    
    AssetIdentifier *       identifier  = [[AssetIdentifier alloc] init];
    NSScanner *             scanner     = [NSScanner scannerWithString:string];
    NSMutableArray *        parts       = [[NSMutableArray alloc] init];
    
    if ( string && scanner ) {
        
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"-:."]];
        
        for ( unsigned value = 0; [scanner scanHexInt:&(value)]; ) [parts addObject:[NSNumber numberWithUnsignedInt:value]];
        
    } else return nil;
    
    if ( parts.count == kAssetIdentifierParts ) {
        
        unsigned short  identity[ kAssetIdentifierParts ] = {
            [(NSNumber *)[parts objectAtIndex:3] unsignedShortValue],
            [(NSNumber *)[parts objectAtIndex:2] unsignedShortValue],
            [(NSNumber *)[parts objectAtIndex:1] unsignedShortValue],
            [(NSNumber *)[parts objectAtIndex:0] unsignedShortValue] };
        
        [identifier setIdentifier:[NSData dataWithBytes:identity length:kAssetIdentifierSize]];
        
    } else return nil;
    
    return ( identifier );
    
}

//
// Check for a match
- (bool) matchesIdentifier:(AssetIdentifier *)identifier { return [[identifier identifierData] isEqual:self.identifier]; }

//
// Generate an identifier string from the 64-bit data
- (NSString *) identifierString {
    
    unsigned short          parts[ kAssetIdentifierParts ];
    
    if ( self.identifier.length == kAssetIdentifierSize ) [self.identifier getBytes:parts range:NSMakeRange(0,kAssetIdentifierSize)];
    else return nil;
    
    return [NSString stringWithFormat:@"%04X-%04X-%04X-%04X", (unsigned short) parts[ 3 ], (unsigned short) parts[ 2 ], (unsigned short) parts[ 1 ], (unsigned short) parts[ 0 ]];
    
}

//
// Get back the 64-bit identifier data
- (NSData *) identifierData { return ( self.identifier ); }

@end


