/* NewPasswordController */

#import <Cocoa/Cocoa.h>
#import "credential.h"
#import "AppController.h"

@interface NewPasswordController : NSObject {
    IBOutlet NSWindow *window;
	IBOutlet AppController *mainController;
	
	Credential	*credential;
	NSString 	*error;
	NSString 	*password;
}

- (void)showNewPasswordWindow:(Credential *)c withError:(NSString *)err;
- (IBAction)login:(id)sender;

- (NSString *)error;
- (void)setError:(NSString *)newError;
- (Credential *)credential;
- (void)setCredential:(Credential *)aValue;
- (NSString *)server;
- (NSString *)username;
- (NSString *)password;
- (void)setPassword:(NSString *)aPassword;

@end
