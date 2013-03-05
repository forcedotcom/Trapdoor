//
//  AllCredentialsController.h
//  trapdoor
//
//  Created by Simon Fell on 4/21/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NewServerController.h"

@class GDOutlineView;
@class CredentialEditor;
@class Browser;

@interface AllCredentialsController : NSObject <NewServerAdded> {
	IBOutlet	NSWindow 			*window;
	IBOutlet 	GDOutlineView		*credList;
	IBOutlet	NewServerController	*newServerController;

	NSMutableArray		*rootList;
	CredentialEditor 	*current;
}

- (IBAction)showCredentials:(id)sender;
- (IBAction)showPassword:(id)sender;
- (IBAction)saveChanges:(id)sender;
- (IBAction)addSever:(id)sender;
- (IBAction)removeCurrentFromKeychain:(id)sender;

- (CredentialEditor *)currentCredential;
- (void)setCurrentCredential:(CredentialEditor *)aValue;

- (void)newServerAdded:(NSString *)server;
- (NSArray *)browsers;
@end
