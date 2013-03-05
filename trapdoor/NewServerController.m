//
//  NewServerController.m
//  trapdoor
//
//  Created by Simon Fell on 4/28/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import "NewServerController.h"


@implementation NewServerController

- (void)dealloc {
	[newServer release];
	[super dealloc];
}

- (IBAction)addServer:(id)sender {
	NSArray *servers = [[NSUserDefaults standardUserDefaults] objectForKey:@"servers"];
	if ([servers containsObject:newServer]) return;
	NSMutableArray *s = [NSMutableArray arrayWithArray:servers];
	[s addObject:newServer];
	[[NSUserDefaults standardUserDefaults] setObject:s forKey:@"servers"];
	[self cancelAddServer:sender];
	[target newServerAdded:newServer];
}

- (IBAction)cancelAddServer:(id)sender {
	[NSApp endSheet:newServerWindow];
	[newServerWindow orderOut:sender];
}

- (IBAction)showAddServer:(NSWindow *)parentWindow finishedTarget:(NSObject<NewServerAdded> *)t {
	target = t;
	[NSApp beginSheet:newServerWindow modalForWindow:parentWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
	[newServerWindow orderFront:self];
}

- (NSString *)newServer {
	return newServer;
}

- (void)setNewServer:(NSString *)aNewServer {
	aNewServer = [aNewServer copy];
	[newServer release];
	newServer = aNewServer;
}

@end
