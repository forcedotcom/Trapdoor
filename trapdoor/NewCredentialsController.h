//
//  NewCredentialsController.h
//  trapdoor
//
//  Created by Simon Fell on 1/24/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NewServerController.h"

@class AppController;
@class Browser;

@interface NewCredentialsController : NSObject <NewServerAdded> {
	IBOutlet NSWindow 				*window;
	IBOutlet AppController 			*mainController;
	IBOutlet NewServerController 	*newServerController;
	
	NSString *newUsername;
	NSString *newPassword;
	NSString *newServer;
	NSString *newAlias;
	Browser  *newBrowser;
}

- (IBAction)addCredential:(id)sender;
- (IBAction)addAndLogin:(id)sender;
- (IBAction)addServer:(id)sender;

- (NSString *)newUsername;
- (void)setNewUsername:(NSString *)s;
- (NSString *)newPassword;
- (void)setNewPassword:(NSString *)s;
- (NSString *)newServer;
- (void)setNewServer:(NSString *)s;
- (NSString *)newAlias;
- (void)setNewAlias:(NSString *)aNewAlias;
- (Browser *)newBrowser;
- (void)setNewBrowser:(Browser *)aNewBrowser;
- (NSArray *)browsers;

@end
