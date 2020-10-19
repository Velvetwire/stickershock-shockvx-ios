//
//  project: ShockVx
//     file: SurfaceArchiveController.m
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "SurfaceArchiveController.h"
#import "SurfaceEventCell.h"
#import "GraphControl.h"

@interface SurfaceArchiveController ( )

@property (nonatomic, weak) IBOutlet    UIProgressView *            eventProgress;
@property (nonatomic, weak) IBOutlet    UIActivityIndicatorView *   eventActivity;
@property (nonatomic, weak) IBOutlet    GraphControl *              eventGraph;
@property (nonatomic, weak) IBOutlet    UITableView *               eventTable;

@property (atomic, strong)              NSArray *                   eventRecords;

@end

@implementation SurfaceArchiveController
@synthesize eventRecords = _eventRecords;

- (void) viewDidLoad {
    
    [super viewDidLoad];

    [self.eventGraph setClipsToBounds:YES];
    [self.eventGraph.layer setCornerRadius:10.0];
    [self.eventGraph addPlot:@"temperature" color:self.view.tintColor];

    [self.eventGraph setScale:0.15];
    [self.eventGraph setRange:100.0];

    // Register for archive event notices.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveEvent:) name:kSensorNotificationSurfaceEvents object:nil];

}

- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    if ( [self.eventRecords count] == [self.sensor.surface number] ) [self plotRecords:self.eventRecords];
    else [self setEventRecords:self.sensor.surface.events];
    
}

- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    NSUInteger      count   = [self.sensor.surface.events count];
    NSUInteger      number  = [self.sensor.surface number];
    
    if ( count && (count >= number) ) {
    
        [self.eventTable setUserInteractionEnabled:YES];
        [self.eventProgress setHidden:YES];
        [self.eventActivity stopAnimating];

    }

}

- (void) setSensor:(SensorDevice *)sensor {

    if ( (_sensor = sensor) ) { [self setEventRecords:sensor.surface.events]; }

}

- (void) plotRecords:(NSArray *)records {

    NSMutableArray *    points  = [[NSMutableArray alloc] init];
    NSArray *           events  = [records copy];
    NSDate *            start   = [(NSDictionary *)[events firstObject] objectForKey:@"date"];
    
    for ( NSDictionary * event in events ) {
    
        CGFloat         time    = [(NSDate *)[event objectForKey:@"date"] timeIntervalSinceDate:start];
        CGFloat         value   = (CGFloat) [[event objectForKey:@"temperature"] floatValue];
        CGPoint         point   = CGPointMake( time, value );
        
        [points addObject:[NSValue valueWithCGPoint:point]];
        
    }

    [self.eventGraph setPlot:@"temperature" points:points];

}

- (void) setEventRecords:(NSArray *)records { if ( (_eventRecords = records) ) [self plotRecords:records]; }

- (NSArray *) eventRecords { return _eventRecords; }


#pragma mark - Table view data source and delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)table { return ( 1 ); }

- (NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section { return [self.eventRecords count]; }

- (NSString *) tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section { return @"Surface Temperature Records"; }

- (UITableViewCell *) tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {

    SurfaceEventCell *  cell        = [table dequeueReusableCellWithIdentifier:@"surfaceEventCell" forIndexPath:path];
    NSDictionary *      event       = [self.eventRecords objectAtIndex:path.row];

    if ( cell ) {
        
        NSDate *        date        = [event objectForKey:@"date"];
        NSNumber *      temperature = [event objectForKey:@"temperature"];
        
        [cell setTimestamp:date];
        [cell setTemperature:temperature];
        
    }

    return ( cell );

}

- (void) tableView:(UITableView *)table growFromIndex:(NSInteger)index {

    NSMutableArray *    paths   = [[NSMutableArray alloc] init];
    
    // Determine the number of new event entries that need
    // to be appended to the table and build an array of
    // index paths. Add points to the graph.
    
    while ( index < self.eventRecords.count ) { [paths addObject:[NSIndexPath indexPathForRow:index ++ inSection:0]]; }

    // Append the new rows to the table. At completion, update the
    // graph with the plot array.

    if ( paths.count ) {

        [table beginUpdates];
        [table insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
        [table endUpdates];
        
    }

}

- (void) tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)path {

    [self.eventGraph selectPlot:@"temperature" pointAtIndex:path.row];
    
}

#pragma mark - Sensor notifications

- (void) didReceiveEvent:(NSNotification *)notification {

    SensorDevice *      sensor  = (SensorDevice *) notification.object;
    NSInteger           index   = [(NSNumber *) [notification.userInfo objectForKey:@"index"] integerValue];
    
    if ( [self.sensor isEqual:sensor] ) {
        
        NSInteger       start   = [self.eventTable numberOfRowsInSection:0];
        NSInteger       total   = [sensor.surface number];
        NSInteger       count   = (index + 1);

        // If all of the events in the unit have been received, activate
        // the table and hide the progress. Otherwise, update progress.

        if ( count == total ) {

            [self.eventTable setUserInteractionEnabled:YES];
            [self.eventProgress setHidden:YES];
            [self.eventActivity stopAnimating];

        } else [self.eventProgress setProgress:((float)count / (float)total)];

        [self setEventRecords:[sensor.surface.events subarrayWithRange:NSMakeRange( 0, count )]];
        
        if ( start < count ) [self tableView:self.eventTable growFromIndex:start];

    }

}

#pragma mark - Attachment data

- (NSDate *) archiveStart {

    return [(NSDictionary *)[self.eventRecords firstObject] objectForKey:@"date"];

}

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
