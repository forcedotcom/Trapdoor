//
//  NewCredentialsController.m
//  trapdoor
//
//  Created by Simon Fell on 1/24/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import "NewCredentialsController.h"
#import "AppController.h"
#import "zkSforceClient.h"
#import "zkSoapException.h"
#import "credential.h"
#import "Browser.h"
#import "BrowserSetting.h"

@implementation NewCredentialsController

- (id)init {
	self = [super init];
	[self setNewServer:prodUrl];
	[self setNewBrowser:[Browser forBundleIdentifier:nil]];
	return self;
}

- (void)dealloc {
	[newUsername release];
	[newPassword release];
	[newServer release];
	[newBrowser release];
	[super dealloc];
}

- (ZKSforceClient *)validateCredentials {
	ZKSforceClient *sforce = [mainController clientForServer:newServer];
	@try {
		[sforce login:newUsername password:newPassword];
		return sforce;
	}
	@catch (ZKSoapException *ex) {
		NSAlert * a = [NSAlert alertWithMessageText:[ex reason] defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Login failed"];
		[a beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
	}
	return nil;
}

- (void)checkAndAdd:(BOOL)openWhenDone {
	ZKSforceClient *sf = [self validateCredentials];
	if (sf == nil) return; 
	Credential *c = [mainController createCredential:newUsername password:newPassword server:newServer];
	if (c == nil) return;
	if ([newAlias length] > 0)
		[c setComment:newAlias];
	[c setBrowser:newBrowser];
	[window performClose:self];
	if (openWhenDone)
		[mainController launchSalesforceForClient:sf andCredential:c];
}

- (IBAction)addCredential:(id)sender {
	[self checkAndAdd:NO];
}

- (IBAction)addAndLogin:(id)sender {
	[self checkAndAdd:YES];
}

- (NSString *)newUsername {
	return newUsername;
}
- (void)setNewUsername:(NSString *)s {
	if (s == newUsername) return;
	[newUsername release];
	newUsername = [s retain];	
}

- (NSString *)newPassword {
	return newPassword;
}
- (void)setNewPassword:(NSString *)s {
	if (s == newPassword) return;
	[newPassword release];
	newPassword = [s retain];
}

- (NSString *)newServer {
	return newServer;
}
- (void)setNewServer:(NSString *)s {
	if (s == newServer) return;
	[newServer release];
	newServer = [s retain];	
}

- (NSString *)newAlias {
	return newAlias;
}

- (void)setNewAlias:(NSString *)aNewAlias {
	if (newAlias == aNewAlias) return;
	[newAlias release];
	newAlias = [aNewAlias retain];
}

- (Browser *)newBrowser {
	return newBrowser;
}

- (void)setNewBrowser:(Browser *)aNewBrowser {
	if (aNewBrowser == newBrowser) return;
	[newBrowser release];
	newBrowser = [aNewBrowser retain];
}

- (void)addServer:(id)sender {
	[newServerController showAddServer:window finishedTarget:self];
}

- (void)newServerAdded:(NSString *)server {
	[self setNewServer:server];
}

- (NSArray *)browsers {
	return [Browser browsers];
}
@end
