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
	IBOutlet NSPopUpButton			*browsers;
	
	NSString *newUsername;
	NSString *newPassword;
	NSString *newServer;
	NSString *newAlias;
}

- (IBAction)addCredential:(id)sender;
- (IBAction)addAndLogin:(id)sender;
- (IBAction)addServer:(id)sender;

@property (retain) NSString *newUsername;
@property (retain) NSString *newPassword;
@property (retain) NSString *newServer;
@property (retain) NSString *newAlias;

- (NSArray *)browsers;

@end
