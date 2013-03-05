#import "AppController.h"
#import "Credential.h"
#import "zkSforceClient.h"
#import "zkDescribeSObject.h"
#import "zkSoapException.h"
#import "NewPasswordController.h"
#import "Browser.h"
#import "BrowserSetting.h"

NSString *prodUrl = @"https://www.salesforce.com";
NSString *testUrl = @"https://test.salesforce.com";

@interface AppController (Private)
- (void)updateCredentialList;
- (void)buildContextMenu;
@end

@implementation AppController

+ (void)initialize {
	NSMutableDictionary * defaults = [NSMutableDictionary dictionary];
	[defaults setObject:[NSArray arrayWithObjects:prodUrl, testUrl, nil] forKey:@"servers"];
	[defaults setObject:[NSNumber numberWithBool:YES] forKey:@"SUCheckAtStartup"];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

OSStatus keychainCallback (SecKeychainEvent keychainEvent, SecKeychainCallbackInfo *info, void *context) {
	AppController *ac = (AppController*)context;
	[ac updateCredentialList];
	return noErr; 
}

- (void)dealloc {
	SecKeychainRemoveCallback(keychainCallback);
	[currentCredentials release];
	[dockMenu release];
	[super dealloc];
}

- (void)awakeFromNib {
	[self updateCredentialList];
	[NSApp setDelegate:self];
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HideWelcome"]) 
		[welcomeWindow makeKeyAndOrderFront:self];
	OSStatus s = SecKeychainAddCallback(keychainCallback, kSecAddEventMask | kSecDeleteEventMask | kSecUpdateEventMask, self);
	if (s != noErr)
		NSLog(@"Trapdoor - unable to register for keychain changes, got error %d", s);
	
	// this is needed because if you add TD to the dock, sparkle won't update its icon if the app icon changes.
	NSImage *currentIcon = [NSImage imageNamed:@"td"];
	if (currentIcon != nil)
		[NSApp setApplicationIconImage:currentIcon];
}

- (void)updateCredentialList {
	NSMutableArray *all = [NSMutableArray array];
	NSArray *servers = [[NSUserDefaults standardUserDefaults] objectForKey:@"servers"];
	NSString *server;
	NSEnumerator *e = [servers objectEnumerator];
	while (server = [e nextObject]) {
		[all addObjectsFromArray:[Credential credentialsForServer:server]];
	}
	[currentCredentials release];
	currentCredentials = [all retain];
	[self buildContextMenu];
}

- (NSString *)clientId {
	static NSString *cid;
	if (cid != nil) return cid;
	NSDictionary *plist = [[NSBundle mainBundle] infoDictionary];
	cid = [[NSMutableString stringWithFormat:@"MacTrapdoor/%@", [plist objectForKey:@"CFBundleVersion"]] retain];
	return cid;
}

- (ZKDescribeSObject *)describeSomethingWithUrls:(ZKSforceClient *)sforce {
	NSArray *types = [sforce describeGlobal];
	// try a custom object first
	NSString *t;
	ZKDescribeSObject *desc;
	NSEnumerator *e = [types reverseObjectEnumerator];
	while (t = [e nextObject]) {
		if([t hasSuffix:@"__c"]) {
			desc = [sforce describeSObject:t];
			if ([[desc urlNew] length] > 0) return desc;
			break; // if it doesn't have one, no other custom objects are going to have one either
		}
	}
	// try some major entities we know should have urls
	NSArray *toTry = [NSArray arrayWithObjects:@"Event", @"Task", @"Product2", @"Contact", @"OpportunityLineItem", @"Opportunity", @"Lead", @"Account", nil];
	e = [toTry objectEnumerator];
	while (t = [e nextObject]) {
		if ([types containsObject:t]) {
			desc = [sforce describeSObject:t];
			if ([[desc urlNew] length] > 0) return desc;
		}
	}
	// what, still no luck? grrh, brute force that sucker
	e = [types objectEnumerator];
	while (t = [e nextObject]) {
		desc = [sforce describeSObject:t];
		if ([[desc urlNew] length] > 0) return desc;
	}
	return nil;
}

- (ZKSforceClient *)clientForServer:(NSString *)server {
	ZKSforceClient *sforce = [[[ZKSforceClient alloc] init] autorelease];
	[sforce setLoginProtocolAndHost:server];
	[sforce setClientId:[self clientId]];
	return sforce;
}

- (IBAction)launchHelp:(id)sender {
	NSString *help = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ZKHelpUrl"];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:help]];
}

- (void)launchSalesforceForClient:(ZKSforceClient *)sforce andCredential:(Credential *)credential {
	[sforce setCacheDescribes:YES];
	ZKDescribeSObject *desc = [self describeSomethingWithUrls:sforce];
	NSString *sUrl = desc != nil ? [desc urlNew] : [sforce serverUrl];
	NSURL *url = [NSURL URLWithString:sUrl];
	NSURL * fd = [NSURL URLWithString:[NSString stringWithFormat:@"/secur/frontdoor.jsp?sid=%@", [sforce sessionId]] relativeToURL:url];

	NSString *bundleIdentifier = [[credential browser] bundleIdentifier];
	if (bundleIdentifier == nil)
		[[NSWorkspace sharedWorkspace] openURL:fd];
	else
		[[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:fd] withAppBundleIdentifier:bundleIdentifier 
			options:NSWorkspaceLaunchAsync additionalEventParamDescriptor:nil launchIdentifiers:nil];
}

- (IBAction)performLogin:(id)sender {
	Credential *c = [sender representedObject];
	ZKSforceClient *sforce = [self clientForServer:[c server]];
	@try {
		[sforce login:[c username] password:[c password]];
		[self launchSalesforceForClient:sforce andCredential:c];
	}
	@catch (ZKSoapException *ex) {
		NSBeep();
		[newpassController showNewPasswordWindow:c withError:[ex reason]];
	}
}

- (void)addItemsToMenu:(NSMenu *)newMenu {
	Credential *c = nil;
	NSString *lastServer = nil;
	NSEnumerator *e = [currentCredentials objectEnumerator];
	while (c = [e nextObject]) {
		if (![[c server] isEqualToString:lastServer]) {
			if (lastServer != nil) 
				[newMenu addItem:[NSMenuItem separatorItem]];
		    NSMenuItem *newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:[c server] action:NULL keyEquivalent:@""];
		    [newMenu addItem:newItem];
		    [newItem release];
			lastServer = [c server];
		}
		NSString *itemTitle = [c username];
		if ([[c comment] length] > 0)
			itemTitle = [NSString stringWithFormat:@"%@ - %@", [c comment], [c username]];
	    NSMenuItem *newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:itemTitle action:NULL keyEquivalent:@""];
		[newItem setRepresentedObject:c];
	    [newItem setTarget:self];
	    [newItem setAction:@selector(performLogin:)];
	    [newMenu addItem:newItem];
	    [newItem release];
	}
}

- (void)buildContextMenu {
	NSMenu *newMenu = [[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"Login"];
	[self addItemsToMenu:newMenu];
	while ([loginMenu numberOfItems] >0)
		[loginMenu removeItemAtIndex:0];
	[self addItemsToMenu:loginMenu];
	[dockMenu release];
	dockMenu = newMenu;	
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender {
	return dockMenu;
}

- (BOOL)hasSomeCredentials {
	return [currentCredentials count] > 0;
}

- (Credential *)createCredential:(NSString *)newUsername password:(NSString *)newPassword server:(NSString *)newServer {
	ZKSforceClient *sforce = [self clientForServer:newServer];
	@try {
		[sforce login:newUsername password:newPassword];
		Credential *c = [Credential createCredentialForServer:newServer username:newUsername password:newPassword];
		if (c != nil)
			[self updateCredentialList];
		return c;
	}
	@catch (ZKSoapException *ex) {
		NSAlert * a = [NSAlert alertWithMessageText:[ex reason] defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Login failed"];
		[a runModal];
	}
	return nil;
}

@end
