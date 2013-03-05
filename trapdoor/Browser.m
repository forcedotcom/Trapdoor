//
//  Browser.m
//  trapdoor
//
//  Created by Simon Fell on 4/21/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import "Browser.h"

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
	NSDictionary *dict = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ZKBrowsers"];
	NSMutableArray *allBrowsers = [NSMutableArray array];
	[allBrowsers addObject:[Browser withLabel:@"System Default" bundleId:nil]];
	NSString *lbl;
	NSEnumerator *e = [dict keyEnumerator];
	while (lbl = [e nextObject]) {
		NSString *bid = [dict objectForKey:lbl];
		Browser *b = [Browser withLabel:lbl bundleId:bid];
		[allBrowsers addObject:b];
	}
	browsers = [allBrowsers retain];

	NSMutableDictionary *byId = [NSMutableDictionary dictionary];
	Browser *b;
	e = [browsers objectEnumerator];
	while (b = [e nextObject]) {
		[byId setObject:b forKey:[b bundleIdentifierNoNil]];
	}
	browsersByBid = [byId retain];
}

+ (NSArray *)browsers {
	return browsers;
}

+ (Browser *)forBundleIdentifier:(NSString *)bid {
	bid = bid == nil ? @"" : bid;
	return [browsersByBid objectForKey:bid];
}

- (NSString *)description {
	return label;
}

- (NSString *)label {
	return label;
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
