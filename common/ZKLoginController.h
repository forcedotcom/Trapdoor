/* ZKLoginController */

#import <Cocoa/Cocoa.h>

@class Credential;
@class ZKSforceClient;

@interface ZKLoginController : NSObject {
	NSString 		*username;
	NSString 		*password;
	NSString 		*server;
	NSString 		*clientId;
	NSArray  		*credentials;
	Credential 		*selectedCredential;
	ZKSforceClient 	*sforce;
	NSString		*newUrl;
	NSString		*statusText;
	
	NSWindow 			*modalWindow;
	id					target;
	SEL					selector;	
	IBOutlet NSWindow 	*window;
	IBOutlet NSButton 	*addButton;
	IBOutlet NSButton	*delButton;
	IBOutlet NSWindow	*newUrlWindow;
	IBOutlet NSProgressIndicator *loginProgress;
}

- (ZKSforceClient *)showModalLoginWindow:(id)sender;
- (void)showLoginWindow:(id)sender target:(id)target selector:(SEL)selector;
- (void)showLoginSheet:(NSWindow *)modalForWindow target:(id)target selector:(SEL)selector;

- (IBAction)cancelLogin:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)showAddNewServer:(id)sender;
- (IBAction)closeAddNewServer:(id)sender;
- (IBAction)addNewServer:(id)sender;
- (IBAction)deleteServer:(id)sender;

- (NSString *)username;
- (void)setUsername:(NSString *)aUsername;
- (NSString *)password;
- (void)setPassword:(NSString *)aPassword;
- (NSString *)server;
- (void)setServer:(NSString *)aServer;
- (NSArray *)credentials;
- (NSString *)newUrl;
- (void)setNewUrl:(NSString *)aNewUrl;
- (NSString *)statusText;
- (void)setStatusText:(NSString *)aStatusText;
- (BOOL)canDeleteServer;
- (NSString *)clientId;
- (void)setClientId:(NSString *)aClientId;
- (void)setClientIdFromInfoPlist;
@end
