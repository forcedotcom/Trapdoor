//
//  CredentialEditor.h
//  trapdoor
//
//  Created by Simon Fell on 4/25/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "credential.h"
#import "BrowserSetting.h"
#import "Browser.h"

@interface CredentialEditor : NSObject {
	Credential *credential;
	
	NSString	*username;
	NSString	*password;
	NSString	*server;
	NSString	*alias;
	Browser		*browser;
}

- (id)initForCredential:(Credential *)c;

- (NSString *)username;
- (void)setUsername:(NSString *)aUsername;
- (NSString *)password;
- (void)setPassword:(NSString *)aPassword;
- (NSString *)server;
- (void)setServer:(NSString *)aServer;
- (NSString *)alias;
- (void)setAlias:(NSString *)aAlias;
- (Browser *)browser;
- (void)setBrowser:(Browser *)aValue;

- (IBAction)populatePasswordFromCredential:(id)sender;
- (BOOL)saveChanges:(id)sender;
- (IBAction)createNewCredential:(id)sender;
- (IBAction)removeFromKeychain:(id)sender;
@end
