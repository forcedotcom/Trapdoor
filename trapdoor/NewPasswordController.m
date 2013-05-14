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

#import "NewPasswordController.h"
#import "zkSforceClient.h"
#import "zkDescribeSObject.h"
#import "zkSoapException.h"
#import "zkUserInfo.h"
#import "zkLoginResult.h"

@implementation NewPasswordController

+ (void)initialize {
	[self setKeys:[NSArray arrayWithObject:@"credential"] triggerChangeNotificationsForDependentKey:@"server"];
	[self setKeys:[NSArray arrayWithObject:@"credential"] triggerChangeNotificationsForDependentKey:@"username"];
}

-(void)showWindowForCredential:(Credential *)c withError:(NSString *)err {
	[self setCredential:c];
	[self setError:err];
	[self setPassword:[c password]];
	[NSApp activateIgnoringOtherApps:YES];
	[window makeKeyAndOrderFront:self];
}

- (void)showNewPasswordWindow:(Credential *)c withError:(NSString *)err {
	[self setForLogin:YES];
	[self showWindowForCredential:c withError:err];
}

- (void)showChangePasswordWindow:(Credential *)c withError:(NSString *)err client:(ZKSforceClient *)client {
	[clientWithExpiredPassword autorelease];
	clientWithExpiredPassword = [client retain];
	[self setForLogin:NO];
	[self showWindowForCredential:c withError:err];
}

- (IBAction)tryLogin:(id)sender {
	ZKSforceClient *sforce = [mainController clientForServer:[credential server]];
	@try {
		ZKLoginResult *lr = [sforce login:[credential username] password:password];
		if ([lr passwordExpired]) {
			[self showChangePasswordWindow:credential withError:@"Your password has expired, please enter a new password" client:sforce];
		} else {
			[credential update:[credential username] password:password];
			[mainController launchSalesforceForClient:sforce andCredential:credential];
			[window orderOut:sender];
			[self setCredential:nil];
			[self setError:nil];
			[self setPassword:nil];
		}
	}
	@catch (ZKSoapException *ex) {
		[self setError:[ex reason]];
		NSBeep();
	}
}

- (IBAction)setPasswordAndLogin:(id)sender {
	@try {
		[clientWithExpiredPassword setPassword:password forUserId:[[clientWithExpiredPassword currentUserInfo] userId]];
		[self tryLogin:sender];
	}
	@catch (ZKSoapException *ex) {
		[self setError:[ex reason]];
		NSBeep();
	}
}

- (IBAction)login:(id)sender {
	if ([self forLogin])
		[self tryLogin:sender];
	else
		[self setPasswordAndLogin:sender];
}


- (void)dealloc {
	[error release];
	[credential release];
	[password release];
	[clientWithExpiredPassword release];
	[super dealloc];
}

- (BOOL)forLogin {
	return forLogin;
}

- (void)setForLogin:(BOOL)n {
	forLogin = n;
}

- (NSString *)server {
	return [credential server];
}
- (NSString *)username {
	return [credential username];
}

- (Credential *)credential {
	return credential;
}

- (void)setCredential:(Credential *)aValue {
	Credential *oldCredential = credential;
	credential = [aValue retain];
	[oldCredential release];
}

- (NSString *)error {
	return error;
}

- (void)setError:(NSString *)aError {
	aError = [aError copy];
	[error release];
	error = aError;
}

- (NSString *)password {
	return password;
}

- (void)setPassword:(NSString *)aPassword {
	aPassword = [aPassword copy];
	[password release];
	password = aPassword;
}

@end
