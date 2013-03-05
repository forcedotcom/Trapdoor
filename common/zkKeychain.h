//
//  zkKeychain.h
//  AppExplorer
//
//  Created by Simon Fell on 11/26/06.
//  Copyright 2006 Simon Fell. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface zkKeychain : NSObject {
	NSString				*server;
	SecKeychainItemRef		keychainItem;	

	NSString				*username;
	NSString				*password;
	BOOL					promptOnSave;
}

+ (id)KeychainItemForServer:(NSString *)server andUsername:(NSString *)username;
+ (id)KeychainItemForServer:(NSString *)server;

- (NSString *)server;
- (NSString *)username;
- (NSString *)password;

- (BOOL)promptOnSave;
- (void)setPromptOnSave:(BOOL)newPromptOnSave;
- (void)updateKeychainWithUsername:(NSString *)newUsername password:(NSString *)newPassword;

@end
