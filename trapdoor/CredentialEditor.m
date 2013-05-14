/**
 * Copyright (c) 2007, salesforce.com, inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided
 * that the following conditions are met:
 *
 *    Redistributions of source code must retain the above copyright notice, this list of conditions and the
 *    following disclaimer.
 *
 *    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
 *    the following disclaimer in the documentation and/or other materials provided with the distribution.
 *
 *    Neither the name of salesforce.com, inc. nor the names of its contributors may be used to endorse or
 *    promote products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

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
