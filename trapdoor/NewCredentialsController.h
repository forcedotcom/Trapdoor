//
//  NewCredentialsController.h
//  trapdoor
//
//  Created by Simon Fell on 1/24/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppController;

@interface NewCredentialsController : NSObject {
	IBOutlet NSWindow 		*window;
	IBOutlet NSWindow 		*addServerWindow;
	IBOutlet AppController 	*mainController;
	
	NSString *newUsername;
	NSString *newPassword;
	NSString *newServer;
	NSString *newAlias;
}

- (IBAction)addCredential:(id)sender;
- (IBAction)addAndLogin:(id)sender;
- (IBAction)addServer:(id)sender;
- (IBAction)cancelAddServer:(id)sender;
- (IBAction)showAddServer:(id)sender;

- (NSString *)newUsername;
- (void)setNewUsername:(NSString *)s;
- (NSString *)newPassword;
- (void)setNewPassword:(NSString *)s;
- (NSString *)newServer;
- (void)setNewServer:(NSString *)s;
- (NSString *)newAlias;
- (void)setNewAlias:(NSString *)aNewAlias;

@end
