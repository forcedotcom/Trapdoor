/* NewPasswordController */

#import <Cocoa/Cocoa.h>
#import "credential.h"
#import "AppController.h"

@class ZKSforceClient;

@interface NewPasswordController : NSObject {
    IBOutlet NSWindow *window;
	IBOutlet AppController *mainController;
	
	Credential	*credential;
	NSString 	*error;
	NSString 	*password;
	BOOL		forLogin;
	
	ZKSforceClient	*clientWithExpiredPassword;
}

- (void)showNewPasswordWindow:(Credential *)c withError:(NSString *)err;
- (void)showChangePasswordWindow:(Credential *)c withError:(NSString *)err client:(ZKSforceClient *)client;

- (IBAction)login:(id)sender;

- (NSString *)error;
- (void)setError:(NSString *)newError;
- (Credential *)credential;
- (void)setCredential:(Credential *)aValue;
- (NSString *)server;
- (NSString *)username;
- (NSString *)password;
- (void)setPassword:(NSString *)aPassword;

- (BOOL)forLogin;
- (void)setForLogin:(BOOL)n;

@end
