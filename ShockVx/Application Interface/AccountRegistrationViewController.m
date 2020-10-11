//
//  project: ShockVx
//     file: AccountRegistrationViewController.m
//
//  Account registration and sign-up form.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//


#import "AccountRegistrationViewController.h"

@interface AccountRegistrationViewController ( )

@property (nonatomic, weak) IBOutlet    UITextField *   nameField;
@property (nonatomic, weak) IBOutlet    UITextField *   emailField;
@property (nonatomic, weak) IBOutlet    UITextField *   passwordField;
@property (nonatomic, weak) IBOutlet    UIButton *      registerButton;
@property (nonatomic, weak) IBOutlet    UIScrollView *  scrollView;

@end

@implementation AccountRegistrationViewController

- (void) viewDidLoad {

    [super viewDidLoad];

    [self.registerButton setClipsToBounds:YES];
    [self.registerButton setBackgroundColor:self.view.tintColor];
    [self.registerButton setTintColor:[UIColor whiteColor]];
    [self.registerButton.layer setCornerRadius:10.0];

}

#pragma mark - Text Fields

- (void) textFieldDidBeginEditing:(UITextField *)field {

    [self.scrollView setContentOffset:CGPointMake( 0, field.frame.origin.y ) animated:YES];

}

- (void) textFieldDidEndEditing:(UITextField *)field {

    [self.scrollView setContentOffset:CGPointMake( 0, 0 ) animated:YES];

    switch ( field.tag ) {
    
        case 1: _userName = field.text; break;
        case 2: _userMail = field.text; break;
        case 3: _userPassword = field.text; break;
    
    }
    
    if ( [self nameFieldValid] && [self emailFieldValid] && [self passwordFieldValid] ) [self.registerButton setEnabled:YES];
    else [self.registerButton setEnabled:NO];
    
}

- (bool) textField:(UITextField *)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    return ( YES );
    
}

- (bool) textFieldShouldReturn:(UITextField *)field {
    
    if ( field.text.length ) [field resignFirstResponder];
    else return ( NO );
    
    return ( YES );
    
}

- (bool) nameFieldValid {
    
    return self.nameField.text.length ? YES : NO;
    
}

- (bool) emailFieldValid {

    return self.emailField.text.length ? YES : NO;

}

- (bool) passwordFieldValid {

    return self.passwordField.text.length ? YES : NO;

}

#pragma mark - User actions

- (IBAction) pressedRegister:(id)sender {

    if ( ! self.userCode ) { _userCode = [NSUUID UUID]; }
    
    [self performSegueWithIdentifier:@"completeRegistration" sender:nil];
    
}

@end
