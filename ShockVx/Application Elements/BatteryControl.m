//
//  project: ShockVx
//     file: BatteryControl.m
//
//  Battery level visualization control.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "BatteryControl.h"

@interface BatteryControl ( )

@property (nonatomic, strong)   BatteryGraphic *    batteryGraphic;
@property (nonatomic, strong)   UILabel *           batteryLabel;

@end

@implementation BatteryControl

- (instancetype) initWithCoder:(NSCoder *)coder {

    if ( (self = [super initWithCoder:coder]) ) [self initElements];
    
    return ( self );

}

- (instancetype) initWithFrame:(CGRect)frame {

    if ( (self = [super initWithFrame:frame]) ) [self initElements];
    
    return ( self );
        
}

- (void) initElements {

    _batteryLabel       = [[UILabel alloc] initWithFrame:self.frame];
    _batteryGraphic     = [[BatteryGraphic alloc] initWithFrame:self.frame];

    [self setBackgroundColor:[UIColor clearColor]];
        
    if ( self.batteryLabel ) {
    
        [self.batteryLabel setFont:[UIFont systemFontOfSize:13.0]];
        [self.batteryLabel setTextAlignment:NSTextAlignmentRight];
        [self.batteryLabel setTextColor:[UIColor lightGrayColor]];
        [self.batteryLabel setText:@"--"];
        
        [self addSubview:self.batteryLabel];
        
    }

    if ( self.batteryGraphic ) {
        
        [self.batteryGraphic setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.batteryGraphic];
        
    }

}

#pragma mark - Values

- (void) setBatteryLevel:(float)level {

    [self.batteryLabel setText:[NSString stringWithFormat:@"%i%%", (int) roundf( _batteryLevel = level )]];
    
    [self.batteryGraphic setBatteryLevel:level / 100];
    [self.batteryGraphic setNeedsDisplay];
    
}


#pragma mark - Arrangement

- (void) layoutSubviews {
    
    CGRect      rect = CGRectMake ( 0, 0, 30, 15 );
    CGRect      area = CGRectOffset( rect, self.bounds.size.width - rect.size.width, (self.bounds.size.height - rect.size.height) / 2 );
    CGRect      text = CGRectMake ( 0, 0, self.bounds.size.width - rect.size.width - 4, self.bounds.size.height );
    
    [self.batteryLabel setFrame:text];
    [self.batteryGraphic setFrame:area];
    
}

@end

@implementation BatteryGraphic

#pragma mark - Rendering

- (void) drawRect:(CGRect)rect {
    
    CGContextRef    context = UIGraphicsGetCurrentContext( );
    CGRect          area    = CGRectInset ( rect, 1.5, 1.5 );
    
    CGContextSaveGState( context );
    CGContextSetAllowsAntialiasing( context, YES );
    
    [self drawBatteryTip:area inContext:context];
    [self drawBattery:area inContext:context];
    
    CGContextRestoreGState( context );
    
}

- (void) drawBatteryTip:(CGRect)rect inContext:(CGContextRef)context {
    
    rect.origin.x           = rect.origin.x + rect.size.width - 2.0;
    rect.size.width         = 1.5;
    CGPathRef       path    = [UIBezierPath bezierPathWithRoundedRect:CGRectInset( rect, 0, 3.0 ) cornerRadius:0.75].CGPath;
    
    CGContextSetFillColorWithColor( context, [self.tintColor colorWithAlphaComponent:0.25].CGColor );
    
    CGContextAddPath( context, path );
    CGContextClosePath( context );
    CGContextFillPath( context );
    
}

- (void) drawBattery:(CGRect)rect inContext:(CGContextRef)context {
    
    rect.size.width         = rect.size.width - 3.0;
    CGPathRef       path    = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:2.5].CGPath;
    
    CGContextSetFillColorWithColor( context, [self tintColor].CGColor );
    CGContextSetStrokeColorWithColor( context, [self.tintColor colorWithAlphaComponent:0.25].CGColor );
    
    CGContextAddPath( context, path );
    CGContextClosePath( context );
    CGContextStrokePath( context );
    
    rect                    = CGRectInset( rect, 1.5, 1.5 );
    rect.size.width         = rect.size.width * self.batteryLevel;
    path                    = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:1.0].CGPath;
    
    CGContextAddPath( context, path );
    CGContextClosePath( context );
    CGContextFillPath( context );
    
}

@end
