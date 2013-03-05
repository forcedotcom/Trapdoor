//
//  BrowserSetting.m
//  trapdoor
//
//  Created by Simon Fell on 4/21/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import "BrowserSetting.h"
#import "Browser.h"

@implementation Credential (BrowserSetting)

- (NSString *)browserKey {
	return [NSString stringWithFormat:@"%@!%@", [self server], [self username]];
}

- (void)setBrowser:(Browser *)b  {
	if ([b bundleIdentifier] == nil) 
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:[self browserKey]];
	else 
		[[NSUserDefaults standardUserDefaults] setObject:[b bundleIdentifier] forKey:[self browserKey]];
}

- (Browser *)browser {
	NSString *bundle = [[NSUserDefaults standardUserDefaults] stringForKey:[self browserKey]];
	return [Browser forBundleIdentifier:bundle];
}

@end
