#import "NewPasswordController.h"
#import "zkSforceClient.h"
#import "zkDescribeSObject.h"
#import "zkSoapException.h"
#import "zkUserInfo.h"
#import "zkLoginResult.h"

@implementation NewPasswordController

+ (void)initialize {
	[self setKeys:[NSArray arrayWithObject:@"credential"] triggerChangeNotificationsForDependentKey:@"server"];
	[self setKeys:[NSArray arrayWithObject:@"credential"] triggerChangeNotificationsForDependentKey:@"username"];
}

-(void)showWindowForCredential:(Credential *)c withError:(NSString *)err {
	[self setCredential:c];
	[self setError:err];
	[self setPassword:[c password]];
	[NSApp activateIgnoringOtherApps:YES];
	[window makeKeyAndOrderFront:self];
}

- (void)showNewPasswordWindow:(Credential *)c withError:(NSString *)err {
	[self setForLogin:YES];
	[self showWindowForCredential:c withError:err];
}

- (void)showChangePasswordWindow:(Credential *)c withError:(NSString *)err client:(ZKSforceClient *)client {
	[clientWithExpiredPassword autorelease];
	clientWithExpiredPassword = [client retain];
	[self setForLogin:NO];
	[self showWindowForCredential:c withError:err];
}

- (IBAction)tryLogin:(id)sender {
	ZKSforceClient *sforce = [mainController clientForServer:[credential server]];
	@try {
		ZKLoginResult *lr = [sforce login:[credential username] password:password];
		if ([lr passwordExpired]) {
			[self showChangePasswordWindow:credential withError:@"Your password has expired, please enter a new password" client:sforce];
		} else {
			[credential update:[credential username] password:password];
			[mainController launchSalesforceForClient:sforce andCredential:credential];
			[window orderOut:sender];
			[self setCredential:nil];
			[self setError:nil];
			[self setPassword:nil];
		}
	}
	@catch (ZKSoapException *ex) {
		[self setError:[ex reason]];
		NSBeep();
	}
}

- (IBAction)setPasswordAndLogin:(id)sender {
	@try {
		[clientWithExpiredPassword setPassword:password forUserId:[[clientWithExpiredPassword currentUserInfo] userId]];
		[self tryLogin:sender];
	}
	@catch (ZKSoapException *ex) {
		[self setError:[ex reason]];
		NSBeep();
	}
}

- (IBAction)login:(id)sender {
	if ([self forLogin])
		[self tryLogin:sender];
	else
		[self setPasswordAndLogin:sender];
}


- (void)dealloc {
	[error release];
	[credential release];
	[password release];
	[clientWithExpiredPassword release];
	[super dealloc];
}

- (BOOL)forLogin {
	return forLogin;
}

- (void)setForLogin:(BOOL)n {
	forLogin = n;
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
