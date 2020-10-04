//
//  project: ShockVx
//     file: AppSettings.h
//
//  Persistent application settings.
//
//  Copyright © 2020 Velvetwire, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSettingsUserCode                       @"account_code"
#define kSettingsUserName                       @"account_name"
#define kSettingsUserMail                       @"account_email"
#define kSettingsUserPass                       @"account_password"

#define kSettingsAssetDescription               @"asset_description"

@interface AppSettings : NSObject

@property (nonatomic, readonly) NSUUID *        userCode;
@property (nonatomic, readonly) NSString *      userName;
@property (nonatomic, readonly) NSString *      userMail;
@property (nonatomic, readonly) NSString *      userPass;

@property (nonatomic, strong)   NSString *      assetDescription;

- (void) setUserName:(NSString *)name code:(NSUUID *)code;
- (void) setUserMail:(NSString *)mail password:(NSString *)password;

@end
