//
//  project: ShockVx
//     file: AmbientArchiveController.m
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AmbientArchiveController.h"
#import "AmbientEventCell.h"
#import "GraphControl.h"

@interface AmbientArchiveController ( )

@property (nonatomic, weak) IBOutlet    UIProgressView *            eventProgress;
@property (nonatomic, weak) IBOutlet    UIActivityIndicatorView *   eventActivity;
@property (nonatomic, weak) IBOutlet    GraphControl *              eventGraph;
@property (nonatomic, weak) IBOutlet    UITableView *               eventTable;

@property (atomic, strong)              NSArray *                   eventRecords;

@end

@implementation AmbientArchiveController
@synthesize eventRecords = _eventRecords;

- (void) viewDidLoad {

    [super viewDidLoad];

    [self.eventGraph setClipsToBounds:YES];
    [self.eventGraph.layer setCornerRadius:10.0];
    [self.eventGraph addPlot:@"temperature" color:self.view.tintColor];

    // Register for archive event notices.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveEvent:) name:kSensorNotificationAtmosphericEvents object:nil];

}

- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    if ( self.eventRecords) [self plotRecords:self.eventRecords];
    else [self setEventRecords:self.sensor.atmosphere.events];
    
}

- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    NSUInteger      count   = [self.sensor.atmosphere.events count];
    NSUInteger      number  = [self.sensor.atmosphere number];
    
    if ( count && (count >= number) ) {

        [self.eventTable setUserInteractionEnabled:YES];
        [self.eventProgress setHidden:YES];
        [self.eventActivity stopAnimating];

    }

}

- (void) setSensor:(SensorDevice *)sensor {

    if ( (_sensor = sensor) ) { [self setEventRecords:sensor.atmosphere.events]; }

}

- (void) plotRecords:(NSArray *)records {

    NSMutableArray *    points  = [[NSMutableArray alloc] init];

    for ( NSDictionary * event in records ) {
        
        CGFloat         time    = (CGFloat) [records indexOfObject:event];
        CGFloat         value   = (CGFloat) [[event objectForKey:@"temperature"] floatValue];
        CGPoint         point   = CGPointMake( time * 10.0, value / 125.0 );
        
        [points addObject:[NSValue valueWithCGPoint:point]];
        
    }

    [self.eventGraph setPlot:@"temperature" points:points];

}

- (void) setEventRecords:(NSArray *)records { if ( (_eventRecords = records) ) [self plotRecords:records]; }

- (NSArray *) eventRecords { return _eventRecords; }

#pragma mark - Table view data source and delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)table { return ( 1 ); }

- (NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section { return [self.eventRecords count]; }

- (NSString *) tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section { return @"Ambient Temperature Records"; }

- (UITableViewCell *) tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {

    AmbientEventCell *  cell        = [table dequeueReusableCellWithIdentifier:@"ambientEventCell" forIndexPath:path];
    NSDictionary *      event       = [self.eventRecords objectAtIndex:path.row];

    if ( cell ) {
        
        NSDate *        date        = [event objectForKey:@"date"];
        NSNumber *      temperature = [event objectForKey:@"temperature"];
        
        [cell setTimestamp:date];
        [cell setTemperature:temperature];
        
    }
    
    return ( cell );
    
}

#pragma mark - Sensor notifications

- (void) didReceiveEvent:(NSNotification *)notification {

    SensorDevice *      sensor  = (SensorDevice *) notification.object;
    NSInteger           index   = [(NSNumber *) [notification.userInfo objectForKey:@"index"] integerValue];
    NSInteger           total   = [sensor.atmosphere number];
    NSMutableArray *    paths   = [[NSMutableArray alloc] init];
    
    if ( [self.sensor isEqual:sensor] ) {
        
        // Determine the number of new event entries that need
        // to be appended to the table and build an array of
        // index paths. Add points to the graph.
        
        for ( NSInteger n = self.eventRecords.count; n <= index; ++ n ) {
            [paths addObject:[NSIndexPath indexPathForRow:n inSection:0]];
        }

        // If all of the events in the unit have been received, activate
        // the table and hide the progress. Otherwise, update progress.

        if ( ++ index == total ) {

            [self.eventTable setUserInteractionEnabled:YES];
            [self.eventProgress setHidden:YES];
            [self.eventActivity stopAnimating];

        } else [self.eventProgress setProgress:((float)index / (float)total)];

        [self setEventRecords:[sensor.atmosphere.events subarrayWithRange:NSMakeRange( 0, index )]];
        
        // Append the new rows to the table. At completion, update the
        // graph with the plot array.

        if ( paths.count ) {

            [self.eventTable beginUpdates];
            [self.eventTable insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.eventTable endUpdates];
            
        }

    }

}

#pragma mark - Attachment data

- (NSData *) archiveAttachment {

    NSMutableData *     attachment  = [[NSMutableData alloc] init];
    NSDateFormatter *   formatter   = [[NSDateFormatter alloc] init];
    NSString *          header      = @"Date,Time,Celsius\n";

    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];

    [attachment appendData:[header dataUsingEncoding:NSUTF8StringEncoding]];
    
    for ( NSDictionary * event in [self.eventRecords copy] ) {

        NSDate *        date        = [event objectForKey:@"date"];
        NSNumber *      temperature = [event objectForKey:@"temperature"];
        NSString *      entry       = [NSString stringWithFormat:@"%@,%1.2f\n", [formatter stringFromDate:date], [temperature floatValue]];
        
        [attachment appendData:[entry dataUsingEncoding:NSUTF8StringEncoding]];
        
    }

    return ( attachment );
    
}

@end
