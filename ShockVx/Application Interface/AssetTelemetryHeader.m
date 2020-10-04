//
//  project: ShockVx
//     file: AssetTelemetryHeader.m
//
//  Section header view which appears at the top of each
//  telemetry group.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AssetTelemetryHeader.h"

@interface AssetTelemetryHeader ( )

@property (nonatomic, weak) IBOutlet    UILabel *       headerLabel;

@end

@implementation AssetTelemetryHeader

- (void) setText:(NSString *)text {

    if ( (_text = text) ) [self.headerLabel setText:text];
    
}

- (void) drawRect:(CGRect)rect {

    CGContextRef    context = UIGraphicsGetCurrentContext( );
    
    CGContextSaveGState( context );
    CGContextSetAllowsAntialiasing( context, YES );

    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, rect.origin.y);

    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y + rect.size.height - 0.25);
    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - 0.25);
    
    CGContextSetStrokeColorWithColor( context, [self tintColor].CGColor );
    CGContextSetLineWidth( context, 0.25 );
    CGContextStrokePath( context );
    
    CGContextRestoreGState( context );

}

@end
