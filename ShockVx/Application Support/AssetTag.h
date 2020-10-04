//
//  project: Shock Vx
//     file: SensorTag.h
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <CoreNFC/CoreNFC.h>
#import "AssetIdentifier.h"

//
// Declare a data interaction protocol handler
@protocol AssetTagDelegate;

//
// Define the tag scan interface
@interface AssetTag : NSObject <NFCNDEFReaderSessionDelegate, NSXMLParserDelegate>

- (id) initWithDelegate:(id)delegate;

@property (nonatomic, strong)   AssetIdentifier *   assetUnit;
@property (nonatomic, strong)   AssetIdentifier *   assetNode;

@property (nonatomic, strong)   NSUUID *            controlService;
@property (nonatomic, strong)   NSUUID *            primaryService;

- (void) scanWithPrompt:(NSString *)prompt;

@end

//
// Define the data interaction protocol
@protocol AssetTagDelegate <NSObject>

- (void) tag:(AssetTag *)tag unit:(NSData *)unit;
- (void) tag:(AssetTag *)tag error:(NSError *)error;

@end
