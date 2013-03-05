#import "AppController.h"
#import "Credential.h"
#import "zkSforceClient.h"
#import "zkDescribeSObject.h"
#import "zkSoapException.h"
#import "NewPasswordController.h"
#import "Browser.h"
#import "BrowserSetting.h"
#import "zkLoginResult.h"
#import "zkUserInfo.h"
#import "zkParser.h"

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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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
		
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
}

-(void)defaultsChanged:(NSNotification *)notification {
	[self updateCredentialList];
}

- (void)updateCredentialList {
	NSMutableArray *all = [NSMutableArray array];
	for (NSString *server in [[NSUserDefaults standardUserDefaults] objectForKey:@"servers"]) {
		NSArray *credentials = [Credential sortedCredentialsForServer:server];
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SortByAlias"]) {
			NSSortDescriptor *alias = [[[NSSortDescriptor alloc] initWithKey:@"comment" ascending:YES] autorelease];
			NSSortDescriptor *usern = [[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES] autorelease];
			credentials = [credentials sortedArrayUsingDescriptors:[NSArray arrayWithObjects:alias, usern, nil]];
		}
		[all addObjectsFromArray:credentials];
	}
	[currentCredentials autorelease];
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
	ZKDescribeGlobalSObject *type;
	ZKDescribeSObject *desc;
	desc = [sforce describeSObject:[[types lastObject] name]];
	if ([[desc urlNew] length] > 0) return desc;
	
	NSMutableArray *typeNames = [NSMutableArray array];
	for (type in types)
		[typeNames addObject:[type name]];
	
	// try some major entities we know should have urls
	NSArray *toTry = [NSArray arrayWithObjects:@"Event", @"Task", @"Product2", @"Contact", @"OpportunityLineItem", @"Opportunity", @"Lead", @"Account", nil];
	for (NSString *typeToTry in toTry) {
		if ([typeNames containsObject:typeToTry]) {
			desc = [sforce describeSObject:typeToTry];
			if ([[desc urlNew] length] > 0) return desc;
		}
	}
	// what, still no luck? grrh, brute force that sucker
	for (type in types) {
		desc = [sforce describeSObject:[type name]];
		if ([[desc urlNew] length] > 0) return desc;
	}
	return nil;
}

- (ZKSforceClient *)clientForServer:(NSString *)server {
	ZKSforceClient *sforce = [[[ZKSforceClient alloc] init] autorelease];
	[sforce setLoginProtocolAndHost:server andVersion:17];
	[sforce setClientId:[self clientId]];
	return sforce;
}

- (IBAction)launchHelp:(id)sender {
	NSString *help = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ZKHelpUrl"];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:help]];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
	NSLog(@"connection:%@ willSendRequest:%@ redirect:%@", connection, request, redirectResponse);
	return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"connection:%@ didRR:%@ statusCode:%d", connection, response, [response statusCode]);
}

-(NSURL *)baseInstanceUrl:(ZKSforceClient *)sforce {
	NSString *idPath = [NSString stringWithFormat:@"/id/%@/%@", [[[sforce currentUserInfo] organizationId] substringToIndex:15], [[[sforce currentUserInfo] userId] substringToIndex:15]];
	NSURL *authUrl = [sforce authEndpointUrl]; // [NSURL URLWithString:[sforce serverUrl]]; 
	if ([[authUrl host] caseInsensitiveCompare:@"www.salesforce.com"] == NSOrderedSame)
		authUrl = [NSURL URLWithString:@"https://login.salesforce.com/"];
	NSURL *identityUrl = [NSURL URLWithString:idPath relativeToURL:authUrl];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:identityUrl];
	[request addValue:@"application/xml" forHTTPHeaderField:@"Accept"];	
	//[request setHTTPShouldHandleCookies:NO];
	//[request addValue:@"MacTrapdoor" forHTTPHeaderField:@"User-Agent"];
	//[request addValue:@"*" forHTTPHeaderField:@"Accept-Language"];
	//[request addValue:@"login.salesforce.com" forHTTPHeaderField:@"Host"];
	[request addValue:[NSString stringWithFormat:@"OAuth %@", [sforce sessionId]] forHTTPHeaderField:@"Authorization"];
	
	NSHTTPURLResponse *resp = nil;
	NSError *err = nil;
	NSLog(@"request url : %@", [request URL]);
	NSLog(@"request headers : \r\n%@", [request allHTTPHeaderFields]);

	NSURLConnection *con = [NSURLConnection connectionWithRequest:request delegate:self];
	[con start];
	return nil;

/*
	NSData *respPayload = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
	NSLog(@"statusCode:%d", [resp statusCode]);
	NSLog(@"headers: \r\n%@", [resp allHeaderFields]);
	NSLog(@"response \r\n%@", [NSString stringWithCString:[respPayload bytes] length:[respPayload length]]);
	if ([resp statusCode] == 302) {
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[resp allHeaderFields] objectForKey:@"Location"]]];
		[request addValue:@"application/xml" forHTTPHeaderField:@"Accept"];	
		respPayload = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
	}
	NSLog(@"response \r\n%@", [NSString stringWithCString:[respPayload bytes] length:[respPayload length]]);
	zkElement *root = [zkParser parseData:respPayload];

	zkElement *urls = [root childElement:@"urls"];
	zkElement *ent = [urls childElement:@"enterprise"];
	NSString *entUrl = [ent stringValue];
	return [NSURL URLWithString:@"/" relativeToURL:[NSURL URLWithString:entUrl]];*/
}

- (void)launchSalesforceForClient:(ZKSforceClient *)sforce andCredential:(Credential *)credential {
	[sforce setCacheDescribes:YES];
	//ZKDescribeSObject *desc = [self describeSomethingWithUrls:sforce];
	//NSString *sUrl = desc != nil ? [desc urlNew] : [sforce serverUrl];
	//NSURL *url = [NSURL URLWithString:sUrl];
	NSURL *url = [self baseInstanceUrl:sforce];
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
		ZKLoginResult *lr = [sforce login:[c username] password:[c password]];
		if ([lr passwordExpired]) {
			[newpassController showChangePasswordWindow:c withError:@"Your password has expired, please enter a new password" client:sforce];
		} else {
			[self launchSalesforceForClient:sforce andCredential:c];
		}
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
	int keyShortCut = 1;
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
		NSString *shortcut = keyShortCut < 10 ? [NSString stringWithFormat:@"%d", keyShortCut++] : @"";
	    NSMenuItem *newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:itemTitle action:NULL keyEquivalent:shortcut];
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
