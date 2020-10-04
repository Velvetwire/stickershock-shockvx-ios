//
//  project: ShockVx
//     file: SignalControl.h
//
//  Signal level visualization control.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

// Signal level thresholds
typedef NS_ENUM( NSInteger, SignalLevel ) {

    kNoSignal           = -127,
    kSignalLevelFaint   = -91,
    kSignalLevelLow     = -83,
    kSignalLevelHigh    = -73,
    kSignalLevelStrong  = -65,

};

//
// Signal control graphic element
@interface SignalGraphic : UIView

@property (nonatomic)   SignalLevel signalLevel;

@end

//
// Signal visualization control
@interface SignalControl : UIControl

@property (nonatomic)   float   signalLevel;

@end
