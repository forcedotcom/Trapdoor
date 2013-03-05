//
//  AllCredentialsController.m
//  trapdoor
//
//  Created by Simon Fell on 4/21/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import "AllCredentialsController.h"
#import "GDOutlineView.h"
#import "BrowserSetting.h"
#import "Browser.h"
#import "CredentialEditor.h"
#import "NewServerController.h"

@interface ServerCredentials : NSObject {
	NSString 	*server;	
	NSArray		*credentials;
}
+ (id)forServer:(NSString *)server;

- (id)initForServer:(NSString *)server;
- (NSString *)server;
- (NSArray *)credentials;
- (void)setCredentials:(NSArray *)c;
- (void)reloadCredentials;
@end

@implementation ServerCredentials 

+ (id)forServer:(NSString *)server {
	ServerCredentials *c = [[ServerCredentials alloc] initForServer:server];
	return [c autorelease];
}

- (void)dealloc {
	[server release];
	[credentials release];
	[super dealloc];
}

- (id)initForServer:(NSString *)serverName {
	self = [super init];
	server = [serverName copy];
	[self reloadCredentials];
	return self;
}

- (void)reloadCredentials {
	[self setCredentials:[Credential sortedCredentialsForServer:server]]; 
}

- (NSString *)server {
	return server;
}

- (void)setCredentials:(NSArray *)c {
	if (credentials == c) return;
	[credentials release];
	credentials = [c retain];
}

- (NSArray *)credentials {
	return credentials;
}
	
@end

@implementation AllCredentialsController

- (void)dealloc {
	[rootList release];
	[current release];
	[super dealloc];
}

- (void)loadCredentials {
	NSArray * servers = [[NSUserDefaults standardUserDefaults] objectForKey:@"servers"];
	NSMutableArray *items = [NSMutableArray arrayWithCapacity:[servers count]];
	NSString *server;
	NSEnumerator *e = [servers objectEnumerator];
	while (server = [e nextObject]) 
		[items addObject:[ServerCredentials forServer:server]];
	[rootList release];
	rootList = [items retain];
	[credList reloadData];
}

- (IBAction)showCredentials:(id)sender {
	[self loadCredentials];
	[credList setRowHeightToFontHeightRatio:1.5];
	if ([rootList count] > 0) {
		id item;
		NSEnumerator *e = [rootList objectEnumerator];
		while (item = [e nextObject]) 
			[credList expandItem:item];
		if ([[[rootList objectAtIndex:0] credentials] count] > 0)
			[credList selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
	}
	[window makeKeyAndOrderFront:sender];
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	if (item == nil) 
		return [rootList count];
	return [[item credentials] count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	return item == nil || [item isKindOfClass:[ServerCredentials class]];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
	if (item == nil) 
		return [rootList objectAtIndex:index];
	return [[item credentials] objectAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if ([item isKindOfClass:[ServerCredentials class]])
		return [item server];
	return	[item username];
}

- (NSImage *)outlineView:(NSOutlineView *)outlineView iconOfItem:(id)item {
	return nil;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	Credential *c = [credList itemAtRow:[credList selectedRow]];
	CredentialEditor *ce = [[[CredentialEditor alloc] initForCredential:c] autorelease];
	[self setCurrentCredential:ce];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	return [item isKindOfClass:[Credential class]];
}

- (CredentialEditor *)currentCredential {
	return current;
}

- (void)setCurrentCredential:(CredentialEditor *)aValue {
	if (aValue == current) return;
	[current release];
	current = [aValue retain];
}

- (NSArray *)browsers {
	return [Browser browsers];
}

- (IBAction)showPassword:(id)sender {
	[current populatePasswordFromCredential:sender];
}

- (IBAction)saveChanges:(id)sender {
	if ([current saveChanges:sender]) {
		ServerCredentials *sc;
		NSEnumerator *e = [rootList objectEnumerator];
		// reload all the items to reflect the move to a new server node.
		while (sc = [e nextObject]) {
			[sc reloadCredentials];
			[credList reloadItem:sc reloadChildren:YES];
			// remake the selection
			if ([[sc server] isEqualToString:[current server]]) {
				Credential *c;
				NSEnumerator *ce = [[sc credentials] objectEnumerator];
				while (c = [ce nextObject]) {
					if ([[c username] isEqualToString:[current username]] &&
					    [[c comment] isEqualToString:[current alias]]) {
							[credList selectRowIndexes:[NSIndexSet indexSetWithIndex:[credList rowForItem:c]] byExtendingSelection:NO];
					}
				}
			}
		}
	}
}

- (IBAction)removeCurrentFromKeychain:(id)sender {
	[current removeFromKeychain:sender];
	ServerCredentials *sc;
	NSEnumerator *e = [rootList objectEnumerator];
	while (sc = [e nextObject]) {
		if ([[sc server] isEqualToString:[current server]]) {
			[sc reloadCredentials];
			[credList selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
			[credList reloadItem:sc reloadChildren:YES];
			return;
		}
	}
}

- (IBAction)addSever:(id)sender {
	[newServerController showAddServer:window finishedTarget:self];
}

- (void)newServerAdded:(NSString *)server {
	[current setServer:server];
	[rootList addObject:[ServerCredentials forServer:server]];
	[credList reloadData];
}

@end
