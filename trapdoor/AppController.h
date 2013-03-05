/* AppController */

#import <Cocoa/Cocoa.h>

@class ZKSforceClient;
@class NewPasswordController;
@class Credential;

extern NSString *prodUrl, *testUrl;

@interface AppController : NSObject
{
	IBOutlet NSWindow *welcomeWindow;
	IBOutlet NSMenu   *loginMenu;
	IBOutlet NewPasswordController *newpassController;
	
	NSArray  *currentCredentials;
	NSMenu	 *dockMenu;
}

- (IBAction)launchHelp:(id)sender;
- (IBAction)performLogin:(id)sender;
- (void)launchSalesforceForClient:(ZKSforceClient *)client;
- (BOOL)hasSomeCredentials;
- (ZKSforceClient *)clientForServer:(NSString *)server;
- (Credential *)createCredential:(NSString *)newUsername password:(NSString *)newPassword server:(NSString *)newServer;

@end
