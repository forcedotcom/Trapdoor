#import "NewPasswordController.h"
#import "zkSforceClient.h"
#import "zkDescribeSObject.h"
#import "zkSoapException.h"

@implementation NewPasswordController

+ (void)initialize {
	[self setKeys:[NSArray arrayWithObject:@"credential"] triggerChangeNotificationsForDependentKey:@"server"];
	[self setKeys:[NSArray arrayWithObject:@"credential"] triggerChangeNotificationsForDependentKey:@"username"];
}

- (void)showNewPasswordWindow:(Credential *)c withError:(NSString *)err {
	[self setCredential:c];
	[self setError:err];
	[self setPassword:[c password]];
	[NSApp activateIgnoringOtherApps:YES];
	[window makeKeyAndOrderFront:self];
}

- (IBAction)login:(id)sender {
	ZKSforceClient *sforce = [mainController clientForServer:[credential server]];
	@try {
		[sforce login:[credential username] password:password];
		[credential update:[credential username] password:password];
		[mainController launchSalesforceForClient:sforce andCredential:credential];
		[window orderOut:sender];
		[self setCredential:nil];
		[self setError:nil];
		[self setPassword:nil];
	}
	@catch (ZKSoapException *ex) {
		[self setError:[ex reason]];
		NSBeep();
	}
}

- (void)dealloc {
	[error release];
	[credential release];
	[password release];
	[super dealloc];
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
