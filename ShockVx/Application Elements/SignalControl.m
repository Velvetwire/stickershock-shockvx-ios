//
//  project: ShockVx
//     file: SignalControl.m
//
//  Signal level visualization control.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "SignalControl.h"

@interface SignalControl ( )

@property (nonatomic, strong)   SignalGraphic *     signalGraphic;
@property (nonatomic, strong)   UILabel *           signalLabel;

@end

@implementation SignalControl

- (instancetype) initWithCoder:(NSCoder *)coder {

    if ( (self = [super initWithCoder:coder] ) ) [self initElements];
    
    return ( self );
    
}

- (instancetype) initWithFrame:(CGRect)frame {

    if ( (self = [super initWithFrame:frame]) ) [self initElements];
    
    return ( self );
    
}

- (void) initElements {

    _signalLabel        = [[UILabel alloc] initWithFrame:self.frame];
    _signalGraphic      = [[SignalGraphic alloc] initWithFrame:self.frame];

    [self setBackgroundColor:[UIColor clearColor]];
    
    if ( self.signalLabel ) {
    
        [self.signalLabel setFont:[UIFont systemFontOfSize:13.0]];
        [self.signalLabel setTextAlignment:NSTextAlignmentLeft];
        [self.signalLabel setTextColor:[UIColor lightGrayColor]];
        
        [self addSubview:self.signalLabel];
        
    }

    if ( self.signalGraphic ) {
        
        [self.signalGraphic setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.signalGraphic];
        
    }

}

#pragma mark - Values

- (void) setSignalLevel:(float)level {

    int     signal = (int) roundf( _signalLevel = level );
    
    [self.signalLabel setText:[NSString stringWithFormat:@"%i dB", signal]];
    
    [self.signalGraphic setSignalLevel:signal];
    [self.signalGraphic setNeedsDisplay];
    
}

#pragma mark - Arrangement

- (void) layoutSubviews {
    
    CGRect      rect = CGRectMake ( 0, 0, 25, 15 );
    CGRect      area = CGRectOffset( rect, 0, (self.bounds.size.height - rect.size.height) / 2 );
    CGRect      text = CGRectMake ( rect.size.width + 4, 0, self.bounds.size.width - rect.size.width - 4, self.bounds.size.height );
    
    [self.signalLabel setFrame:text];
    [self.signalGraphic setFrame:area];
    
}

@end

@implementation SignalGraphic

#pragma mark - Rendering

- (void) drawRect:(CGRect)rect {
    
    CGContextRef    context = UIGraphicsGetCurrentContext( );
    CGSize          size    = CGSizeMake ( rect.size.width / 4, rect.size.height / 2 );
    CGRect          area    = CGRectMake( 0, size.height, size.width, rect.size.height - size.height );
    
    CGContextSaveGState( context );
    CGContextSetAllowsAntialiasing( context, YES );
    
    [self drawBar:CGRectInset( area, 1, 1 ) inContext:context threshold:(self.signalLevel >= kSignalLevelFaint ? YES : NO)];
    [self moveBar:&area shift:size.width grow:size.height / 3];
    
    [self drawBar:CGRectInset( area, 1, 1 ) inContext:context threshold:(self.signalLevel >= kSignalLevelLow ? YES : NO)];
    [self moveBar:&area shift:size.width grow:size.height / 3];

    [self drawBar:CGRectInset( area, 1, 1 ) inContext:context threshold:(self.signalLevel >= kSignalLevelHigh ? YES : NO)];
    [self moveBar:&area shift:size.width grow:size.height / 3];

    [self drawBar:CGRectInset( area, 1, 1 ) inContext:context threshold:(self.signalLevel >= kSignalLevelStrong ? YES : NO)];

    CGContextRestoreGState( context );
    
}

- (void) drawBar:(CGRect)rect inContext:(CGContextRef)context threshold:(bool)threshold {
    
    CGPathRef       path    = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:1.0].CGPath;
    
    // Select the bar color based on the whether it is above or below the threshold.
    
    if ( threshold ) { CGContextSetFillColorWithColor( context, [self tintColor].CGColor ); }
    else { CGContextSetFillColorWithColor( context, [self.tintColor colorWithAlphaComponent:0.25].CGColor ); }
    
    // Draw the signal bar element.
    
    CGContextAddPath( context, path );
    CGContextClosePath( context );
    CGContextFillPath( context );
    
}

- (void) moveBar:(CGRect *)rect shift:(CGFloat)shift grow:(CGFloat)grow {
    
    rect->origin.x      += shift;
    rect->origin.y      -= grow;
    rect->size.height   += grow;
    
}

@end
