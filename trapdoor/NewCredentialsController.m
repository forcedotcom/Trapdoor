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

#import "NewCredentialsController.h"
#import "AppController.h"
#import "zkSforceClient.h"
#import "zkSoapException.h"
#import "credential.h"
#import "Browser.h"
#import "BrowserSetting.h"

@implementation NewCredentialsController

@synthesize newUsername, newPassword, newServer, newAlias;

-(id)init {
	self = [super init];
	return self;
}

-(void)dealloc {
	[newUsername release];
	[newPassword release];
	[newServer release];
	[newAlias release];
	[super dealloc];
}

- (void)awakeFromNib {
	[Browser buildPopUpButtonForBrowsers:browsers];
	[self setNewServer:prodUrl];
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
	[c setBrowser:[[browsers selectedItem] representedObject]];
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
