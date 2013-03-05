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
