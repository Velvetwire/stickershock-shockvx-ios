//
//  project: ShockVx
//     file: AccountRegistrationViewController.h
//
//  Account registration and sign-up form.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountRegistrationViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, readonly) NSUUID *        userCode;
@property (nonatomic, readonly) NSString *      userName;
@property (nonatomic, readonly) NSString *      userMail;
@property (nonatomic, readonly) NSString *      userPassword;

@end
