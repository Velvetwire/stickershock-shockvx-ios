//
//  project: ShockVx
//     file: GraphControl.m
//
//  Linear graph visualization control.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "GraphControl.h"
#import "GraphView.h"

@interface GraphControl( )

@property (nonatomic, strong)   UIScrollView *          scrollView;
@property (nonatomic, strong)   NSMutableDictionary *   graphViews;
@property (nonatomic)           float                   origin;
@property (nonatomic)           float                   extent;

@end

@implementation GraphControl

- (instancetype) initWithCoder:(NSCoder *)coder {
    
    if ( (self = [super initWithCoder:coder]) ) { [self initWithScale:1.0 range:1.0 bias:0.0]; }
    
    return ( self );
    
}

- (instancetype) initWithFrame:(CGRect)frame {
    
    if ( (self = [super initWithFrame:frame]) ) { [self initWithScale:1.0 range:1.0 bias:0.0]; }
    
    return ( self );
    
}

- (void) initWithScale:(float)scale range:(float)range bias:(float)bias {

    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectInset( self.bounds, 1.0, 0.0 )];
    _graphViews = [[NSMutableDictionary alloc] init];

    _scale      = scale;
    _range      = range;
    _bias       = bias;
    
    if ( self.scrollView ) {
        
        [self.scrollView setScrollEnabled:YES];
        [self.scrollView setShowsVerticalScrollIndicator:NO];
        [self.scrollView setShowsHorizontalScrollIndicator:NO];

        [self addSubview:self.scrollView];
        
    }

}

- (void) setScale:(float)scale {

    if ( (_scale = scale) < 0 ) { _scale = 0.0; }
    for ( GraphView * graph in [self.graphViews allValues] ) [graph setScale:scale];

}

- (void) setRange:(float)range {

    if ( (_range = range) < 0 ) { _range = 0.0; }
    for ( GraphView * graph in [self.graphViews allValues] ) [graph setRange:range];
    
}

- (void) setBias:(float)bias { _bias = bias; [self setNeedsDisplay]; }

- (void) addPlot:(NSString *)label color:(UIColor *)color {

    GraphView *     graphView   = [[GraphView alloc] initWithFrame:self.scrollView.frame];
    
    [graphView setScale:self.scale];
    [graphView setRange:self.range];
    
    [self.graphViews setObject:graphView forKey:label];
    [self.scrollView addSubview:graphView];
    
}

- (void) setPlot:(NSString *)label points:(NSArray *)points {

    GraphView *     graphView   = [self.graphViews objectForKey:label];
    _origin                     = 0.0;
    _extent                     = 0.0;
    
    if ( points.count ) for ( NSValue * datum in points ) {
        
        CGPoint     point       = [datum CGPointValue];

        if ( point.x < self.origin ) { _origin = point.x; }
        if ( point.x > self.extent ) { _extent = point.x; }

    }
    
    if ( points ) {
    
        CGFloat     extent      = self.extent * self.scale;
        CGPoint     offset      = self.scrollView.contentOffset;
        
        if ( ! [self.scrollView isTracking] ) {
            
            if ( (extent - 10.0) < offset.x ) {
                [self.scrollView setContentOffset:CGPointMake( extent - 10.0, offset.y )];
            } else if ( (extent + 10.0) > (offset.x + self.scrollView.bounds.size.width) ) {
                [self.scrollView setContentOffset:CGPointMake( extent + 10.0 - self.scrollView.bounds.size.width, offset.y )];
            }
            
        }

    } else [self.scrollView setContentOffset:CGPointMake( 0, 0 )];
    
    [graphView setPoints:[points copy]];
    
    [self setNeedsLayout];
    
}

- (void) layoutSubviews {

    CGRect      area    = CGRectMake ( self.origin * self.scale, 0, 5.0 + ((self.extent - self.origin) * self.scale), self.bounds.size.height );
    
    for ( GraphView * graph in [self.graphViews allValues] ) [graph setFrame:area];

    [self.scrollView setContentSize:CGSizeMake( area.size.width, area.size.height )];

}

#pragma mark - Rendering

- (void) drawRect:(CGRect)rect {

    CGContextRef    context     = UIGraphicsGetCurrentContext( );
    
    CGContextSaveGState( context );
    CGContextSetAllowsAntialiasing( context, YES );

    [self drawAxis:rect inContext:context];
    
    CGContextRestoreGState( context );

}

- (void) drawAxis:(CGRect)rect inContext:(CGContextRef)context {

    // Poistion the axis lines using the bias and range.
    
    if ( self.range ) {
        
        CGFloat center  = (0.5 + (self.bias / self.range)) * rect.size.height;
    
        CGContextMoveToPoint( context, rect.origin.x, rect.origin.y );
        CGContextAddLineToPoint( context, rect.origin.x, rect.origin.y + rect.size.height );
        CGContextMoveToPoint( context, rect.origin.x, rect.origin.y + rect.size.height - center );
        CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - center );

        } else return;

    // Render the axis lines.
    
    CGContextSetStrokeColorWithColor( context, [UIColor lightGrayColor].CGColor );
    CGContextSetLineWidth( context, 0.25 );
    CGContextStrokePath( context );

}

@end
