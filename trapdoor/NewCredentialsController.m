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

@implementation NewCredentialsController

- (id)init {
	self = [super init];
	[self setNewServer:prodUrl];
	return self;
}

- (void)dealloc {
	[newUsername release];
	[newPassword release];
	[newServer release];
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
	if ([newAlias length] > 0)
		[c setComment:newAlias];
	[window performClose:self];
	if (openWhenDone)
		[mainController launchSalesforceForClient:sf];
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

- (IBAction)addServer:(id)sender {
	NSArray *servers = [[NSUserDefaults standardUserDefaults] objectForKey:@"servers"];
	if ([servers containsObject:newServer]) return;
	NSMutableArray *s = [NSMutableArray arrayWithArray:servers];
	[s addObject:newServer];
	[[NSUserDefaults standardUserDefaults] setObject:s forKey:@"servers"];
	[self cancelAddServer:sender];
}

- (IBAction)cancelAddServer:(id)sender {
	[NSApp endSheet:addServerWindow];
	[addServerWindow orderOut:sender];
}

- (IBAction)showAddServer:(id)sender {
	[NSApp beginSheet:addServerWindow modalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
	[addServerWindow orderFront:sender];
}

@end
