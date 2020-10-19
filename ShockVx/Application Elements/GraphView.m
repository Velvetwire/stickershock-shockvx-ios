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
- (void) setSelect:(NSNumber *)select { if ( (_select = select) ) [self setNeedsDisplay]; }

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
        
        [self drawTicks:rect context:context];
        [self drawLines:rect context:context];
        
        [self drawPoints:rect context:context];
        [self drawSelect:rect context:context];
    
    }

    CGContextRestoreGState( context );

}

- (void) drawTicks:(CGRect)rect context:(CGContextRef)context {

    CGFloat         minimum     = 0.0;
    CGFloat         maximum     = 0.0;

    for ( NSValue * value in self.points ) {
        
        CGPoint     point       = [value CGPointValue];

        if ( point.x < minimum ) { minimum = point.x; }
        if ( point.x > maximum ) { maximum = point.x; }
        
    }

    CGFloat         unit        = (15.0 * 60.0);
    CGPoint         tick        = CGPointMake( round( minimum / unit ), self.bounds.size.height / 2.0 );
    
    for ( CGFloat last = round( maximum / unit ); tick.x < last; tick.x += 1.0 ) {
    
        if ( ((int) tick.x) & 3 ) {
            CGContextMoveToPoint( context, ((tick.x * unit) * self.scale) + 5.0, tick.y - 5.0 );
            CGContextAddLineToPoint( context, ((tick.x * unit) * self.scale) + 5.0, tick.y + 5.0 );
        } else {
            CGContextMoveToPoint( context, ((tick.x * unit) * self.scale) + 5.0, tick.y - 10.0 );
            CGContextAddLineToPoint( context, ((tick.x * unit) * self.scale) + 5.0, tick.y + 10.0 );
        }
        
    }
    
    CGContextSetStrokeColorWithColor( context, [UIColor lightGrayColor].CGColor );
    CGContextSetLineWidth( context, 0.25 );
    CGContextStrokePath( context );

}

- (void) drawLines:(CGRect)rect context:(CGContextRef)context {

    CGFloat         offset      = self.bounds.size.height / 2.0;
    NSUInteger      count       = 0;

    for ( NSValue * value in self.points ) {
        
        CGPoint     point       = [value CGPointValue];

        if ( count ++ ) { CGContextAddLineToPoint( context, (point.x * self.scale) + 5.0, offset - (point.y * offset / self.range )); }
        else { CGContextMoveToPoint( context, (point.x * self.scale) + 5.0, offset - (point.y * offset / self.range )); }
            
    }

    CGContextSetStrokeColorWithColor( context, [self.tintColor colorWithAlphaComponent:0.50].CGColor );
    CGContextSetLineWidth( context, 2.5 );
    CGContextStrokePath( context );

}

- (void) drawPoints:(CGRect)rect context:(CGContextRef)context {

    CGFloat         offset      = self.bounds.size.height / 2.0;
    CGFloat         radius      = 2.5;

    for ( NSValue * value in self.points ) {
        
        CGPoint     point       = [value CGPointValue];
        CGRect      datum       = CGRectMake( - radius, - radius, 2.0 * radius, 2.0 * radius );

        CGContextAddEllipseInRect( context, CGRectOffset( datum, (point.x * self.scale) + 5.0, offset - (point.y * offset / self.range) ) );
            
    }
    
    CGContextSetLineWidth( context, 0.5 );
    CGContextSetFillColorWithColor( context, [UIColor whiteColor].CGColor );
    CGContextSetStrokeColorWithColor( context, self.tintColor.CGColor );
    CGContextDrawPath( context, kCGPathFillStroke );
    
}

- (void) drawSelect:(CGRect)rect context:(CGContextRef)context {

    CGFloat         offset      = self.bounds.size.height / 2.0;
    CGFloat         radius      = 2.5;

    if ( self.select && ([self.select integerValue] < [self.points count]) ) {

        NSValue *   value       = [self.points objectAtIndex:[self.select integerValue]];
        CGPoint     point       = [value CGPointValue];
        CGRect      datum       = CGRectMake( - radius, - radius, 2.0 * radius, 2.0 * radius );

        CGContextAddEllipseInRect( context, CGRectOffset( datum, (point.x * self.scale) + 5.0, offset - (point.y * offset / self.range) ) );

    }

    CGContextSetLineWidth( context, 0.5 );
    CGContextSetFillColorWithColor( context, [self.tintColor colorWithAlphaComponent:0.5].CGColor );
    CGContextSetStrokeColorWithColor( context, self.tintColor.CGColor );
    CGContextDrawPath( context, kCGPathFillStroke );

}

@end
