//
//  CredentialEditor.m
//  trapdoor
//
//  Created by Simon Fell on 4/25/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import "CredentialEditor.h"


@implementation CredentialEditor

- (void)dealloc {
	[username release];
	[password release];
	[alias release];
	[server release];
	[browser release];
	[credential release];
	[super dealloc];
}

- (void)setCredential:(Credential *)c {
	if (credential == c) return;
	[credential release];
	credential = [c retain];
	if (credential != nil) {
		username = [[credential username] copy];
		alias = [[credential comment] copy];
		server = [[credential server] copy];
		browser = [[credential browser] retain];
	}
}

- (id)initForCredential:(Credential *)c {
	self = [super init];
	[self setCredential:c];
	return self;
}

- (void)populatePasswordFromCredential:(id)sender {
	[self setPassword:[credential password]];
}

- (IBAction)removeFromKeychain:(id)sender {
	[credential removeFromKeychain];
}

- (BOOL)saveChanges:(id)sender {
	BOOL reloadList = NO;
	if (![[credential server] isEqualToString:server]) {
		[credential setServer:server];
		reloadList = YES;
	}
	if (![username isEqualToString:[credential username]])
		[credential setUsername:username];
	if (password != nil)
		[credential setPassword:password];
	
	[credential setComment:alias];
	[credential setBrowser:browser];
	return reloadList;
}

- (IBAction)createNewCredential:(id)sender {
	Credential *c = [Credential createCredentialForServer:server username:username password:password];
	[c setComment:alias];
	[c setBrowser:browser];
	[credential release];
}

- (NSString *)username {
	return username;
}

- (void)setUsername:(NSString *)aUsername {
	aUsername = [aUsername copy];
	[username release];
	username = aUsername;
}

- (NSString *)password {
	return password;
}

- (void)setPassword:(NSString *)aPassword {
	aPassword = [aPassword copy];
	[password release];
	password = aPassword;
}

- (NSString *)alias {
	return alias;
}

- (void)setAlias:(NSString *)aAlias {
	aAlias = [aAlias copy];
	[alias release];
	alias = aAlias;
}

- (NSString *)server {
	return server;
}

- (void)setServer:(NSString *)aServer {
	aServer = [aServer copy];
	[server release];
	server = aServer;
}

- (Browser *)browser {
	return browser;
}

- (void)setBrowser:(Browser *)aValue {
	Browser *oldBrowser = browser;
	browser = [aValue retain];
	[oldBrowser release];
}

@end
