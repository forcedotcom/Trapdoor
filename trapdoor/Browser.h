//
//  Browser.h
//  trapdoor
//
//  Created by Simon Fell on 4/21/07.
//  Copyright 2007 Simon Fell. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Browser : NSObject {
	NSString *label;
	NSString *bundleIdentifier;
	NSImage *icon;
}

+ (NSArray *)browsers;
+ (Browser *)forBundleIdentifier:(NSString *)bid;
+ (void)buildPopUpButtonForBrowsers:(NSPopUpButton *)button;

- (NSString *)label;
- (void)setLabel:(NSString *)aLabel;
- (NSString *)bundleIdentifier;
- (void)setBundleIdentifier:(NSString *)aBundleIdentifier;
- (NSString *)bundleIdentifierNoNil;

- (NSImage *)icon;

@end
