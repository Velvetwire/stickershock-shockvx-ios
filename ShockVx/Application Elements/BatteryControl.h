//
//  project: ShockVx
//     file: BatteryControl.h
//
//  Battery level visualization control.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

//
// Battery control graphic element
@interface BatteryGraphic : UIView

@property (nonatomic)   float       batteryLevel;

@end

//
// Battery visualization control
@interface BatteryControl : UIControl

@property (nonatomic)   float       batteryLevel;
@property (nonatomic)   bool        batteryCharging;

@end
