//
//  project: ShockVx
//     file: ArchiveTabsController.m
//
//
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "ArchiveTabsController.h"
#import "AmbientArchiveController.h"
#import "SurfaceArchiveController.h"

#import <MessageUI/MessageUI.h>

@interface ArchiveTabsController ( ) <MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *  sendButton;

@property (nonatomic, weak) AmbientArchiveController *  ambientController;
@property (nonatomic, weak) SurfaceArchiveController *  surfaceController;

@end

@implementation ArchiveTabsController

- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    for ( UIViewController * controller in self.viewControllers ) {
    
        if ( [controller isKindOfClass:[AmbientArchiveController class]] ) { [(_ambientController = (AmbientArchiveController *)controller) setSensor:self.sensor]; }
        if ( [controller isKindOfClass:[SurfaceArchiveController class]] ) { [(_surfaceController = (SurfaceArchiveController *)controller) setSensor:self.sensor]; }

    }
    
    if ( ! [MFMailComposeViewController canSendMail] ) { [self.sendButton setEnabled:NO]; }
    
}

- (IBAction)touchSend:(id)sender {

    [self sendMail];
    
}

#pragma mark - Mail composition

- (void) sendMail {

    MFMailComposeViewController *   controller  = [[MFMailComposeViewController alloc] init];
    NSDateFormatter *               formatter   = [[NSDateFormatter alloc] init];
    NSString *                      section     = @"Capture";
    NSDate *                        date        = [NSDate date];
    
    switch ( self.selectedIndex ) {
    
        case kArchiveTabIndexAmbient:
            section     = @"Ambient temperature";
            date        = [self.ambientController archiveStart];
            break;
            
        case kArchiveTabIndexSurface:
            section     = @"Surface tempreature";
            date        = [self.surfaceController archiveStart];
            break;

    }
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];

    NSString *                      subject     = [NSString stringWithFormat:@"%@ - %@", section, [formatter stringFromDate:date]];
    
    [controller setMailComposeDelegate:self];
    [controller setSubject:subject];
    
    NSString *                      message     = [NSString stringWithFormat:@"Telemetry captured by device %@\n", [self.sensor.unitIdentifier identifierString]];

    [controller setMessageBody:message isHTML:NO];

    switch ( self.selectedIndex ) {
    
        case kArchiveTabIndexAmbient:
            [controller addAttachmentData:[self.ambientController archiveAttachment]
                                 mimeType:@"text/csv"
                                 fileName:@"Ambient.csv"];
            break;
            
        case kArchiveTabIndexSurface:
            [controller addAttachmentData:[self.surfaceController archiveAttachment]
                                 mimeType:@"text/csv"
                                 fileName:@"Surface.csv"];
            break;
            
    }
    
    [self presentViewController:controller animated:YES completion:nil];

}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {

    [controller dismissViewControllerAnimated:YES completion:^{

        // Code goes here

        if ( error ) NSLog ( @"Mail sent with error %@", error );
        else NSLog ( @"Mail sent with result %i", (int) result );
        
    }];
    
}

@end
