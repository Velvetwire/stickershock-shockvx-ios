//
//  project: ShockVx
//     file: AppSettings.h
//
//  Persistent application settings.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import "AppSettings.h"

//
// Persistent settings implementation
//

@implementation AppSettings

- (id) init {
    
    if ( (self = [super init]) ) {
        
        // Retrieve the settings from the user defaults.
        
        [self retrieveSettings];
        
        // Register to receive notifications whenever defaults change.
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retrieveSettings) name:NSUserDefaultsDidChangeNotification object:nil];
        
    }
    
    // Return with settings.
    
    return ( self );
    
}

//
// Get the persistent settings for the application
- (void) retrieveSettings {
    
    NSUserDefaults *    defaults    = [NSUserDefaults standardUserDefaults];
    NSString *              code    = [defaults stringForKey:kSettingsUserCode];

    // Construct the user code if it exists.
    
    if ( code ) { _userCode = [[NSUUID alloc] initWithUUIDString:code]; }

    // Fetch the settings from the user defaults.
        
    _userName                       = [defaults stringForKey:kSettingsUserName];
    _userMail                       = [defaults stringForKey:kSettingsUserMail];
    _userPass                       = [defaults stringForKey:kSettingsUserPass];

    // Fetch the default values for asset description
    
    _assetDescription               = [defaults stringForKey:kSettingsAssetDescription];
    
}

//
// Set or reset the user name and UUID code
- (void) setUserName:(NSString *)name code:(NSUUID *)code {

    NSUserDefaults *    defaults    = [NSUserDefaults standardUserDefaults];

    if ( (_userName = name) ) [defaults setObject:[name copy] forKey:kSettingsUserName];
    else [defaults removeObjectForKey:kSettingsUserName];
    
    if ( (_userCode = code) ) [defaults setObject:[code UUIDString] forKey:kSettingsUserCode];
    else [defaults removeObjectForKey:kSettingsUserCode];

}

//
// Set or reset the user email and password
- (void) setUserMail:(NSString *)mail password:(NSString *)password {

    NSUserDefaults *    defaults    = [NSUserDefaults standardUserDefaults];

    if ( (_userMail = mail) ) [defaults setObject:[mail copy] forKey:kSettingsUserMail];
    else [defaults removeObjectForKey:kSettingsUserMail];
    
    if ( (_userPass = password) ) [defaults setObject:[password copy] forKey:kSettingsUserPass];
    else [defaults removeObjectForKey:kSettingsUserPass];
    
}

//
// Update the default asset description
- (void) setAssetDescription:(NSString *)description {

    NSUserDefaults *    defaults    = [NSUserDefaults standardUserDefaults];

    if ( (_assetDescription = description) ) [defaults setObject:[description copy] forKey:kSettingsAssetDescription];
    else [defaults removeObjectForKey:kSettingsAssetDescription];

}

@end
