//
//  project: ShockVx
//     file: GraphView.m
//
//  Linear graph plot.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView

- (instancetype) initWithFrame:(CGRect)frame {
    
    if ( (self = [super initWithFrame:frame]) ) {
    
        _scale  = 1.0;
        _range  = 1.0;
    
    } else return ( self );
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    return ( self );
    
}

- (void) setPoints:(NSArray *)points { if ( (_points = points) ) [self setNeedsDisplay]; }

- (void) setScale:(float)scale {

    if ( (_scale = scale) < 0.0 ) { _scale = 0.0; }
    
    [self setNeedsDisplay];

}

- (void) setRange:(float)range {

    if ( (_range = range) < 0.0 ) { _range = 0.0; }
    
    [self setNeedsDisplay];
    
}

- (void) drawRect:(CGRect)rect {

    CGContextRef    context     = UIGraphicsGetCurrentContext( );
    
    CGContextSaveGState( context );
    CGContextSetAllowsAntialiasing( context, YES );

    if ( self.range ) {
        
        [self drawLines:rect context:context];
        [self drawPoints:rect context:context];
        
    }

    CGContextRestoreGState( context );

}

- (void) drawLines:(CGRect)rect context:(CGContextRef)context {

    CGFloat         offset      = self.bounds.size.height / 2;
    NSUInteger      count       = 0;

    for ( NSValue * value in self.points ) {
        
        CGPoint     point       = [value CGPointValue];

        if ( count ++ ) { CGContextAddLineToPoint( context, point.x * self.scale, offset - (point.y * offset / self.range ));}
        else { CGContextMoveToPoint( context, point.x * self.scale, offset - (point.y * offset / self.range )); }
            
    }

    CGContextSetStrokeColorWithColor( context, self.tintColor.CGColor );
    CGContextSetLineWidth( context, 0.5 );
    CGContextStrokePath( context );

}

- (void) drawPoints:(CGRect)rect context:(CGContextRef)context {

    CGFloat         offset      = self.bounds.size.height / 2;
    CGFloat         radius      = 2.5;

    for ( NSValue * value in self.points ) {
        
        CGPoint     point       = [value CGPointValue];
        CGRect      datum       = CGRectMake( -radius, -radius, 2 * radius, 2 * radius );

        CGContextAddEllipseInRect( context, CGRectOffset( datum, point.x * self.scale, offset - (point.y * offset / self.range) ) );
            
    }
    
    CGContextSetFillColorWithColor( context, [UIColor whiteColor].CGColor );
    CGContextSetStrokeColorWithColor( context, self.tintColor.CGColor );
    CGContextSetLineWidth( context, 0.5 );
    CGContextDrawPath( context, kCGPathFillStroke );
    
}
    
@end
