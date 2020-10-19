//
//  project: ShockVx
//     file: SurfaceArchiveController.h
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SensorDevice.h"

@interface SurfaceArchiveController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak)     SensorDevice *              sensor;

- (NSDate *) archiveStart;
- (NSData *) archiveAttachment;

@end
