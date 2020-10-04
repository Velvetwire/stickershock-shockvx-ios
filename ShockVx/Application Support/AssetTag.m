//
//  project: Shock Vx
//     file: AssetTag.m
//
//  Copyright © 2020 Velvetwire LLC. All rights reserved.
//

#import "AssetTag.h"

//
// Sensor tag scan instance
//

@interface AssetTag( )

@property (nonatomic, weak)     id <AssetTagDelegate>       delegate;

@property (nonatomic, strong)   NFCNDEFReaderSession *      session;
@property (nonatomic, strong)   NSString *                  element;

@end

//
// Sensor tag scan implementation
//

@implementation AssetTag

- (id) initWithDelegate:(id)delegate {
    
    // Construct an NFC reader session to scan a type-A NFC tag.
    
    if ( (self = [super init]) ) {
        
        _delegate   = delegate;
        _session    = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:nil invalidateAfterFirstRead:YES];
        
    }
    
    // Return with instance.
    
    return ( self );
    
}

#pragma mark - NFC Reader Session

- (void) scanWithPrompt:(NSString *)prompt {
    
    // Set the description and begin the reader session.
    
    [self.session setAlertMessage:prompt];
    [self.session beginSession];
    
}

- (void) readerSessionDidBecomeActive:(NFCNDEFReaderSession *)session {

    NSLog ( @"Scan session active." );
    
}

- (void) readerSession:(nonnull NFCNDEFReaderSession *)session didDetectNDEFs:(nonnull NSArray<NFCNDEFMessage *> *)messages {
    
    for ( NFCNDEFMessage * message in messages ) {

        for ( NFCNDEFPayload * payload in message.records ) if ( payload.typeNameFormat == NFCTypeNameFormatMedia )
            [self readerSession:session mediaType:[[NSString alloc] initWithData:payload.type encoding:NSUTF8StringEncoding] media:payload.payload];

    }
    
}

//
// If the media type is recognized as XML, parse the XML to retrieve the device unit number,
// the device network node, and the primary and control service UUIDs.
- (void) readerSession:(nonnull NFCNDEFReaderSession *)session mediaType:(NSString *)type media:(NSData *)media {
    
    if ( type && ([type caseInsensitiveCompare:@"text/xml"] == NSOrderedSame || [type caseInsensitiveCompare:@"application/xml"] == NSOrderedSame) ) {
        
        NSXMLParser *   parser = [[NSXMLParser alloc] initWithData:media];
        
        [parser setDelegate:self];
        [parser parse];
        
    }
    
}

- (void) readerSession:(nonnull NFCNDEFReaderSession *)session didInvalidateWithError:(nonnull NSError *)error {
    
    if ( error ) switch ( error.code ) {
            
        case 200:   [self readerSessionCancelled:session]; break;
        case 204:   [self readerSessionConcluded:session]; break;
            
        default:    if ( self.delegate && [self.delegate respondsToSelector:@selector(tag:error:)] )
            [self.delegate tag:self error:error];
            break;
            
    }
    
}

- (void) readerSessionConcluded:(nonnull NFCNDEFReaderSession *)session {
    
    if ( self.delegate && [self.delegate respondsToSelector:@selector(tag:unit:)] )
        [self.delegate tag:self unit:[self.assetUnit identifierData]];
    
}

- (void) readerSessionCancelled:(nonnull NFCNDEFReaderSession *)session {
    
    if ( self.delegate && [self.delegate respondsToSelector:@selector(tag:error:)] )
        [self.delegate tag:self unit:nil];
    
}

#pragma mark - XML Document Parsing

//
// Document parsing has started so reset the tag elements.
- (void) parserDidStartDocument:(NSXMLParser *)parser {
    
    // Initialize the element path to empty.
    
    [self setElement:[[NSMutableString alloc] init]];
    
    // Reset the document elements to be filled in during the document scan.
    
    [self setAssetUnit:nil];
    [self setAssetNode:nil];
    
    [self setPrimaryService:nil];
    [self setControlService:nil];
    
}

//
// Document parsing has concluded.
- (void) parserDidEndDocument:(NSXMLParser *)parser {
    
    // Discard the element path after parsing the XML document.
    
    [self setElement:nil];
    
}

//
// Element parsing started so append the element node to the current path.
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)element namespaceURI:(NSString *)uri qualifiedName:(NSString *)name attributes:(NSDictionary *)attributes {
    
    // Append the opened element to end of the element path.
    
    [self setElement:[self.element stringByAppendingPathComponent:element]];
    
}

//
// Element parsing has concluded so remove the element node from the current path.
- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)element namespaceURI:(NSString *)uri qualifiedName:(NSString *)name {
    
    // Remove the closed element from the end of the element path.
    
    [self setElement:[self.element stringByDeletingLastPathComponent]];
    
}

//
// Process the element value and update recognized members.
- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    // Retrieve the sensor unit and node numbers.
    
    if ( self.element && [self.element caseInsensitiveCompare:@"tag/device/unit"] == NSOrderedSame ) {
        [self setAssetUnit:[AssetIdentifier identifierWithString:string]];
    }

    if ( self.element && [self.element caseInsensitiveCompare:@"tag/device/node"] == NSOrderedSame ) {
        [self setAssetNode:[AssetIdentifier identifierWithString:string]];
    }
         
    // Retreive the primary and control service UUIDs from the document.
    
    if ( self.element && [self.element caseInsensitiveCompare:@"tag/service/primary"] == NSOrderedSame ) {
        [self setPrimaryService:[[NSUUID alloc] initWithUUIDString:string]];
    }

    if ( self.element && [self.element caseInsensitiveCompare:@"tag/service/control"] == NSOrderedSame ) {
        [self setControlService:[[NSUUID alloc] initWithUUIDString:string]];
    }
    
}

@end
