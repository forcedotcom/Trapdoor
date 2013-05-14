/**
 * Copyright (c) 2007, salesforce.com, inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided
 * that the following conditions are met:
 *
 *    Redistributions of source code must retain the above copyright notice, this list of conditions and the
 *    following disclaimer.
 *
 *    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
 *    the following disclaimer in the documentation and/or other materials provided with the distribution.
 *
 *    Neither the name of salesforce.com, inc. nor the names of its contributors may be used to endorse or
 *    promote products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import "Browser.h"
#import "AppController.h"

@implementation Browser

static NSArray *browsers;
static NSDictionary *browsersByBid;

+ (id)withLabel:(NSString *)lbl bundleId:(NSString *)bid {
	Browser *b = [[Browser alloc] init];
	[b setLabel:lbl];
	[b setBundleIdentifier:bid];
	return [b autorelease];
}

+ (void)initialize {
	NSMutableArray *allBrowsers = [NSMutableArray array];
	NSURL *url = [NSURL URLWithString:@"https://www.salesforce.com"];
	NSArray *apps = [(NSArray *)LSCopyApplicationURLsForURL((CFURLRef)url,  kLSRolesViewer) autorelease];
	NSMutableDictionary *byId = [NSMutableDictionary dictionary];
	for (NSURL *appUrl in apps) {
		if ([[appUrl path] rangeOfString:@"vmwarevm"].location != NSNotFound) continue;	// skip VMWares hack nonsense
		NSBundle *bundle = [NSBundle bundleWithPath:[appUrl path]];
		if ([byId objectForKey:[bundle bundleIdentifier]] != nil) continue;
		NSString *bundleName = [bundle objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
		if ([bundleName length] == 0) {
			NSLog(@"Browser::initialize, skipping %@ because its bundle has no entry for kCFBundleNameKey", appUrl);
			continue;
		}
		Browser *browser = [Browser withLabel:bundleName bundleId:[bundle bundleIdentifier]];
		[allBrowsers addObject:browser];
		[byId setObject:browser forKey:[browser bundleIdentifierNoNil]];
	}

	NSSortDescriptor *sdl = [[[NSSortDescriptor alloc] initWithKey:@"label" ascending:TRUE] autorelease];
	[allBrowsers sortUsingDescriptors:[NSArray arrayWithObject:sdl]];
	Browser *sysDef = [Browser withLabel:@"System Default" bundleId:nil];
	[allBrowsers insertObject:sysDef atIndex:0];
	[byId setObject:sysDef forKey:[sysDef bundleIdentifierNoNil]];
	browsers = [allBrowsers retain];
	browsersByBid = [byId retain];
}

+ (NSArray *)browsers {
	return browsers;
}

+ (Browser *)forBundleIdentifier:(NSString *)bid {
	bid = bid == nil ? @"" : bid;
	Browser *b = [browsersByBid objectForKey:bid];
	return b == nil ? [browsersByBid objectForKey:@""] : b;
}

+ (void)buildPopUpButtonForBrowsers:(NSPopUpButton *)button {
	[button removeAllItems];
	for (Browser *b in [self browsers]) {
	    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[b label]  action:nil  keyEquivalent: @""];
		NSImage *i = [[[b icon] copy] autorelease];
		[i setSize:NSMakeSize(16,16)];
		[menuItem setImage:i];
		[menuItem setRepresentedObject:b];
		[[button menu] addItem: menuItem];
		[menuItem release];
	}
	[button selectItemAtIndex:0];
}
	
-(void)dealloc {
	[label release];
	[bundleIdentifier release];
	[icon release];
	[super dealloc];
}

- (NSString *)description {
	return label;
}

- (NSString *)label {
	return label;
}

-(NSImage *)icon {
	if (icon == nil) {
		NSString *path = nil;
		if (bundleIdentifier == nil) {	// system default
			NSURL *appUrl = nil;
			LSGetApplicationForURL((CFURLRef)[NSURL URLWithString:@"https://www.salesforce.com"], kLSRolesViewer, NULL, (CFURLRef *)&appUrl);
			path = [appUrl path];
			[appUrl autorelease];
		} else {
			path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:bundleIdentifier];
		}
		if (path != nil)
			icon = [[[NSWorkspace sharedWorkspace] iconForFile:path] retain];
	}
	return icon;
}

- (void)setLabel:(NSString *)aLabel {
	aLabel = [aLabel copy];
	[label release];
	label = aLabel;
}

- (NSString *)bundleIdentifierNoNil {
	return bundleIdentifier == nil ? @"" : bundleIdentifier;
}

- (NSString *)bundleIdentifier {
	return bundleIdentifier;
}

- (void)setBundleIdentifier:(NSString *)aBundleIdentifier {
	aBundleIdentifier = [aBundleIdentifier copy];
	[bundleIdentifier release];
	bundleIdentifier = aBundleIdentifier;
}

@end
