//
//  project: ShockVx
//     file: AmbientArchiveController.h
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SensorDevice.h"

@interface AmbientArchiveController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak)     SensorDevice *              sensor;

- (NSDate *) archiveStart;
- (NSData *) archiveAttachment;

@end
